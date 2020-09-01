public with sharing class AdminPageController {

    //Функция для получения значений оффисов
    @AuraEnabled
    public static List<String> getNameOffices(){
        List<String> listNameOffices = new List<String>();
        Schema.DescribeFieldResult fieldResult = Contact.Office__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry picklistEntry : pickListEntries){
            String oneOfficeName = picklistEntry.getValue();
            listNameOffices.add(oneOfficeName);
        }
        return listNameOffices;
    }

    //Функция для получения всех Monthly Expense за выбранный год
    @AuraEnabled
    public static List<Monthly_Expense__c> listMonthlyExpenseYear(Integer year){
        List<Monthly_Expense__c> listExpenseYear = new List<Monthly_Expense__c>();
        listExpenseYear = [SELECT Spent_Amount__c, Month_Date__c, Reminder__c, Balance__c, Keeper__c 
                            FROM Monthly_Expense__c
                            WHERE CALENDAR_YEAR(Month_Date__c) =: year];
        //System.debug(listExpenseYear);
        return listExpenseYear;               
    }

    //Функция для получения всех контактов всех оффисов
    @AuraEnabled
    public static List<Contact> listContactOffice(){
        List<Contact> listContact = new List<Contact>();
        listContact = [SELECT Id, Office__c, Name FROM Contact WHERE Office__c <> ''];
        //System.debug(listContact);
        return listContact;
    }

    //Функция для сортировки контактов для одного выбранного офиса
    @AuraEnabled
    public static List<Contact> listContact(List<Contact> listContact, String nameOffice){
        List<Contact> listOneOffice = new List<Contact>();
        for(Contact con : listContact){
            if(con.Office__c == nameOffice){
                listOneOffice.add(con);
            } else {
                continue;
            }
        }
        return listOneOffice;
    }

    //Функция для получения данных Monthly Expense для одного оффиса
    @AuraEnabled
    public static List<Monthly_Expense__c> listMonthlyExpense(List<Contact> listContact, List<Monthly_Expense__c> listMonthlyExpense, String nameOffice){
        List<Monthly_Expense__c> listMonthly = new List<Monthly_Expense__c>();
        List<Contact> listOneOffice = listContact(listContact, nameOffice);
        for(Contact con : listOneOffice){
            for(Monthly_Expense__c mon : listMonthlyExpense){
                if(mon.Keeper__c == con.Id){
                    listMonthly.add(mon);
                } else {
                    continue;
                }
            }
        }
        return listMonthly;
    }

    //Функция для заполния всех данных расходов для всех оффисов и для целого года
    @AuraEnabled
    public static List<espenseMonthsForYear> getespenseMonthsForYear(Integer year){
        List<espenseMonthsForYear> listEspenseMonthsForYear = new List<espenseMonthsForYear>();
        List<Monthly_Expense__c> listMonthlyExpenseYear = listMonthlyExpenseYear(year);
        List<Contact> listContactOffice = listContactOffice();
        //System.debug(listContactOffice);
        List<String> nameOffice = getNameOffices();
        List<String> nameMonths = new List<String>{'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};
        for(Integer i = 0; i < 12; i++){
            Decimal coun = 0;
            List<Decimal> listSpentAmount = new List<Decimal>();
            for(String nameOff: nameOffice){
                Decimal count = 0;

                List<Monthly_Expense__c> listExpenseYear = listMonthlyExpense(listContactOffice, listMonthlyExpenseYear, nameOff);
                for(Monthly_Expense__c oneExpense : listExpenseYear){
                    if(oneExpense.Month_Date__c.month() == i+1){
                        count += oneExpense.Spent_Amount__c;
                    } else {
                        continue;
                    }
                }
                coun += count;
                listSpentAmount.add(count);
            }
            listEspenseMonthsForYear.add(new espenseMonthsForYear(nameMonths[i], listSpentAmount, coun));

        }
        return listEspenseMonthsForYear;
    }

    //Функция для получения итогового баланса по каждому офису
    @AuraEnabled
    public static List<Decimal> getlistReminderYear(Integer year){
        List<Monthly_Expense__c> listMonthlyExpenseYear = listMonthlyExpenseYear(year);
        List<Contact> listContactOffice = listContactOffice();
        List<String> nameOffice = getNameOffices();
        List<Decimal> listReminderOffice = new List<Decimal>();
        for(String nameOff: nameOffice){
            List<Monthly_Expense__c> listExpenseYear = listMonthlyExpense(listContactOffice, listMonthlyExpenseYear, nameOff);
            Decimal count = 0;
            for(Monthly_Expense__c oneExpense : listExpenseYear){
                count += oneExpense.Reminder__c;
            }
            listReminderOffice.add(count.setscale(1));
        }
        //System.debug(listReminderOffice);
        return listReminderOffice;
    }

    //Функция для получения среднемесячного расхода по каждому офису
    @AuraEnabled
    public static List<Decimal> getlistEverageYear(Integer year){
        List<Monthly_Expense__c> listMonthlyExpenseYear = listMonthlyExpenseYear(year);
        List<Contact> listContactOffice = listContactOffice();
        List<String> nameOffice = getNameOffices();
        List<Decimal> listEverageYear = new List<Decimal>();
        for(String nameOff: nameOffice){
            List<Monthly_Expense__c> listExpenseYear = listMonthlyExpense(listContactOffice, listMonthlyExpenseYear, nameOff);
            Integer countMonths = 0;
            Decimal count = 0;
            for(Integer i = 0; i < 12; i++){
                Decimal num = 0;
                for(Monthly_Expense__c oneExpense : listExpenseYear){
                    if(oneExpense.Month_Date__c.month() == i+1){
                        count += oneExpense.Spent_Amount__c;
                        num += oneExpense.Spent_Amount__c;
                    } else {
                        continue;
                    }              
                }
                if(num != 0){
                    countMonths++;
                    num = 0;
                } else {
                    continue;
                }
            }
            if(countMonths != 0){
                count = (count/countMonths).setscale(2);
            } else {
                count.setscale(2);
            }
            listEverageYear.add(count);

        }
        //System.debug(listEverageYear);
        return listEverageYear;
    }

    //Функция для получения итоговых расходов по каждому офису
    @AuraEnabled
    public static espenseMonthsForYear getTotal(Integer year){
        List<Monthly_Expense__c> listMonthlyExpenseYear = listMonthlyExpenseYear(year);
        List<Contact> listContactOffice = listContactOffice();
        List<String> nameOffice = getNameOffices();
        String nameRow ='Total';
        Decimal coun = 0;
        List<Decimal> listSpentAmount = new List<Decimal>();
        for(String nameOff: nameOffice){
            Decimal count = 0;
            List<Monthly_Expense__c> listExpenseYear = listMonthlyExpense(listContactOffice, listMonthlyExpenseYear, nameOff);
            for(Monthly_Expense__c oneExpense : listExpenseYear){
                count += oneExpense.Spent_Amount__c;
            }
            coun += count;
            listSpentAmount.add(count);
        }
        espenseMonthsForYear oneEspenseMonthsForYear = new espenseMonthsForYear(nameRow, listSpentAmount, coun);
        //System.debug(oneEspenseMonthsForYear);
        return oneEspenseMonthsForYear;
    }


    //Общая фунция для заполнения таблицы из класса обертки
    @AuraEnabled
    public static expenseOfficesYear getInformation(Integer year){
        expenseOfficesYear oneYear = new expenseOfficesYear();
        oneYear.nameOffice = getNameOffices();
        oneYear.espenseMonthsForYear = getespenseMonthsForYear(year);
        oneYear.listReminderYear = getlistReminderYear(year);
        oneYear.listEverageYear = getlistEverageYear(year);
        oneYear.total = getTotal(year);
        //System.debug(oneYear);
        return oneYear;
    }


    //Классы обертки для заполнения таблицы
    /*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    */
    public class expenseOfficesYear {
        @AuraEnabled
        public List<String> nameOffice {get; set;}
        @AuraEnabled
        public List<espenseMonthsForYear> espenseMonthsForYear {get; set;}
        @AuraEnabled    
        public List<Decimal> listReminderYear {get; set;}
        @AuraEnabled    
        public List<Decimal> listEverageYear {get; set;}
        @AuraEnabled
        public espenseMonthsForYear total {get; set;}
    }

    public class espenseMonthsForYear{
        @AuraEnabled    
        public String nameMonth {get; set;}
        @AuraEnabled    
        public List<Decimal> expenseMonth {get; set;}
        @AuraEnabled    
        public Decimal summExpense {get; set;}

        public espenseMonthsForYear(String nameMonth, List<Decimal> expenseMonth, Decimal summExpense){
            this.nameMonth = nameMonth;
            this.expenseMonth = expenseMonth;
            this.summExpense = summExpense;
        }
    }

}
