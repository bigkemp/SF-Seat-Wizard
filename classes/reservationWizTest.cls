@isTest
public with sharing class reservationWizTest {
    
    @TestSetup
    static void makeData(){
        TestHelper.makeData();
    }

    @isTest
    public static void reservationWizTest() {
        List<Seat__c> seats =  [SELECT Id, Name, Coordinates__c, Neighborhood__c, Type__c, Floor__c FROM Seat__c WHERE Type__c='Daily'];
        List<Seat__c> hourlySeats =  [SELECT Id, Name, Coordinates__c, Type__c, Neighborhood__c, Floor__c FROM Seat__c WHERE Type__c='Hourly'];
        BuilderService.NewSeatFromUI res = new BuilderService.NewSeatFromUI();
        res.Coord = (List<Double>)JSON.deserialize('['+seats[0].Coordinates__c+',7,7]',List<Double>.class);
        res.Name =  seats[0].Name+' v2';
        system.debug(JSON.Serialize(res));
        reservationWiz.saveNewSeats('['+JSON.Serialize(res)+']', seats[0].Floor__c);
        Map<String,List<GeneralService.DateWrapper>> maps = reservationWiz.getDates();
        reservationWiz.getFloors();
        Date dt = Date.Today().toStartOfWeek().addDays(2);
        List<GeneralService.SeatWrapper> sw = reservationWiz.getAvailableSeats(dt, seats[0].Floor__c);
        List<Date> datesList = reservationWiz.availableSeatDates(seats[0].Coordinates__c, seats[0].Floor__c);
        reservationWiz.searchWorker(UserInfo.getUserId(), dt,seats[0].Floor__c);
        reservationWiz.searchWorkerAllDates(UserInfo.getUserId(), seats[0].Floor__c);

        reservationWiz.TakeSeat(seats[0].Name, dt, seats[0].Floor__c);
        List<GeneralService.SeatWrapper> sw2 = reservationWiz.getAvailableSeats(dt, seats[0].Floor__c);
        List<Date> datesList2 = reservationWiz.availableSeatDates(seats[0].Coordinates__c, seats[0].Floor__c);

        reservationWiz.searchWorker(UserInfo.getUserId(), dt,seats[0].Floor__c);
        reservationWiz.searchWorkerAllDates(UserInfo.getUserId(), seats[0].Floor__c);

        //, String.join(res.Coords,','), 
        reservationWiz.freeSeat(dt);
        reservationWiz.deleteSeat( String.join(res.Coord,','), seats[0].Floor__c);

        List<Date> dates = new List<Date>();
        dates.add(dt);
        dates.add(dt.addDays(1));
        reservationWiz.TakeSeatMulti(seats[0].Name, String.valueOf(dt)+','+String.valueOf(dt.addDays(1)), seats[0].Floor__c, seats[0].Type__c,'');
        reservationWiz.TakeSeatMulti(hourlySeats[0].Name,String.valueOf(dt)+','+String.valueOf(dt.addDays(1)),hourlySeats[0].Floor__c, hourlySeats[0].Type__c, '09:00-10:00');
        reservationWiz.getHierarchyCoWorkers();
        reservationWiz.getPermissionSets();
        reservationWiz.getLineWidth();
        reservationWiz.getAllOccupiedSeatsOnSpecificDay(dt, seats[0].Floor__c);
        reservationWiz.getSeatAttributes();
        List<String> types = reservationWiz.getSeatType();
        List<Neighborhood__c> neighs = reservationWiz.getNeighborhoods();
        reservationWiz.getDayEvents( dates[0], hourlySeats[0].Coordinates__c ,hourlySeats[0].Floor__c);
        Map<String,String> seatUpdate = new Map<String,String>{'Name'=> seats[0].Name, 'Type'=> seats[0].Type__c, 'Neighborhood'=> neighs[0].Id, 'OwnerId'=> UserInfo.getUserId()};
        try{
            GeneralService.getTimeFormatNoTZ(600);
            GeneralService.getMinuetsFromTimeFormat('09:00:00T');
            reservationWiz.updateSeatCords(seats[0].Floor__c, seats[0].Coordinates__c,seats[0].Coordinates__c);
            reservationWiz.saveTimeReservation(dates[0].addDays(5), hourlySeats[0].Id, 660, 720);
            SeatService.getMyTimeReservations();
            List<Date> datesListHourly = reservationWiz.availableSeatDates(hourlySeats[0].Coordinates__c, hourlySeats[0].Floor__c);
            reservationWiz.freeTimeReservation(dates[0].addDays(5), 660, hourlySeats[0].Coordinates__c, hourlySeats[0].Floor__c);
            reservationWiz.updateSeatByCords(seats[0].Coordinates__c,seats[0].Floor__c,JSON.serialize((Object)seatUpdate));
        }catch(Exception e){
            system.debug(e.getStackTraceString());
        }

        List<User> ul = [Select Id, ManagerId, Name FROM USER WHERE ManagerId != null AND isActive = TRUE AND Manager.isActive =TRUE Limit 1];
        if(!ul.isEmpty()){
            reservationWiz.TakeSeatMulti(seats[0].Name, String.valueOf(dt.toStartOfWeek().addDays(10))+','+String.valueOf(dt.toStartOfWeek().addDays(9)), seats[0].Floor__c, seats[0].Type__c,'');
            List<Seat_Reservation__c> srl = [SELECT Id FROM Seat_Reservation__c Limit 2];
            srl[0].User__c = ul[0].Id;
            srl[1].User__c = ul[0].ManagerId;
            update srl;

            System.runAs(new User(Id=ul[0].ManagerId)) {
                reservationWiz.getHierarchyCoWorkers();
            }
        }
        try{
            reservationWiz.saveNewSeats('['+JSON.Serialize(res)+']', seats[0].Floor__c);  // simulate duplication name and floor      
            reservationWiz.saveNewSeats('['+JSON.Serialize(res)+']', seats[0].Floor__c);  // simulate duplication name and floor      
        }catch(Exception e){}
        try{
            res.Name= null;
            reservationWiz.saveNewSeats('['+JSON.Serialize(res)+']', seats[0].Floor__c); // no name
        }catch(Exception e){}
    }
}