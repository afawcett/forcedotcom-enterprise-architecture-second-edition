({
    /**
     * Calls Apex Controller method to load Race Calendar sets 'calendar' attribute
     **/
    getCalendar : function(component, event ) {
        var action = component.get("c.getRaceCalendar");
        action.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS') {
                    component.set("v.calendar", response.getReturnValue());
                }                
            });
        $A.enqueueAction(action);        
    },
    /**
     * Utility function scans a list of races and marks the given race as selected
     **/
    selectRace : function(races, raceId) {
        for(var raceIdx = 0; raceIdx < races.length; raceIdx++) {
            races[raceIdx].Selected = races[raceIdx].Id == raceId ? true : false;
        }
    }    
})