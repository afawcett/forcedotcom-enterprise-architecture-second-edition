public class Contestants extends ApplicationDomain {

	public Contestants(List<Contestant__c> contestants) {
		super(contestants);
	}

    /** 
     * Performas validation on insert of new Contestants
     **/
	public override void onValidate() {	    
		// Bulk load the associated races
		Set<Id> raceIds = new Set<Id>();
		for(Contestant__c contestant : (List<Contestant__c>) Records) {
            raceIds.add(contestant.Race__c);		    
		}
		Map<Id, Race__c> associatedRaces = 
			new Map<Id, Race__c>(new RacesSelector().selectById(raceIds));

		// Only permit new contestants to be added to Scheduled races, unless they have race position or DNF (aka historic data load)
		for(Contestant__c contestant : (List<Contestant__c>) Records) {
			Race__c race = associatedRaces.get(contestant.Race__c);
			if(race.Status__c != 'Scheduled' && contestant.RacePosition__c == null && contestant.DNF__c != true) {
                contestant.addError( 'Contestants can only be added to scheduled races');			    
			}
		}
	}

	/**
	 * Performs validation on update of existing Contestants
	 **/
	public override void onValidate(Map<Id,SObject> existingRecords) {	    
		// Bulk load the associated races
		Map<Id, Race__c> associatedRaces = queryAssociatedRaces();
		// Can only change drivers in scheduled races
		for(Contestant__c contestant : (List<Contestant__c>) Records) {			
			Race__c contestantRace = associatedRaces.get(contestant.Race__c);
			Contestant__c oldContestant  = (Contestant__c) existingRecords.get(contestant.Id);
			if(contestantRace.Status__c != 'Scheduled' && 
			   contestant.Driver__c !=  oldContestant.Driver__c) {
                contestant.Driver__c.addError( 'You can only change drivers for scheduled races' );			       
            }
		}
	}

    /**
     * Awards the applicable championship points to the contestants
     **/
	public void awardChampionshipPoints(fflib_ISObjectUnitOfWork uow)
	{
		// Custom implementation configured by Developer X?
		Object registeredInterfaceImpl = 
		    Application.Callouts.newInstance(ContestantService.IAwardChampionshipPoints.class);
		if(registeredInterfaceImpl instanceof ContestantService.IAwardChampionshipPoints) {
			// Cast the interface to call the calculate method
			ContestantService.IAwardChampionshipPoints awardChampionshipPoints = 
				(ContestantService.IAwardChampionshipPoints) registeredInterfaceImpl;
			// Invoke the custom method from Developer X
			awardChampionshipPoints.calculate(Records);
			// Mark dirty on behalf of Developer X
			for(Contestant__c contestant : (List<Contestant__c>) Records) {
                uow.registerDirty(contestant);			    
			}
			return;
		}

        // Continue with standard implementation...
        
        // Apply championship points to given contestants
        Map<Integer, ChampionshipPoint__mdt> pointsByTrackPosition = 
          new ChampionshipPointsSelector().selectAllByTrackPosition();      
        for(Contestant__c contestant : (List<Contestant__c>) Records) {
            // Determine points to award for the given position
            ChampionshipPoint__mdt pointsForPosition = 
                pointsByTrackPosition.get(Integer.valueOf(contestant.RacePosition__c));
            if(pointsForPosition!=null) {
                // Apply points and register for udpate with uow
                contestant.ChampionshipPoints__c = pointsForPosition.PointsAwarded__c;
                uow.registerDirty(contestant);
            }
        }       
	}
	
	/** 
	 * Calculate the Contestants RaceDataId__c
	 **/
	public override void onBeforeInsert() {
		// Query Drivers related to Contestant records
		Map<Id, Driver__c> driversById = 
			new Map<Id, Driver__c>((List<Driver__c>)
				Application.Selector.selectByRelationship(
					Records, Contestant__c.Driver__c));

		// Query Races related to Contestant records
		Map<Id, Race__c> racesById = queryAssociatedRaces();

		// Calculate each unique Contestants Race Data Id
		for(Contestant__c contestant : (List<Contestant__c>) Records) {		
			Race__c race = racesById.get(contestant.Race__c);
			Driver__c driver = driversById.get(contestant.Driver__c);
			contestant.RaceDataId__c = makeRaceDataId(race.Year__c, race.Name, driver.DriverId__c); 
		}		
	}

	public static String makeRaceDataId(Decimal year, String raceName, String driverId) {
		return makeRaceDataId(String.valueOf(year), raceName, driverId);
	}

	public static String makeRaceDataId(String year, String raceName, String driverId) {
		return year+'-'+raceName+'-'+driverId;
	}

	private Map<Id, Race__c> queryAssociatedRaces() {
		// Bulk load the associated races
		Set<Id> raceIds = new Set<Id>();
		for(Contestant__c contestant : (List<Contestant__c>) Records) {
            raceIds.add(contestant.Race__c);		    
		}			
		return new Map<Id, Race__c>(new RacesSelector().selectById(raceIds));		
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable {
		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new Contestants(sObjectList);
		}
	}	
}