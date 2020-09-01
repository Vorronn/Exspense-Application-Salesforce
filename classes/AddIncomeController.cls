public with sharing class AddIncomeController {
    @AuraEnabled
    public static Monthly_Expense__c addBalance(Decimal addIncome, Integer year, Integer month, String nameEmail, String nameOffice){
        //Получаем пользователя приложения
        Contact incomeContact = [SELECT Id, Office__c, Name, Email 
                                FROM Contact 
                                WHERE Office__c =: nameOffice 
                                AND Email =: nameEmail
                                LIMIT 1];
        //Получаем данные Monthly Expense для указаного месяца
        List<Monthly_Expense__c> monthMonthlyExpense = new List<Monthly_Expense__c>();
        monthMonthlyExpense = [SELECT Spent_Amount__c, Month_Date__c, Reminder__c, Balance__c, Keeper__c 
                            FROM Monthly_Expense__c
                            WHERE CALENDAR_YEAR(Month_Date__c) =: year
                            AND CALENDAR_MONTH(Month_Date__c) =: month
                            AND Keeper__c =: incomeContact.Id
                            LIMIT 1];
        Monthly_Expense__c newExpense = new Monthly_Expense__c();
        //Проверяем есть ли Monthly Expense если есть то пополняем баланс если нет то создаем новую Monthly Expense с указанным балансом
        if(monthMonthlyExpense.size() != 0){
            monthMonthlyExpense[0].Balance__c +=addIncome;
            update monthMonthlyExpense;
            return monthMonthlyExpense[0];
        } else {
            String newDate = year + '-' + month + '-' + '01';
            Date currentDate = Date.valueOf(newDate);
            newExpense.Keeper__c = incomeContact.Id;
            newExpense.Balance__c = addIncome;
            newExpense.Month_Date__c = currentDate;
            insert newExpense;
            return newExpense;
        }

    }

}
