({
    init : function(component, event, helper) {
        //Получаем параметы с компонента и записываем их в аттрибут users
        let myPageRef = component.get("v.pageReference");
        let users = myPageRef.state;
        component.set("v.users", users);

        //Получение текущей даты
        let currentDate = new Date();
        //Получение полного года
        let yyyy = currentDate.getFullYear();
        //Заполнение массива для Select
        let listYears = [];
        for(let i = yyyy; i > (yyyy - 4); i--){
            listYears.push(i);
        }
        component.set("v.listNameYear", listYears);
        component.set("v.nameYear", yyyy);
        //Получение данных через контроллер
        helper.helperGetInformation(component, event, helper);
    },

    //Функция для отображения данных в зависимости от выбраного года в selectMenu
    handleMenuSelect: function (component, event, helper){
        var menuValue = event.detail.menuItem.get("v.value");
        component.set("v.nameYear", menuValue);
        helper.helperGetInformation(component, event, helper);
    },

    //Функция перехода к данным одного из оффисов
    clickToOffice: function(component, event, helper){
        let users = component.get("v.users");
        let nameYear = component.get("v.nameYear");
        //Получаем название оффиса через кнопку
        let nameOffice = event.getSource().get("v.label");
        let navService = component.find("navService");
        let pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ExpensesPage',
            },
            state: {
                "c__Name": nameOffice,
                "c__Email": '',
                "c__Office": nameOffice,
                "c__Year": users[0].c__Year,
                "c__Month": 1, 
                "c__NameAdmin": users[0].c__Name,
                "c__NameEmail": users[0].c__Email

            }
        };
        //console.log(pageReference);
        event.preventDefault();

        navService.navigate(pageReference);
    }
})
