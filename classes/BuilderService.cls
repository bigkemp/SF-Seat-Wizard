public with sharing class BuilderService {

    /** 
     * mathod name : saveNewSeats
     * description: save seat records
     * used by : builder tab
     */
    public static String saveNewSeats(String Json,String floorMap){
        List<NewSeatFromUI> newSeats = (List<NewSeatFromUI>) System.JSON.deserialize(Json, List<NewSeatFromUI>.class);
        List<Seat__c> myseats = new List<Seat__c>();
        List<GeneralService.SeatWrapper> noNameseats = new List<GeneralService.SeatWrapper>();
        for (NewSeatFromUI seat : newSeats) {
            Seat__c seatObj = new Seat__c();
            seatObj.Floor__c = floorMap;
            if(!String.isBlank(seat.PermanentOwnerId)){
                seatObj.Worker__c = seat.PermanentOwnerId;
            }
            seatObj.Name = seat.Name;
            seatObj.Key__c = seatObj.Floor__c+'~'+seat.Name;
            if(!String.isBlank(seat.Neighborhood)){
                seatObj.Neighborhood__c = seat.Neighborhood;
            }
            if(!String.isBlank(seat.Type)){
                seatObj.Type__c = seat.Type;
            }
            if(seat.Attributes != null && !seat.Attributes.isEmpty()){
                seatObj.Attributes__c = String.join(seat.Attributes,';');
            }
            seatObj.Coordinates__c = String.join(seat.Coord,',');
            seatObj.CoordinatesCenter__c = getCenterAndWidth(seat.Coord)[0];
            seatObj.Width_Label__c = Decimal.valueOf(getCenterAndWidth(seat.Coord)[1]);
            if(seatObj.Name !=null && !String.isBlank(seatObj.Name)){
                myseats.add(seatObj);
            }else{
                GeneralService.SeatWrapper sw = new GeneralService.SeatWrapper();
                sw.Coordinates = seatObj.Coordinates__c;
                sw.Floor = seatObj.Floor__c;
                sw.Name = seatObj.name;
                sw.Msg = 'No Name Defined';
                noNameseats.add(sw);
            }
        }
        List<GeneralService.SeatWrapper> failedSeats = new List<GeneralService.SeatWrapper>();
        Integer i =0;
        for(database.saveresult sr: database.insert(myseats, false)){
            if(!sr.isSuccess()){
                Seat__c s = myseats.get(i);
                GeneralService.SeatWrapper sw = new GeneralService.SeatWrapper();
                sw.Coordinates = s.Coordinates__c;
                sw.Floor = s.Floor__c;
                sw.Name = s.name;
                for(Database.Error err : sr.getErrors()) {
                    String msg = err.getMessage();
                    if(msg.containsIgnoreCase('duplicat') && msg.containsIgnoreCase('Key__c')){
                        sw.Msg = 'Duplicate seat name for the same floor';
                    }else{
                        sw.Msg = msg;
                    }
                    break;
                }
                failedSeats.add(sw) ;
            }
            i++;
        }

        failedSeats.addAll(noNameseats);
        system.debug(failedSeats);
        if(failedSeats.isEmpty()){
            return 'success';
        }else{
            return system.JSON.serialize(failedSeats);
        }
    }

    /** 
     * mathod name : getCenterAndWidth
     * description: overloading - calculates center and width of shape for text display on canvas
     *              part of the save seat process
     * used by : builder tab
     */
    private static List<string> getCenterAndWidth(String coords){
        return getCenterAndWidth((List<Double>) JSON.deserialize(coords, List<Double>.class));
    }

    /** 
     * mathod name : getCenterAndWidth
     * description: overloading - calculates center and width of shape for text display on canvas
     *              part of the save seat process
     * used by : builder tab
     */
    private static List<string> getCenterAndWidth(List<Double> coords){

        boolean isItX = true;
        Integer minX = 0;
        Integer maxX = 0;
        Integer minY = 0;
        Integer maxY = 0;
        for (Double Coordi : coords) {
            Integer Coord=Integer.valueOf(Coordi);
            if(isItX){
                isItX = false;
                if (minX > Coord || minX == 0) {
                    minX = Coord;
                }
                if (maxX < Coord) {
                    maxX = Coord;
                }
            }else{
                isItX = true;
                if (minY > Coord || minY == 0) {
                    minY = Coord;
                }
                if (maxY < Coord) {
                    maxY = Coord;
                }
            }
        }
        system.debug(maxY);
        system.debug(minY);
        system.debug(maxX);
        system.debug(minX);
        integer valueforX = ((maxX - minX)/2)+minX;
        integer valueforY = ((maxY - minY)/2)+minY;
        List<String> res = new List<String>();
        res.add(valueforX+','+ valueforY);
        res.add(''+(maxX-minX));
        return res;
    }

    /** 
     * mathod name : getNeighborhoods
     * description: returns list of Neighborhood records
     * used by : builder tab
     */
    public static List<Neighborhood__c> getNeighborhoods(){
        return [SELECT id,Name FROM Neighborhood__c];
    }

    /** 
     * mathod name : getSeatType
     * description: returns list of seat types - picklist values
     * used by : builder tab
     */
    public static List<String> getSeatType(){
        return getType();
    }

    /** 
     * mathod name : getType
     * description: returns list of seat types - picklist values
     * used by : builder tab
     */
    private static List<String> getType(){
        List<String> types = new List<String>();
        for(Schema.PicklistEntry myvalue :  Seat__c.Type__c.getDescribe().getPicklistValues()){
            types.add(myvalue.getLabel());
        }
        return types;
    }

    /** 
     * mathod name : updateSeatCords
     * description: updates seat record relaying seat coords before change
     * used by : builder tab
     */
    public static string updateSeatCords(String floor, String  oldCords, String newCords){
        Seat__c seat = [Select Id From Seat__c Where Coordinates__c =: oldCords Limit 1];
        seat.Coordinates__c = newCords;
        seat.CoordinatesCenter__c = getCenterAndWidth('['+seat.Coordinates__c+']')[0];
        seat.Width_Label__c = Decimal.valueOf(getCenterAndWidth('['+seat.Coordinates__c+']')[1]);
        update seat;
        return 'success';
    }

    /** 
     * mathod name : deleteSeat
     * description: deletes seat by coords and floor
     * used by : builder tab
     */
    public static Boolean deleteSeat(String cords,Id floor){
        delete GeneralService.getSeatByFloorAndCoords(cords,floor);
        return true;
    }

    /** 
     * mathod name : updateSeatByCords
     * description: updates seat by coords and floor, with receieved attributes
     * used by : builder tab
     */
    public static Boolean updateSeatByCords(String cords,Id floor, String changes){
        Seat__c seat = GeneralService.getSeatByFloorAndCoords(cords,floor);
        Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(changes);
        if(!String.isBlank((String)meta.get('Name'))){
            seat.name = (String)meta.get('Name');
            seat.Key__c = floor+'~'+seat.Name;
        }
        if(!String.isBlank((String)meta.get('Type'))){
            seat.Type__c = (String)meta.get('Type');
        }
        if(!String.isBlank((String)meta.get('Neighborhood'))){
            // seat.Neighborhood__c = [SELECT id FROM Neighborhood__c WHERE Name =:(String)meta.get('Neighborhood') LIMIT 1 ].id;
            seat.Neighborhood__c = (String)meta.get('Neighborhood');
        }
        if(!String.isBlank((String)meta.get('OwnerId'))){
            // seat.Neighborhood__c = [SELECT id FROM Neighborhood__c WHERE Name =:(String)meta.get('Neighborhood') LIMIT 1 ].id;
            seat.Worker__c = (String)meta.get('OwnerId');
        }
        List<Object> newAttrs = (List<Object>)meta.get('Attributes');
        if(!newAttrs.isEmpty()){
            List<String> finale = new List<String>();
            for (Object newAttr : newAttrs) {
                finale.add((String)newAttr);
            }
            seat.Attributes__c = String.join(finale,';');
        }
        update seat;
        return true;
    }

    public class NewSeatFromUI{
        public String Name;
        public List<Double> Coord;
        public String Type;
        public String Neighborhood;
        public List<String> Attributes;
        public String PermanentOwnerId;
    }
}