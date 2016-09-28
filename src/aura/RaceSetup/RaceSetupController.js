({
    /**
     * Loads wrapped list of drivers for selection by the user
     **/
	onInit : function(component, event, helper) {
	    helper.getDrivers(component, event);
	},
	/**
     * Close the action popup
     **/
    onCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    /**
     * Passes the selected drivers back to the Apex controller, if successful closes action popup
     **/
    onAddDrivers : function(component, event, helper) {
        helper.addDrivers(component, event);
    }
})