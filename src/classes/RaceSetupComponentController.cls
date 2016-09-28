public with sharing class RaceSetupComponentController {
 
    @AuraEnabled
    public static List<DriverSelection> getDriverList() {
        List<DriverSelection> drivers = new List<DriverSelection>();
        for(Driver__c driver : new DriversSelector().selectAll()) {
            DriverSelection driverSelection = new DriverSelection();
            driverSelection.RecordId = driver.Id;
            driverSelection.Name = driver.Name;
            driverSelection.Selected = false;
            drivers.add(driverSelection);            
        }
        return drivers;
    }
    
    @AuraEnabled
    public static Integer addDrivers(Id raceId, List<DriverSelection> driversToAdd) {
        Map<Id, List<Id>> driversByRaceId = new Map<Id, List<Id>>();
        List<Id> selectedDriverIds = new List<Id>();
        for(Integer driverIdx=0; driverIdx < driversToAdd.size(); driverIdx++) {
            DriverSelection driverSelection = driversToAdd[driverIdx];
            if(driverSelection.Selected) {
                selectedDriverIds.add(driverSelection.RecordId);                
            }
        }
        driversByRaceId.put(raceId, selectedDriverIds);
        return RaceService.addDrivers(driversByRaceId).get(raceId);
    }

    public class DriverSelection {
        @AuraEnabled
        public Id RecordId;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public Boolean Selected;
    }   
}