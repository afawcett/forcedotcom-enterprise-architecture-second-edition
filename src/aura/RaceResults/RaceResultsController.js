({
    /**
     * Loads the race results for the race specified in the event
     **/
	handleRaceSelectedEvent : function(component, event, helper) {
	
	    // Update race record Id and Name attributes
		component.set('v.recordId', event.getParam('raceId'));
		component.set('v.recordName', event.getParam('raceName'));

		// Retrieve race results
		helper.getRaceResults(component, event);
	}
})