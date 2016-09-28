({
    /**
     * Loads the race calendar from the server
     **/
    onInit : function(component, event, helper) {
        helper.getCalendar(component, event);
    },
    /**
     * Updates the selected race to the one clicked and fires the RaceSelected application event
     **/
    onRaceClicked : function(component, event, helper) {
    
        // Establish the selected race via the HTML5 data attribute raceid added in the markup
        var selectedRaceId = event.currentTarget.dataset.raceid;
        var selectedRaceName = event.currentTarget.dataset.racename;
        
        // Mark the race as selected and deselect any currently selected
        var calendar = component.get('v.calendar');
        helper.selectRace(calendar.Remaining, selectedRaceId);
        helper.selectRace(calendar.Completed, selectedRaceId);
        component.set("v.calendar", calendar);
        
        // Fire the RaceSelected event
        var compEvent = $A.get("e.c:RaceSelected");
        compEvent.setParams({"raceId" : selectedRaceId } );
        compEvent.setParams({"raceName" : selectedRaceName } );
        compEvent.fire();        
    }
})