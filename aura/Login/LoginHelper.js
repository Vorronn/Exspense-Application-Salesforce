({
    //Функция отображния сообщения
    displayToast : function(title, type, message) {
        let resultToast = $A.get("e.force:showToast");
        resultToast.setParams({
            "title" : title,
            type: type,
            "message" : message
        });
        $A.get("e.force:closeQuickAction").fire();
        resultToast.fire();
    }
})
