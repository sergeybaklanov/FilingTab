trigger CaseTriggerTest on Case(
    after insert, after update, after delete, after undelete 
){
    Set<Id> accountsId = new Set<Id>();
    if (Trigger.isInsert || Trigger.isUndelete){
        for (Case case_i : Trigger.new ){
            if (case_i.AccountId != null){
                accountsId.add(case_i.AccountId);
            }
        }
    }
    if (Trigger.isDelete){
        for (Case case_i : Trigger.old){
            if (case_i.AccountId != null){
                accountsId.add(case_i.AccountId);
            }
        }
    }
    if (Trigger.isUpdate){
        for (Case case_i : Trigger.new ){
            Case oldCase = Trigger.oldMap.get(case_i.Id);
            if (case_i.AccountId != oldCase.AccountId){
                if (case_i.AccountId != null && case_i.IsClosed == false){
                    accountsId.add(case_i.AccountId);
                }
                if (oldCase.AccountId != null && oldCase.IsClosed == false){
                    accountsId.add(oldCase.AccountId);
                }
            }
            if (case_i.IsClosed != oldCase.IsClosed && case_i.AccountId != null){
                accountsId.add(case_i.AccountId);
            }
        }
    }

    private void updateCaseNumOnAccount(Set<Id> accountsId){
        List<Account> accountsToUpdate = new List<Account>();
        List<AggregateResult> result = [SELECT AccountId acc, COUNT(ID)countCases
                                        FROM CASE
                                        WHERE AccountId IN:(new List<Id>(accountsId)) AND IsClosed = true
                                        GROUP BY AccountId];
        for (AggregateResult res_i : result){
            accountsToUpdate.add(new Account(
                Id = (Id) res_i.get('acc'), 
                Amount_of_open_cases__c = (Integer) res_i.get('countCases')
            ));
        }

        if (!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }

    }

}