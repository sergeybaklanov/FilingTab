trigger OpportunityTrigger on Opportunity(
    after insert, after update, after undelete, after delete 
){
    Set<Id> opportunityIds = new Set<Id>();
    Set<Id> accountsIdSet = new Set<Id>();
    if (Trigger.isAfter){
        if (Trigger.isInsert || Trigger.isUndelete){
            for (Opportunity opp_i : Trigger.new ){
                if (opp_i.AccountId != null && opp_i.IsWon){
                    accountsIdSet.add(opp_i.AccountId);
                }
            }
        }
        if (Trigger.isDelete){
            for (Opportunity opp_i : Trigger.old){
                if (opp_i.AccountId != null && opp_i.IsWon){
                    accountsIdSet.add(opp_i.AccountId);
                    opportunityIds.add(opp_i.Id);
                }
            }
        }
        if (Trigger.isUpdate){
            for (Opportunity opp_i : Trigger.new ){
                Opportunity oldOpp = Trigger.oldMap.get(opp_i.Id);
                if (opp_i.AccountId != oldOpp.AccountId && opp_i.IsWon){
                    if (opp_i.AccountId != null){
                        accountsIdSet.add(opp_i.AccountId);
                        opportunityIds.add(opp_i.Id);
                    }
                    if (oldOpp.AccountId != null){
                        accountsIdSet.add(oldOpp.AccountId);
                        opportunityIds.add(opp_i.Id);
                    }
                }
                if (opp_i.IsWon != oldOpp.IsWon && opp_i.AccountId != null){
                    accountsIdSet.add(opp_i.AccountId);
                    opportunityIds.add(opp_i.Id);
                }
            }
        }
        if (!accountsIdSet.isEmpty()){
            updateAccountTop3(accountsIdSet);
        }
    }

    private static void updateAccountTop3(Set<Id> opportunitiesIdSet){
        List<Account> accountsToUpdateList = new List<Account>();


        List<Account> accounts = [SELECT Id, Name, ReachTextArea__c, (SELECT Id, Name, (SELECT Id, Quantity, TotalPrice, Product2.Id, Product2.Name, Product2.Family
                                                                                        FROM OpportunityLineItems
                                                                                        ORDER BY TotalPrice DESC
                                                                                        LIMIT 3)
                                                                      FROM Opportunities
                                                                      WHERE IsWon = true AND IsClosed = true)
                                  FROM Account 
                                  WHERE Id IN (SELECT AccountId
                                               FROM Opportunity
                                               WHERE IsWon = true AND IsClosed = true)];
        for (Account account_i : accounts){
            String top3Products = '';
            for (Opportunity opp_i : account_i.Opportunities){
                for (OpportunityLineItem oppLineItem_i : opp_i.OpportunityLineItems){
                    top3Products += '<div> Id: ' + oppLineItem_i.Product2.Id + ' Name: ' + oppLineItem_i.Product2.Name + ' Family: ' + oppLineItem_i.Product2.Family + ' Quantity: ' + oppLineItem_i.Quantity + ' TotalPrice: ' + oppLineItem_i.TotalPrice + ' ' + '</div>';
                    System.debug('ReachTextArea__c: ' + account_i.ReachTextArea__c);
                }
            }
            if (top3Products != ''){
                account_i.ReachTextArea__c = top3Products;
                accountsToUpdateList.add(account_i);
            }
        }

        if (!accountsToUpdateList.isEmpty()){
            System.debug('Accounts to Update: ' + accountsToUpdateList);
            update accountsToUpdateList;
        }
    }

}