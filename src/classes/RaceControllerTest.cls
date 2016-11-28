@isTest
private class RaceControllerTest {
    	
	@isTest static void testAwardPoints() {
		SeasonService.importSeasons(TestData.asJSON());
		new RaceController(
			new ApexPages.StandardController(
				[select Id from Race__c LIMIT 1])).awardPoints();
	}
	
	@IsTest
	private static void whenAwardPointsCalledIdPassedToService() {
	    
	    fflib_ApexMocks mocks = new fflib_ApexMocks();
	    	    
	    // Given
	    RaceServiceImpl mockService = (RaceServiceImpl) mocks.factory(RaceServiceImpl.class);
	    Application.Service.setMock(RaceService.class, mockService);
	    
	    // When
	    Id raceId = fflib_IDGenerator.generate(Race__c.SObjectType);
	    RaceController raceController = 
	       new RaceController(
	           new ApexPages.StandardController(
	               new Race__c(Id = raceId)));
	    raceController.awardPoints();
	    
	    // Then
	    ((RaceServiceImpl) mocks.verify(mockService, 1)).awardChampionshipPoints(new Set<Id> { raceId });
	}
}