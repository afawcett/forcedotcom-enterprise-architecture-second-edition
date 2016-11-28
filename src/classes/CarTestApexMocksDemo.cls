@IsTest
private class CarTestApexMocksDemo {
    
    @IsTest
    private static void whenCarStartCalledDashboardAndEngineInitialised() {
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        // Given
        Dashboard mockDashboard = (Dashboard) mocks.factory(Dashboard.class);
        Engine mockEngine = (Engine) mocks.factory(Engine.class);
        mocks.startStubbing();
        mocks.when(mockEngine.isRunning()).thenReturn(true);
        mocks.stopStubbing();

        // When        
        Car car = new Car(mockEngine, mockDashboard);
        car.start();

        // Then
        System.assertEquals(true, car.isRunning());
        ((Dashboard) mocks.verify(mockDashboard, 1)).initialise();
        ((Engine) mocks.verify(mockEngine, 1)).start();        
    }    
}