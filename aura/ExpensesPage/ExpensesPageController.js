({
    init : function(component, event, helper) {
       /// $A.get("e.force:refreshView").fire();
    //Получаем данные с другого компонента
    let myPageRef = component.get("v.pageReference");
    let users = myPageRef.state;
    component.set("v.users", users);
    //Проверяем кто заходит на этот компонет(если сотрудник то отображются кнопки New Card Expense и Income, елси же зашел admin то отображается кнока backToAdmin Page)
    component.set('v.nameLogin', users.c__Name);
    if(users.c__Email == ''){
        component.set("v.truthy", false);
    } else {
        component.set("v.truthy", true);
    }

    //Получение текущей даты
    let currentDate = new Date();
    //Получение полного года
    let yyyy = currentDate.getFullYear();
    //Устанавливаем значения кнопок отображения номера года
    let listYears = [];
    for(let i = yyyy; i > (yyyy - 4); i--){
        listYears.push(i);
    }
    component.set("v.listNameYear", listYears);

    
    // for(let i=1; i<5; i++){
    //     let button = component.find('button'+i);
    //     $A.util.removeClass(button, 'slds-button_dual-stateful slds-is-pressed');
    //     if(button.get("v.label") == users.c__Year){
    //         console.log(button.get("v.label"));

    //         $A.util.addClass(button, 'slds-button_dual-stateful slds-is-pressed');
    //     } else {
    //         continue;
    //     }

    // }
    
    // Устанавливаем значения колонок для автоматического заполнения таблицы
    component.set('v.columns', [
    {label: 'DESCRIPTION', fieldName: 'Description__c', type: 'text', editable : 'true'},
    {label: 'AMOUNT', fieldName: 'Amount__c', type: 'currency', initialWidth: 100, typeAttributes: { currencyCode: 'USD'},cellAttributes: { alignment: 'left' }, editable : 'true'},
    {label: 'ACTION',  type: 'button', initialWidth: 100,  typeAttributes: { label: 'Delete', name: 'delete', title: 'Click to View Details' , variant: 'base'}, cellAttributes: { alignment: 'left' }},

    ]);

    //Вызываем метод контроллера Apex для полученмя данных из БД
    helper.helperGetInformation(component, event, helper);
    helper.fetchData(component,event, helper);
    //helper.Refresh(component, event, helper);
    },
    // handleSaveEdition: function (cmp, event, helper) {
    //     var draftValues = event.getParam('draftValues');

    //     helper.saveEdition(cmp, draftValues);
    // },


    //Функция перехода на другой компонент для создания Expense Card
    clickNewExpenses: function (component, event, helper){
        let users = component.get("v.users");
        console.log(users);
        let navService = component.find("navService");
        let pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__NewExpenseCard',
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

    //Функция перехода на другой компонент для пополнения баланса
    clickIncome: function (component, event, helper){
        let users = component.get("v.users");
        let currentMonth = component.get("v.currentMonth");
        //console.log(users);
        let navService = component.find("navService");
        let pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__AddIncome',
            },
            state: {
                "c__Name": users[0].c__Name,
                "c__Email": users[0].c__Email,
                "c__Office": users[0].c__Office,
                "c__Year": users[0].c__Year,
                "c__Month": currentMonth
            }
        };
        event.preventDefault();

        navService.navigate(pageReference);
    },

    //Функция перехода на другой компонент - Админисатратора, работает только если сам админимтор зашел на страницу
    clickBackAdminPage: function (component, event, helper){    
        let year = component.get("v.listNameYear");
        console.log(year);
        let users = component.get("v.users");
        let navService = component.find("navService");
        let pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__AdminPage',
            },
            state: {
                "c__Name": users[0].c__NameAdmin,
                "c__Email": users[0].c__NameEmail,
                "c__Office": undefined,
                "c__Year": year[0],
                "c__Month": users[0].c__Month
            }
        };
        //console.log(pageReference);
        event.preventDefault();

        navService.navigate(pageReference);
    },

    //Функция переключения номера года
    clickNumberYear: function(component, event, helper){
        //Удаляем со всех кнопок стиль нажатой кнопки
        for(let i=1; i<5; i++){
            let button = component.find('button'+i);
            //console.log(button.get("v.label"));
            $A.util.removeClass(button, 'slds-button_dual-stateful slds-is-pressed');
        }
        //Получаем нажатую кнопку
        let button = event.getSource();
        //Получаем Id  нажатой кнопи
        let buttonClick = component.find(button.getLocalId());
        //Добавляем классы для отображения нажатой кнопки
        $A.util.addClass(buttonClick, 'slds-button_dual-stateful slds-is-pressed');
    
        //Устанавливаем текущее значения года и вызываем функцию для получения данный из Apex 
        component.set("v.users[0].c__Year", button.get("v.label"));
        helper.helperGetInformation(component, event, helper);
    },

    //Функция для отображения Табов
    clickTab: function(component, event, helper){
        //Получаем dataset нажатого таба
        var id = event.target.dataset.menuItemId;
        //console.log(id);
        //Получаем все месяца
        let months= component.get("v.espenseMonthsForYear");
        //console.log(months);
        //Проходим циклом и устанавливаем нажатое значение в true остальные false
        for(let i=0; i< months.length; i++){
            //console.log(months[i].active);
            if(months[i].nameMonths == id){
                months[i].active = true;
                component.set("v.currentMonth", i+1);
                //console.log(component.get("v.currentMonth"));
            } else {
                months[i].active = false;
            }
        }

        //Аналогично поступаем с отображением контента при нажатом Tab
        let monthsCard = component.get("v.listCard");

        for(let i=0; i<monthsCard.length; i++){

            if(monthsCard[i].nameMonths == id){
                monthsCard[i].active = false;
            } else {
                monthsCard[i].active = true;
            }
        }
        //Устанавливаем текущии значения
        component.set("v.listCard", monthsCard);
        component.set("v.espenseMonthsForYear", months);

        // if (id) {
        //     component.getSuper().navigate(id);
        //     //console.log(id);
        //  }
    },

    //Функция для Action в данный момент для Delete
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                component.set('v.recordId', row.Id);
                console.log(component.get('v.recordId'));
                var action2 = component.get("c.deleteExpenseCard");
                action2.setParams({"idExpenseCard" : row.Id});
                action2.setCallback(this, function(response) {
                    var state = response.getState();
                    $A.get('e.force:refreshView').fire();
                    
                });
                $A.enqueueAction(action2);

                break;
        }
    },

    //Функция для внесение изменений в dataTable
    handleSaveEdition: function (component, event, helper) {
        var draftValues = event.getParam('draftValues');
        console.log(draftValues);
        var action = component.get("c.updateExpenseCard");
        action.setParams({"exc" : draftValues});
        action.setCallback(this, function(response) {
            var state = response.getState();
            $A.get('e.force:refreshView').fire();
            
        });
        $A.enqueueAction(action);
    },

    handleCancelEdition: function (component) {
        // do nothing for now...
    }


})

