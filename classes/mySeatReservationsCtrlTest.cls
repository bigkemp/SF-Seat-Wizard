@isTest
public with sharing class mySeatReservationsCtrlTest {

    @TestSetup
    static void makeData(){
        TestHelper.makeData();
    }

    @isTest
    public static void mySeatReservationsCtrlTest() {
        List<Seat__c> seats =  [SELECT Id, Name, Coordinates__c, Neighborhood__c, Type__c, Floor__c FROM Seat__c WHERE Type__c='Daily'];
        List<Seat__c> hourlySeats =  [SELECT Id, Name, Coordinates__c, Type__c, Neighborhood__c, Floor__c FROM Seat__c WHERE Type__c='Hourly'];
        Date dt = Date.Today().toStartOfWeek().addDays(9);
        reservationWiz.TakeSeatMulti(seats[0].Name, String.valueOf(dt)+','+String.valueOf(dt), seats[0].Floor__c, seats[0].Type__c,'');
        reservationWiz.TakeSeatMulti(hourlySeats[0].Name,String.valueOf(dt)+','+String.valueOf(dt),hourlySeats[0].Floor__c, hourlySeats[0].Type__c, '09:00-10:00');
        List<SeatService.SeatResrvation> seatRes = mySeatReservationsCtrl.getMyReservations();
        mySeatReservationsCtrl.getMyTimeReservations();
        List<Seat_Reservation__c> sr = [SELECT Id FROM Seat_Reservation__c];
        List<Time_Reservation__c> tr = [SELECT Id, Seat__r.name, Date__c, Seat__r.Floor__r.name, Seat__r.Floor__c, StartTime_MIN__c, EndTime_MIN__c FROM Time_Reservation__c];
        SeatService.SeatTimeResrvation str = new SeatService.SeatTimeResrvation(tr[0]);
        mySeatReservationsCtrl.RemoveSeatResrvation(sr[0].Id);
        mySeatReservationsCtrl.RemoveSeatTimeResrvation(tr[0].Id);
        try{
            mySeatReservationsCtrl.RemoveSeatResrvation(sr[0].Id);
        }catch(Exception e){}
        try{
            mySeatReservationsCtrl.RemoveSeatTimeResrvation(tr[0].Id);
        }catch(Exception e){}
    }
}