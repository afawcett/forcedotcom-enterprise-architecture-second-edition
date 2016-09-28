public with sharing class RaceStandingsComponentController {

    @AuraEnabled
    public static List<RaceStanding> getStandings() {
        List<RaceStanding> raceStandings = new List<RaceStanding>();
        for(ContestantsSelector.Standing standing : new ContestantsSelector().selectStandingsForCurrentSeason()) {
            RaceStanding raceStanding = new RaceStanding();
            raceStanding.Position = standing.Position;
            raceStanding.Driver = standing.Driver;
            raceStanding.Team = standing.Team;
            raceStanding.Wins = standing.Wins;
            raceStanding.Points = standing.Points;
            raceStandings.add(raceStanding);
        }
        return raceStandings;
    }    
    
    public class RaceStanding {
        @AuraEnabled
        public Integer Position;
        @AuraEnabled
        public String Driver;
        @AuraEnabled
        public String Team;
        @AuraEnabled
        public Integer Wins;
        @AuraEnabled
        public Integer Points;
    }
}