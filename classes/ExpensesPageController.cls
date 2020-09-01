public with sharing class ExpensesPageController {

    //Функция для получения всех Monthly Expense за указанный год
    @AuraEnabled
    public static List<Monthly_Expense__c> listMonthlyExpenseYear(Integer year){
        List<Monthly_Expense__c> listExpenseYear = new List<Monthly_Expense__c>();
        listExpenseYear = [SELECT Spent_Amount__c, Month_Date__c, Reminder__c, Balance__c, Keeper__c 
                            FROM Monthly_Expense__c
                            WHERE CALENDAR_YEAR(Month_Date__c) =: year];
        return listExpenseYear;               
    }

    //Получения списка контактов, если зашел Админ то берутся все сотруднки с оффиса если зашел сотрудник то он берется один для заполнения данных в таблице
    @AuraEnabled
    public static List<Contact> listContactOffice(String nameOffice, String nameEmail){
        List<Contact> listContact = new List<Contact>();
        if(nameEmail != ''){
            listContact = [SELECT Id, Office__c, Name, Email FROM Contact WHERE Office__c =: nameOffice AND Email =: nameEmail];
        } else {
            listContact = [SELECT Id, Office__c, Name, Email FROM Contact WHERE Office__c =: nameOffice];
        }
        System.debug(listContact);
        return listContact;
    }

    //Функция для отбора нужных Monthly Expense
    @AuraEnabled
    public static List<Monthly_Expense__c> listMonthlyExpense(List<Contact> listContact, List<Monthly_Expense__c> listMonthlyExpense, String nameOffice, String nameEmail){
        List<Monthly_Expense__c> listMonthly = new List<Monthly_Expense__c>();
        List<Contact> listOneOffice = listContactOffice(nameOffice, nameEmail);
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

    //Заполнение информации в табах
    @AuraEnabled
    public static List<officeMonth> getespenseMonthsForYear(Integer year, String nameOffice, String nameEmail){
        List<officeMonth> listOfficeMonth = new List<officeMonth>();
        List<Monthly_Expense__c> listMonthlyExpenseYear = listMonthlyExpenseYear(year);
        List<Contact> listContactOffice = listContactOffice(nameOffice, nameEmail);
        List<String> nameMonths = new List<String>{'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};
        for(Integer i = 0; i < 12; i++){
            Decimal income = 0;
            Decimal amount = 0;

            List<Monthly_Expense__c> listExpenseYear = listMonthlyExpense(listContactOffice, listMonthlyExpenseYear, nameOffice, nameEmail);
            for(Monthly_Expense__c oneExpense : listExpenseYear){
                if(oneExpense.Month_Date__c.month() == i+1){
                    System.debug(oneExpense.Month_Date__c.month());
                    income += oneExpense.Balance__c;
                    amount += oneExpense.Spent_Amount__c;
                } else {
                    continue;
                }
            }
            if(income == 0){
                income = null;
            }
            if(amount == 0){
                amount = null;
            }
            if(i == 0){
                listOfficeMonth.add(new officeMonth(nameMonths[i], amount, income, true));
            } else {
                listOfficeMonth.add(new officeMonth(nameMonths[i], amount, income, false));

            }

        }
        return listOfficeMonth;
    }

    //Функция для получения занчения total в Табах
    @AuraEnabled
    public static officeMonth getTotalYear(Integer year, String nameOffice, String nameEmail){
        List<Monthly_Expense__c> listMonthlyExpenseYear = listMonthlyExpenseYear(year);
        List<Contact> listContactOffice = listContactOffice(nameOffice, nameEmail);
        Decimal income = 0;
        Decimal amount = 0;
        List<Monthly_Expense__c> listExpenseYear = listMonthlyExpense(listContactOffice, listMonthlyExpenseYear, nameOffice, nameEmail);
        for(Monthly_Expense__c oneExpense : listExpenseYear){
            income += oneExpense.Balance__c;
            amount += oneExpense.Spent_Amount__c;
        }
        officeMonth oneOfficeMonth = new officeMonth('Total', amount, income, true);
        return oneOfficeMonth;
    }

    //Функция получения всех нужных нам Expense Card для оффиса или сотрудника
    @AuraEnabled
    public static List<Expense_Card__c> listMonthlyExpenseYear(Integer year, Integer month, String nameOffice, String nameEmail){
        List<Expense_Card__c> listExpenseCard = new List<Expense_Card__c>();
        List<Contact> listOneOffice = listContactOffice(nameOffice, nameEmail);
        listExpenseCard = [SELECT Id, Name, Amount__c, Card_Date__c, Card_Keeper__c, Description__c 
                            FROM Expense_Card__c
                            WHERE Card_Keeper__c IN : (listOneOffice) 
                            AND CALENDAR_YEAR(Card_Date__c) =: year
                            /*AND CALENDAR_MONTH(Card_Date__c) =: month*/];
        //System.debug(listExpenseCard);
        return listExpenseCard;               
    }

    //Получения всех данных Expense Card рассортированого по месяцам и дням
    @AuraEnabled
    public static List<listMonthsExpenseCard> getlistExpenseCardMonths(Integer year, Integer month, String nameOffice, String nameEmail){
        List<listMonthsExpenseCard> newlistMonthsExpenseCard =new List<listMonthsExpenseCard>();
        List<Expense_Card__c> listExpenseCard = listMonthlyExpenseYear(year, month, nameOffice, nameEmail);
        List<String> nameMonths = new List<String>{'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};
        for(Integer j = 0; j < 12; j++){
            List<expenseCard> newListExpenseCard = new List<expenseCard>();
            for(Integer i = 0; i < 31; i++){
                Decimal total = 0;
                List<Expense_Card__c> newListCard = new List<Expense_Card__c>();
                //System.debug(newListCard);
                String nameDate='';

                for(Expense_Card__c oneCard : listExpenseCard){
                    if(oneCard.Card_Date__c.day() == i+1 && oneCard.Card_Date__c.month() == j+1){
                        nameDate = String.valueOf(oneCard.Card_Date__c);
                        newListCard.add(oneCard);
                        total += oneCard.Amount__c;
                    } else {
                        continue;
                    }
                }
                if(total != 0){
                    newListExpenseCard.add(new expenseCard(nameDate, newListCard, total));
                } else {
                    continue;
                }
            }
            if(j==0){
                newlistMonthsExpenseCard.add(new listMonthsExpenseCard(j+1, nameMonths[j], newListExpenseCard, false));
            } else{
                newlistMonthsExpenseCard.add(new listMonthsExpenseCard(j+1, nameMonths[j], newListExpenseCard, true));
            }
        }
        //System.debug(newListExpenseCard);
        return newlistMonthsExpenseCard;
    }

    //Заполнение итогового класса обертки для передачи данных в контроллер компонента
    @AuraEnabled
    public static expenseOfficeName getInformation(Integer year, Integer month, String nameOffice, String nameEmail){
        expenseOfficeName oneYear = new expenseOfficeName();
        oneYear.listMothsInOffice = getespenseMonthsForYear(year, nameOffice, nameEmail);
        oneYear.totalYear = getTotalYear(year, nameOffice, nameEmail);
        oneYear.listMonthsExpenseCardYear = getlistExpenseCardMonths(year, month, nameOffice, nameEmail);
        return oneYear;
    }

    
    
    //Классы обертки для заполнения таблицы
    /*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    */
    public class expenseOfficeName {
        @AuraEnabled
        public List<officeMonth> listMothsInOffice {get; set;}
        @AuraEnabled
        public officeMonth totalYear {get; set;}
        @AuraEnabled
        public List<listMonthsExpenseCard> listMonthsExpenseCardYear {get; set;}
        
    }

    public class officeMonth {
        @AuraEnabled
        public String nameMonths {get; set;}
        @AuraEnabled
        public Decimal amount {get; set;}
        @AuraEnabled
        public Decimal income {get; set;}
        @AuraEnabled
        public Boolean active {get; set;}
        
        public officeMonth(String nameMonths, Decimal amount, Decimal income, Boolean active){
            this.nameMonths = nameMonths;
            this.amount = amount;
            this.income = income;
            this.active = active;
        }
    }

    public class listMonthsExpenseCard{
        @AuraEnabled
        public Integer numberMonths {get; set;}
        @AuraEnabled
        public String nameMonths {get; set;}
        @AuraEnabled
        public List<expenseCard> listExpenseCardMonths {get; set;}
        @AuraEnabled
        public Boolean active {get; set;}

        
        public listMonthsExpenseCard(Integer numberMonths, String nameMonths, List<expenseCard> listExpenseCardMonths, Boolean active){
            this.numberMonths = numberMonths;
            this.nameMonths = nameMonths;
            this.listExpenseCardMonths = listExpenseCardMonths;
            this.active = active;
        }
    }

    public class expenseCard {
        @AuraEnabled
        public String nameDay {get; set;}
        @AuraEnabled
        public List<Expense_Card__c> listExpense {get; set;}
        @AuraEnabled
        public Decimal totalDay {get; set;}


        public expenseCard(String nameDay, List<Expense_Card__c> listExpense, Decimal totalDay){
            this.nameDay = nameDay;
            this.listExpense = listExpense;
            this.totalDay = totalDay;
        }
    }
    /*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    */

    //Функции редактирования таблицы
    /*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    */ 
    @AuraEnabled
    public static List<Expense_Card__c> getAllExpenseCard(){
        return [SELECT Id, Name, Amount__c, Card_Date__c, Card_Keeper__c, Description__c FROM Expense_Card__c] ;
    }


    @AuraEnabled
    public static void updateExpenseCard(List<Expense_Card__c> exc){
        update exc;
    }

    @AuraEnabled
    public static void deleteExpenseCard(String idExpenseCard){
        List<Expense_Card__c> oldExpenseCard = new List<Expense_Card__c>();
        oldExpenseCard = [SELECT Id, Name FROM Expense_Card__c WHERE Id =:idExpenseCard];
        delete oldExpenseCard;
        
    }
        /*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    */
}
