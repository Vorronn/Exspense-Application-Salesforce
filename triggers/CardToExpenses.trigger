trigger CardToExpenses on Expense_Card__c (before insert) {
	//Созадем экземпляр объека
	List<Monthly_Expense__c> newMonthlyExpense = new List<Monthly_Expense__c>();
	//Циклом проходим по всем вновь создаваемым Expense Card
	for (Expense_Card__c exc: Trigger.new){
		//Получаем целое число года из даты объека
		Integer year = exc.Card_Date__c.year();
		//Получаем целое число месяца из даты объека
		Integer month = exc.Card_Date__c.month();
		//Выполняем запрос и находим нужные нам записи
		newMonthlyExpense = [SELECT Id, Spent_Amount__c, Month_Date__c, Reminder__c, Balance__c, Keeper__c 
							FROM Monthly_Expense__c
							WHERE CALENDAR_YEAR(Month_Date__c) =: year
							AND CALENDAR_MONTH(Month_Date__c) =: month
							AND Keeper__c =: exc.Card_Keeper__c];
		//Если записи есть то привязываем ее к нашему объекту если нет то создаем экземпляр объекта Monthly Expense и привязыаем его к нашему объекту
		if(newMonthlyExpense.size()!=0){
			exc.Monthly_Expense__c = newMonthlyExpense[0].Id;
		} else {
			Monthly_Expense__c newMonthly = new Monthly_Expense__c(Balance__c=0, Keeper__c=exc.Card_Keeper__c, Month_Date__c=exc.Card_Date__c);
			insert newMonthly;
			exc.Monthly_Expense__c = newMonthly.Id;

		}
	}

}