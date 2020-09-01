({
    helperGetInformation : function(component, event, helper) {

        let nameYear = component.get("v.nameYear");
        let action = component.get("c.getInformation");
        //Устанавливаем значение передоваемое в controller
        action.setParams({"year" : nameYear});
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){

                let result = response.getReturnValue();
                //Записываем значения для отображения их в dataTable
                component.set('v.nameOffice', result.nameOffice);
                component.set('v.espenseMonthsForYear', result.espenseMonthsForYear);                
                component.set('v.listReminderYear', result.listReminderYear);
                component.set('v.listEverageYear', result.listEverageYear);
                component.set('v.rowTotal', result.total);
                
            } else {
                component.set("v.message",'Error:'+' the database is not available');
            }
        });
        $A.enqueueAction(action);
    }
})
