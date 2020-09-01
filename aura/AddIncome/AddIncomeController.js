({
    init : function(component, event, helper) {
        //Получаем параметы с компонента Expense Page и записываем их в аттрибут users
        let myPageRef = component.get("v.pageReference");
        let users = myPageRef.state;
        component.set("v.users", users);
    },
    //Функция возвращения на предыдущий компонент не внося изменений
    clickCancel : function(component, event, helper){
        let users = component.get("v.users");
        let navService = component.find("navService");
        let pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ExpensesPage',
            },
            state: {
                "c__Name": users[0].c__Name,
                "c__Email": users[0].c__Email,
                "c__Office": users[0].c__Office,
                "c__Year": users[0].c__Year,
                "c__Month": users[0].c__Month
            }
        };
        event.preventDefault();
        navService.navigate(pageReference);
    },

    clickAdding : function(component, event, helper){
        //Получаем все данные из формы
        let users = component.get("v.users");
        let amount = component.get('v.amount');
        //Вешаем событие для обращения в controller
        let action = component.get("c.addBalance");
        //Устанавливаем значение передоваемое в controller
        action.setParams({"addIncome" : amount , "year" : users[0].c__Year, "month" : users[0].c__Month, "nameEmail" : users[0].c__Email, "nameOffice" : users[0].c__Office});
        action.setCallback(this, function(response){
            let state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
    
                let result = response.getReturnValue();
                let users = component.get("v.users");
                let navService = component.find("navService");
                let pageReference = {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__ExpensesPage',
                    },
                    state: {
                        "c__Name": users[0].c__Name,
                        "c__Email": users[0].c__Email,
                        "c__Office": users[0].c__Office,
                        "c__Year": users[0].c__Year,
                        "c__Month": users[0].c__Month
                    }
                };
                event.preventDefault();
                //выводим сообщение о создании объекта
                let resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "SUCCESS!",
                    type : 'success',
                    "message": "Еhe balance was topped up."
                });
                $A.get("e.force:closeQuickAction").fire();
                resultsToast.fire();
                //Переходим на предыдущий компонент
                navService.navigate(pageReference);
            } else {
                //выводим сообщение об ошибке
                let resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "ERROR!",
                    type : 'error',
                    "message": "Check that the fields are filled in correctly."
                });
                $A.get("e.force:closeQuickAction").fire();
                resultsToast.fire();
            }
        });
        $A.enqueueAction(action);
    }
})
