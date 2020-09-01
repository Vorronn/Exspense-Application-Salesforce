({
    helperGetInformation : function(component, event, helper) {
        // $A.get("e.force:refreshView").fire();
        let users = component.get("v.users");

        let action = component.get("c.getInformation");
        //Устанавливаем значение передоваемое в controller
        action.setParams({"year" : users[0].c__Year, "month" : users[0].c__Month, "nameOffice" : users[0].c__Office, "nameEmail" : users[0].c__Email});
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){
    
                let result = response.getReturnValue();
                //Записываем значения для отображения их в dataTable
                component.set('v.espenseMonthsForYear', result.listMothsInOffice);                
                component.set('v.rowTotal', result.totalYear);
                component.set('v.listCard', result.listMonthsExpenseCardYear);
    
                component.set('v.balance', (component.get('v.rowTotal[0].income') - component.get('v.rowTotal[0].amount')).toFixed(2));

                //console.log(component.get('v.balance'));
            } else {
                component.set("v.message",'Error:');
                //alert('There is no data in the database and the API service is not available! try to get the data a little later!');
            }
        });
        $A.enqueueAction(action);

    },

    //Функция для получения всех Expense Card
    fetchData: function (component,event,helper) {
        var action = component.get("c.getAllExpenseCard");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set('v.data',data);
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        $A.enqueueAction(action);
    },

    // Refresh : function(component, event, helper) {
	// 	$A.get('e.force:refreshView').fire();
    //     $A.get("e.force:closeQuickAction").fire();
	// }
})
