trigger CaseTrigger on Case(
    after insert, after update, after delete, after undelete 
){
    Set<Id> accountIdSet = new Set<Id>();
    if (Trigger.isAfter){
        if (Trigger.isInsert || Trigger.isUndelete){
            for (Case case_i : Trigger.new ){
                if (case_i.AccountId != null && case_i.IsClosed == false){
                    accountIdSet.add(case_i.AccountId);
                }
            }
        }
        if (Trigger.isDelete){
            for (Case case_i : Trigger.old){
                if (case_i.AccountId != null && case_i.IsClosed == false){
                    accountIdSet.add(case_i.AccountId);
                }
            }
        }
        if (Trigger.isUpdate){
            for (Case case_i : Trigger.new ){
                Case oldCase = Trigger.oldMap.get(case_i.Id);
                if (case_i.AccountId != oldCase.AccountId){
                    if (case_i.AccountId != null && case_i.IsClosed == false){
                        accountIdSet.add(case_i.AccountId);
                    }
                    if (oldCase.AccountId != null && oldCase.IsClosed == false){
                        accountIdSet.add(oldCase.AccountId);
                    }
                }
                if (case_i.IsClosed != oldCase.IsClosed && case_i.AccountId != null){
                    accountIdSet.add(case_i.AccountId);
                }
            }
        }
        updateCaseNumOnAccounts(accountIdSet);
    }

    private static void updateCaseNumOnAccounts(Set<Id> accountIdSet){
        List<Account> listAccountsToUpdate = new List<Account>();
        List<AggregateResult> result = [SELECT AccountId accId, COUNT(ID)countedCases
                                        FROM Case
                                        WHERE AccountId IN:(new List<Id>(accountIdSet)) AND IsClosed = false
                                        GROUP BY AccountId];
        for (AggregateResult res_i : result){
            listAccountsToUpdate.add(new Account(
                Id = (Id) res_i.get('accId'), 
                Amount_of_open_cases__c = (Integer) res_i.get('countedCases')
            ));
        }
        if(!listAccountsToUpdate.isEmpty()){
            update listAccountsToUpdate;
        }
    }

}