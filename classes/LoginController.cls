public with sharing class LoginController {

    @AuraEnabled
    public static Contact loginNameUser(String email, String password){
        Contact loginNameContact = [SELECT Id, Name, FirstName, LastName, Email, Password__c, Office__c, Admin__c FROM Contact WHERE Email =: email and Password__c =: password LIMIT 1];
        return loginNameContact;
    }
}
