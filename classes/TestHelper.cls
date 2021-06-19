public with sharing class TestHelper {


    public static Map__c returnFloorMap(String floorName){
        Map__c m  = new Map__c(Name = floorName, Map_Image__c=URL.getSalesforceBaseUrl().toExternalForm()+'maps/'+floorName);
        return m;
    }

    // public static Neighborhood_Coordinates__c returnNeighborhoodCoords(String ncName, Id mapId ){
    //     return new Neighborhood_Coordinates__c(Name = ncName, Map__c = mapId);
    // }

    public static Neighborhood__c returnNeighborhood(String nName ){
        return new Neighborhood__c(Name = nName);
    }

    public static Seat__c returnSeat(String Coordinates, String name, Id nId, Id mapId ){
        return new Seat__c(Coordinates__c = Coordinates, Name = name, Neighborhood__c = nId, Floor__c = mapId);
    }

    public static Seat_Reservation__c returnSeat(Date Reservation_Date, Id Worker, Id seatId){
        DateTime dt = DateTime.newInstance(Reservation_Date.year(),Reservation_Date.month(),Reservation_Date.day());
        return returnSeatDT(dt, Worker, seatId);
    }

    public static Seat_Reservation__c returnSeatDT(DateTime dt, Id Worker, Id seatId){
        return new Seat_Reservation__c(Reservation_Date__c = dt.Date(),	Week__c = dt.format('w'), User__c = Worker, Seat__c = seatId);
    }

    public static void makeData(){
        List<String> types = reservationWiz.getSeatType();

        List<Map__c> mapList = new List<Map__c>();
        for(Integer i =0; i<3; i++){
            mapList.add(returnFloorMap('Floor Map'+i));
        }
        insert mapList;


        List<Neighborhood__c> nList = new List<Neighborhood__c>();
        nList.add(returnNeighborhood('test1'));
        nList.add(returnNeighborhood('test2'));
        insert nList;

        List<Seat__c> seatList = new List<Seat__c>();
        Integer j =0;
        for(Neighborhood__c nc : nList){
            Id MapId = mapList[j].Id;
            for(Integer i =0; i<types.size(); i++){
                seatList.add(returnSeat( getCoords(i), nc.name+' Seat '+(i+1), nc.Id, MapId) );
                seatList[seatList.size()-1].Type__c = types[i];
                if(types[i].containsIgnoreCase('Permanent')){
                    seatList[seatList.size()-1].Worker__c = UserInfo.getUserId();
                }
            }
            j++;
        }
        insert seatList;
    }

    public static String getCoords(Integer i){
        return i==0?'0,0,10,0,10,10,10,0':'10,0,20,0,20,10,10,10';
    }
}