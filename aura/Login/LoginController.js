({
    init : function(component, event, helper) {

    },

    loginClick : function (component, event, helper) {
        //Получаем значение Login        
        let login = component.find("loginEmail").get("v.value");
        //Получаем значение Password        
        let password = component.find("inputPassword").get("v.value");
        //Проверяем валидный ли введен Login в форме Email
        let validity = component.find("loginEmail").get("v.validity");

        if(login == '' || password == ''){
            //Выводим сообщение об ошибке
            helper.displayToast("WARNING!", "warning", "Enter your username and password!");
        } else if(validity.valid != true ) {
            //Выводим сообщение об ошибке
            helper.displayToast("WARNING!", "warning", "Enter valid username in the format yourname@domain.com!");
        } else {
            let action = component.get("c.loginNameUser");
            action.setParams({"email" : login, "password" : password});
            action.setCallback(this, function(response){
                let state =response.getState();
                console.log(state);
                if(state === "SUCCESS"){

                    //Получение текущей даты для передачи ее в параметры на другой компонент
                    let currentDate = new Date();
                    let dd = String(currentDate.getDate() - 1).padStart(2, '0');
                    let mm = String(currentDate.getMonth() + 1).padStart(2, '0');
                    let yyyy = currentDate.getFullYear();

                    let result = response.getReturnValue();
                    //Проверяем Админ или не админ и переходим либо на страницу админа или пользователя
                    let admin = result.Admin__c;
                    if(admin){
                        let navService = component.find("navService");
                        let pageReference = {
                            type: 'standard__component',
                            attributes: {
                                componentName: 'c__AdminPage',
                            },
                            state: {
                                "c__Name": result.Name,
                                "c__Email": result.Email,
                                "c__Office": result.Office__c,
                                "c__Year": yyyy,
                                "c__Month": mm
                            }
                        };
                        console.log(pageReference);
                        event.preventDefault();
                        navService.navigate(pageReference);
                    } else {
                        let navService = component.find("navService");
                        let pageReference = {
                            type: 'standard__component',
                            attributes: {
                                componentName: 'c__ExpensesPage',
                            },
                            state: {
                                "c__Name": result.Name,
                                "c__Email": result.Email,
                                "c__Office": result.Office__c,
                                "c__Year": yyyy,
                                "c__Month": mm
                            }
                        };
                        event.preventDefault();
                        navService.navigate(pageReference);
                    }


                } else {
                    //Выводим сообщение об ошибке
                    helper.displayToast("ERROR!", "Error", "This user does not exist, please make sure that the username and password are filled in correctly!");

                }
            });
            $A.enqueueAction(action);
        }
    }
})
