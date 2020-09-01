public with sharing class NewExpenseCardController {
    //Функция для создания новой Expense Card с параметрами из контроллера компонента
    @AuraEnabled
    public static Expense_Card__c addCard(Decimal amount, String dateInput, String description, String nameEmail, String nameOffice){
        //Преобразование строки в дату
        Date dateinput1 = Date.valueOf(dateInput);
        //Ищем связанный контакт с этой записью
        Contact cardContact = [SELECT Id, Office__c, Name, Email 
                                FROM Contact 
                                WHERE Office__c =: nameOffice 
                                AND Email =: nameEmail
                                LIMIT 1];
        //Создаем новый объукт типа Expense Card заполняем его и возвращаем его значение ( связанная запись Monthly Expense создается в Trigger)
        Expense_Card__c newCard = new Expense_Card__c();
        newCard.Amount__c=amount;
        newCard.Card_Date__c=dateInput1;
        newCard.Card_Keeper__c=cardContact.Id;
        newCard.Description__c=description;
        insert newCard;
        return newCard;
    }
}
