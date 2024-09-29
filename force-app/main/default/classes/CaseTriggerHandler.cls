public with sharing class CaseTriggerHandler {
        public static void afterInsertCases(Map<Id, Case> caseMap){
            List<Case> casesList = [SELECT Id FROM Case WHERE Status != 'Closed'];

        }   
}