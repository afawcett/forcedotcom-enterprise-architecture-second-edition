({
    /**
     * Passes the selected drivers back to the Apex controller, if successful closes action popup
     **/
    onAddDrivers : function(component, event, helper) {
        helper.addDrivers(component, event);
    }
})