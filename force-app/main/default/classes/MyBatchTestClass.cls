public with sharing class MyBatchTestClass  implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT ID FROM Account');
    }
    public void execute(Database.BatchableContext context, List<Account> accounts){ 
        System.debug('Batch for all accounts');
    }
    
    public void finish(Database.BatchableContext context) {
        System.debug('Batch for all accounts finished');
    }
}