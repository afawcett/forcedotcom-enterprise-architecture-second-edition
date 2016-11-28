public class RaceServiceImpl implements IRaceService {
    
    public Map<Id, List<RaceService.ProvisionalResult>> calculateProvisionResults(Set<Id> raceIds) {           
        throw new RaceService.RaceServiceException('Not implemented');
    }

    public void applyRaceResults(Map<Id, List<RaceService.ProvisionalResult>> provisionalResultsByRaceId) {
        throw new RaceService.RaceServiceException('Not implemented');
    }

    public void awardChampionshipPoints(Set<Id> raceIds) {
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        // Query Races and contestants and bulkify list of all contestants
        RacesSelector racesSelector = (RacesSelector) Application.Selector.newInstance(Race__c.SObjectType);        
        List<Contestant__c> contestantsList = new List<Contestant__c>();
        for(Race__c race : racesSelector.selectByIdWithContestants(raceIds)) {
            contestantsList.addAll(race.Contestants__r);            
        }
        
        // Delegate to Contestant Domain class
        Contestants contestants = (Contestants) Application.Domain.newInstance(contestantsList);
        contestants.awardChampionshipPoints(uow);

        // Commit work
        uow.commitWork();
    }
    
	public String generateSummaryAsCSV(Set<Id> raceIds)
	{
		// Query summaries via custom selector method
		Map<Id, List<ContestantsSelector.Summary>> summariesByRaceId = 
			new ContestantsSelector().selectByRaceIdWithContestantSummary(raceIds);
		// Construct CSV output (note this is not a formal implementation of the CSV spec)
		String csvOutput = '';
		for(Id raceId : summariesByRaceId.keySet())
			for(ContestantsSelector.Summary raceContestantSummary : summariesByRaceId.get(raceId))
				csvOutput+= String.join(
					new Object[] { 
							raceContestantSummary.Season,
							raceContestantSummary.Race,
							raceContestantSummary.Position,
							raceContestantSummary.Driver,
							raceContestantSummary.Team,
							raceContestantSummary.Car
						} , ',') + '\r\n';
		return csvOutput;
	}
	
    public Map<Id, Integer> addDrivers(Map<Id, List<Id>> driversByRaceId) {
        
        // TODO: Provide a means to determine drivers current car for the season
        List<Car__c> cars = new CarsSelector().selectAll();
        if(cars.size()>0) {
            throw new RaceService.RaceServiceException('Must have at least one Car record in the system');          
        }        
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
 
        // Create Contestant__c records for each Driver for the given Race
        for(Id raceId : driversByRaceId.keySet()) {
            for(Id driverId : driversByRaceId.get(raceId)) {
                Contestant__c contestant = new Contestant__c();
                contestant.Race__c = raceId;
                contestant.Driver__c = driverId;
                contestant.Car__c = cars[0].Id;
                uow.registerNew(contestant);                
            }            
        }       
 
        // Commit work
        uow.commitWork();
        
        return null;
    }	
    
	public Id runProcessDataJob()
	{
		// TODO: Implement concurrency check and scope config (via custom setting)
		return Database.executeBatch(new ProcessRaceDataJob(), 2000);	
	}    
    
	public void processData(Set<Id> raceDataIds)
	{
		// Query Race Data records and update with Contestant relationship
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		for(RaceData__c raceData : 
				(List<RaceData__c>)
					Application.Selector.selectById(raceDataIds))
		{
			// Associate Race Data record with a Contestant via Unique Id
			raceData.Contestant__r = 
				new Contestant__c(
					RaceDataId__c = 
						Contestants.makeRaceDataId(
							raceData.Year__c, 
							raceData.RaceName__c, 
							raceData.DriverId__c));
			uow.registerDirty(raceData);
		}
		// Update records
		uow.commitWork();
	}
        
	public List<RaceService.AnalysisResult> analizeData(Set<String> raceNames)
	{
		List<RaceData__c> raceData = 
			RaceDataSelector.newInstance().selectByRaceName(raceNames);			
		return null;
	}
}