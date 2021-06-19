public with sharing class SeatService {
    /** 
     * mathod name : getAvailableSeats
     * description: returns list of SeatWrapper from seat and related seat reservations
     * used by : wizard tab
     */
    public static List<GeneralService.SeatWrapper> getAvailableSeats(Date day,Id floor){
        List<GeneralService.SeatWrapper> coors = new List<GeneralService.SeatWrapper>();
        List<GeneralService.SeatWrapper> emptySeatscoors = new List<GeneralService.SeatWrapper>();
        Boolean foundMe = false;
        
        for (Seat__c coor : [SELECT id, (SELECT Id, Reservation_Date__c, Seat__c,User__c,User__r.Name, Week__c FROM Seat_Reservations__r WHERE Reservation_Date__c =: day),
                                Width_Label__c, Coordinates__c, Floor__c,CoordinatesCenter__c, Neighborhood__c, Neighborhood__r.Name, Worker__r.Name, Name,Attributes__c,Type__c FROM 
                                    Seat__c WHERE Floor__c =: floor]) {
            GeneralService.SeatWrapper currentSeat = new GeneralService.SeatWrapper();
            currentSeat.Name = coor.Name;
            currentSeat.Id = coor.Id;
            currentSeat.CoordinatesCenter = coor.CoordinatesCenter__c;
            currentSeat.Coordinates = coor.Coordinates__c;
            if(coor.Neighborhood__c != null){
                currentSeat.Neighborhood = coor.Neighborhood__c;
                currentSeat.NeighborhoodName = coor.Neighborhood__r.Name;
            }
            currentSeat.Width = coor.Width_Label__c;
            currentSeat.Type = coor.Type__c;
            if(currentSeat.Type =='Non Reservable'){
                currentSeat.Occupied = true;
                currentSeat.Owner = 'Non Reservable';
            }
            if(currentSeat.Type =='Permanent'){
                currentSeat.Occupied = true;
                currentSeat.Owner = coor.Worker__c != null ? coor.Worker__r.Name : 'Free';
            }
            if(!String.isBlank(coor.Attributes__c)){
                currentSeat.Attributes = coor.Attributes__c.split(';');
            }else{
                currentSeat.Attributes = new List<String>();
            }
            if(coor.Type__c == 'Daily' && coor.Seat_Reservations__r.isEmpty()){
                emptySeatscoors.add(currentSeat);
            }else if(coor.Type__c == 'Daily' && !coor.Seat_Reservations__r.isEmpty()){
                currentSeat.mySeat = coor.Seat_Reservations__r[0].User__c == UserInfo.getUserId();
                currentSeat.Occupied = true;
                currentSeat.Owner = coor.Seat_Reservations__r[0].User__r.Name;
                coors.add(currentSeat);
                if(currentSeat.mySeat){
                    foundMe = true;
                }
            }else{
                coors.add(currentSeat);
            }
        }
        if(!foundMe && !emptySeatscoors.isEmpty()){
            coors.addAll(emptySeatscoors);
        }
        return coors;
    }

    /** 
     * mathod name : getAllOccupiedSeatsOnSpecificDay
     * description: returns list of GeneralService.SeatWrapper of seat reservations for a specific day and floor
     * used by : wizard tab
     */
    public static List<GeneralService.SeatWrapper> getAllOccupiedSeatsOnSpecificDay(Date day,Id floor){
        List<GeneralService.SeatWrapper> coors = new List<GeneralService.SeatWrapper>();
        
        for (Seat__c coor : [SELECT id, (SELECT Id, Reservation_Date__c, Seat__c,User__c,User__r.Name, Week__c FROM Seat_Reservations__r WHERE Reservation_Date__c =: day),
                                 Coordinates__c, Floor__c,CoordinatesCenter__c, Neighborhood__c, Neighborhood__r.Name, Worker__r.Name, Name FROM 
                                    Seat__c WHERE Floor__c =: floor]) {
            GeneralService.SeatWrapper currentSeat = new GeneralService.SeatWrapper();
            currentSeat.Name = coor.Name;
            if(!coor.Seat_Reservations__r.isEmpty()){
                currentSeat.Coordinates = coor.Coordinates__c;
                currentSeat.Occupied = true;
                currentSeat.CoordinatesCenter = coor.CoordinatesCenter__c;
                currentSeat.Owner = coor.Seat_Reservations__r[0].User__r.Name;
                coors.add(currentSeat);
            }
        }
        return coors;
    }

    /** 
     * mathod name : availableSeatDates
     * description: returns list of avaialable dates the for multi resevation functunality
     * used by : wizard tab
     */
    public static List<Date> availableSeatDates(String Cords,Id floor){     
        FloorManager__mdt manager = [SELECT First_is_Sunday__c,Friday__c,include_Holidays__c,Monday__c,NumOfWeeks__c,Saturday__c,Sunday__c,Thursday__c,Tuesday__c,Wednesday__c FROM FloorManager__mdt WHERE MasterLabel = 'Settings'];
        // Date startOfWeek = Date.today().toStartOfWeek();
        Date startOfWeek =Date.Today().addDays(GeneralService.setStartofWeek(manager)).toStartOfWeek(); // start of week = MONDAY

        List<Date> availableDates = new List<Date>();
        List<Date> finalOpenDates = new List<Date>();
        List<Date> unavailableDates = new List<Date>();

        Set<Date> hasResDates = new Set<Date>();
        for(SeatService.SeatResrvation myres : mySeatReservationsCtrl.getMyReservations()){
            hasResDates.add(myres.thisDate);
        }

        if(manager.First_is_Sunday__c){
            startOfWeek = startOfWeek.addDays(-1);
        }
        Date me = Date.today();
        for(integer i = 0; i < (Integer.valueOf(manager.NumOfWeeks__c)*7); i++ ){
            if(i != 0){
                startOfWeek = startOfWeek.addDays(1);
            }
            if(hasResDates.contains(startOfWeek)){
                continue;
            }
            GeneralService.DateWrapper currentDate = new GeneralService.DateWrapper();
            Datetime thisDateTime = DateTime.newInstance(startOfWeek.year(), startOfWeek.month(), startOfWeek.day());
            currentDate.currentDate = startOfWeek;
            currentDate.dayName = thisDateTime.format('EEEE');
            currentDate.week = thisDateTime.format('w');
            currentDate.isInactive = me > startOfWeek ? true : false;
            if(GeneralService.checkifDayisWorkday(currentDate.dayName,manager)){
                if(!currentDate.isInactive){
                    availableDates.add(startOfWeek);
                }
            }
        }

        for (Seat__c coor : [SELECT id, (SELECT Id, Reservation_Date__c, Seat__c,User__c,User__r.Name, Week__c FROM Seat_Reservations__r WHERE Reservation_Date__c IN:availableDates),
                                 Coordinates__c, Floor__c, Neighborhood__c, Neighborhood__r.Name, Worker__r.Name, Name FROM 
                                    Seat__c WHERE Floor__c =: floor AND Coordinates__c =:Cords ]) {
            // SeatWrapper currentSeat = new SeatWrapper();
            // currentSeat.Name = coor.Name;
            if(coor.Seat_Reservations__r.isEmpty()){
                return availableDates;
            }else{
                for (Seat_Reservation__c resDate  : coor.Seat_Reservations__r) {
                    unavailableDates.add(resDate.Reservation_Date__c);
                }
            }
        }
        for (Date openDate : availableDates) {
            if(!unavailableDates.contains(openDate)){
                finalOpenDates.add(openDate);
            }
        }
        return finalOpenDates;
    }

    //// SEARCH SECTION ////    
    
    /** 
     * mathod name : searchWorker
     * description: returns list of searched workers in the floor that selected date - search functionality
     * used by : wizard tab
     */
    public static List<String> searchWorker(String WorkerId,Date day,Id floor){
        List<Seat__c> foundSeats = new List<Seat__c>();
        for (Seat__c coor : [SELECT id, (SELECT Id, Reservation_Date__c, Seat__c,User__c,User__r.Name, Week__c FROM Seat_Reservations__r WHERE Reservation_Date__c =:day AND User__c =: WorkerId),
                                 Coordinates__c, Floor__c, Neighborhood__c, Neighborhood__r.Name, Worker__r.Name, Name FROM 
                                    Seat__c WHERE Floor__c =: floor]) {
            if(!coor.Seat_Reservations__r.isEmpty()){
                foundSeats.add(coor);
            }
        }
        if(foundSeats.size() == 1){
            return new List<String>{foundSeats[0].Coordinates__c};
        }else{
            return null;
        }
    }

    /** 
     * mathod name : searchWorkerAllDates
     * description: returns list of searched workers in the floor all dates - search functionality
     * used by : wizard tab
     */
    public static Map<String,List<String>> searchWorkerAllDates(String WorkerId,Id floor){
        List<String> workersDates = new List<String>();
        Map<String,List<String>> workerSeats = new Map<String,List<String>>();
        for (Seat__c coor : [SELECT id, (SELECT Id, Reservation_Date__c, Seat__c,User__c,User__r.Name, Week__c 
                                            FROM Seat_Reservations__r 
                                                WHERE (User__c =: WorkerId) AND (Reservation_Date__c >= TODAY) ),
                                 Coordinates__c, Floor__c, Neighborhood__c, Neighborhood__r.Name, Worker__r.Name, Name FROM 
                                    Seat__c WHERE Floor__c =: floor]) {
            system.debug(coor);
            system.debug(coor.Seat_Reservations__r.isEmpty());
            if(coor.Seat_Reservations__r.isEmpty()){
                
            }else{
                for (Seat_Reservation__c reserversion : coor.Seat_Reservations__r) {
                    if(!workerSeats.containsKey(coor.Name)){
                        workerSeats.put(coor.Name,new List<String>());
                    }
                    workerSeats.get(coor.Name).add(String.valueOf(reserversion.Reservation_Date__c));
                }
            }
        }
        if(workerSeats.isEmpty()){
            return null;
        }else{
            return workerSeats;
        }
    }

    //// DATE RESERVATION SECTION ////


    /** 
     * mathod name : TakeSeat
     * description: create Seat Reservation record for the running user on seat for specific date
     * used by : wizard tab
     */
    public static Boolean TakeSeat(String SeatName,Date day,Id floor){
        Seat__c Seat = [SELECT id, (SELECT Id, Reservation_Date__c, Seat__c, Week__c FROM Seat_Reservations__r WHERE Reservation_Date__c =: day),
        Coordinates__c, Floor__c, Neighborhood__c, Neighborhood__r.Name, Worker__r.Name, Name FROM 
           Seat__c WHERE Floor__c =: floor AND Name=:SeatName LIMIT 1];

        if(Seat.Seat_Reservations__r.isEmpty()){
            Seat_Reservation__c  myseat = new Seat_Reservation__c();
            myseat.Seat__c = Seat.id;
            myseat.Reservation_Date__c = day;
            myseat.Name = Seat.Name;
            myseat.User__c = UserInfo.getUserId();
            insert myseat;
        }
        return true;
    }

    /** 
     * mathod name : TakeSeatMulti
     * description: create Seat Reservation / Time Reservation records multi selection functionality
     * used by : wizard tab
     */
    public static Boolean TakeSeatMulti(String SeatName,String availableDates,Id floor,String seatType,String availableHours){

        system.debug(availableDates);
        if(seatType == 'Daily'){
            List<Date> searchableDates = new List<Date>();
            for (String openDate : availableDates.split(',')) {
                searchableDates.add(Date.valueOf(openDate));
            }
            system.debug(searchableDates);
            Seat__c Seat = [SELECT id, (SELECT Id, Reservation_Date__c, Seat__c, Week__c FROM Seat_Reservations__r WHERE Reservation_Date__c IN: searchableDates),
            Coordinates__c, Floor__c, Neighborhood__c, Neighborhood__r.Name, Worker__r.Name, Name FROM 
               Seat__c WHERE Floor__c =: floor AND Name=:SeatName LIMIT 1];
            List<Seat_Reservation__c> reservations = new List<Seat_Reservation__c>();
            if(Seat.Seat_Reservations__r.isEmpty()){
                for (String openDate : availableDates.split(',')) {
                    Seat_Reservation__c  myseat = new Seat_Reservation__c();
                    myseat.Seat__c = Seat.id;
                    myseat.Reservation_Date__c = Date.valueOf(openDate);
                    myseat.Name = Seat.Name;
                    myseat.User__c = UserInfo.getUserId();
                    reservations.add(myseat);
                }
            }
            insert reservations;
        }else if(seatType == 'Hourly'){
            Date todays = Date.valueOf(availableDates);
            Seat__c Seat = [SELECT id, Coordinates__c, Floor__c, Neighborhood__c, 
                            Neighborhood__r.Name, Worker__r.Name, Name FROM 
                            Seat__c WHERE Floor__c =: floor AND Name=:SeatName LIMIT 1];
            List<Time_Reservation__c> reservations = new List<Time_Reservation__c>();
                List<String> arrayHours = availableHours.split(',');
                for (String hours : arrayHours) {
                    Integer startHour = (Integer.valueOf(hours.split ('-')[0].split(':')[0]));
                    Integer startMin = (Integer.valueOf(hours.split('-')[0].split(':')[1]));
                    Integer endHour = (Integer.valueOf(hours.split('-')[1].split(':')[0]));
                    Integer endMin = (Integer.valueOf(hours.split('-')[1].split(':')[1]));
                    Time myTimeS = Time.newInstance(startHour, startMin, 0, 0);
                    Time myTimeE = Time.newInstance(endHour, endMin, 0, 0);
                    Time_Reservation__c  myseat = new Time_Reservation__c();
                    myseat.Seat__c = Seat.id;
                    myseat.StartTime__c = myTimeS;
                    myseat.EndTime__c = myTimeE;
                    myseat.Date__c = todays;
                    myseat.StartTime_Min__c = startHour*60+startMin;
                    myseat.EndTime_Min__c = endHour*60+endMin;
                    myseat.Name = Seat.Name;
                    myseat.User__c = UserInfo.getUserId();
                    reservations.add(myseat);
                }
                insert reservations;
            }
            return true;
    }

    /** 
     * mathod name : freeSeat
     * description: deletes seat reservation under the user for that specific date
     * used by : wizard tab
     */
    @AuraEnabled
    public static Boolean freeSeat(Date day){
        delete [SELECT Id FROM Seat_Reservation__c WHERE Reservation_Date__c =: day AND User__c =:UserInfo.getUserId()];
        return true;
    }

    //// TIME RESERVATION SECTION ////

    /** 
     * mathod name : getDayEvents
     * description: retrive day seat time reservations
     * used by : wizard tab
     */
    public static GeneralService.DayEventsWrapper getDayEvents(Date thisDate, String cords,Id floor){
        system.debug('thisDate'+thisDate);
        Seat__c seat = GeneralService.getSeatByFloorAndCoords(cords,floor);
        system.debug('seat'+seat);
        return getDayEventsHelper(thisDate, seat.Id);
    }

    /** 
     * mathod name : getDayEventsHelper
     * description: retrive day seat time reservations
     * used by : wizard tab
     */
    private static GeneralService.DayEventsWrapper getDayEventsHelper(Date thisDate, Id seat){
        GeneralService.DayEventsWrapper dew = new GeneralService.DayEventsWrapper(thisDate, seat);
        List<Time_Reservation__c> tr = [SELECT Id, StartTime__c, StartTime_Min__c, EndTime__c, EndTime_Min__c, Date__c, Seat__c, User__c, User__r.Name
                                            FROM Time_Reservation__c
                                                WHERE Date__c =: thisDate AND Seat__c =: Seat];

        FloorManager__mdt manager = [SELECT Working_Hours_End_Time__c, Working_Hours_Start_Time__c, Time_Step_Unit__c FROM FloorManager__mdt WHERE MasterLabel = 'Settings'];
        dew.generalHours = GeneralService.getGeneralHours(manager);
        dew.dayEvents = getDayEventsProcessed(tr,dew.generalHours,manager).dayEvents;
        dew.takenHours = getDayEventsProcessed(tr,dew.generalHours,manager).takenHours;
        dew.availableHours = getDayEventsProcessed(tr,dew.generalHours,manager).availableHours;
        system.debug(JSON.serialize(dew));
        return dew;
    }

    /** 
     * mathod name : getDayEventsProcessed
     * description: retrive day seat time reservations helper method
     * used by : wizard tab
     */
    private static GeneralService.DayEventsRes getDayEventsProcessed(List<Time_Reservation__c> tr, Map<Integer, GeneralService.HourWrapper> generalHours, FloorManager__mdt manager){
        GeneralService.DayEventsRes der = new GeneralService.DayEventsRes();
        List<GeneralService.EventWrapper> ewl = new List<GeneralService.EventWrapper>();
        Map<Integer, GeneralService.HourWrapper> takenHours = new Map<Integer, GeneralService.HourWrapper>();
        Map<Integer, GeneralService.HourWrapper> freeHours = generalHours;
        for(Time_Reservation__c hour : tr){
            GeneralService.EventWrapper ew = new GeneralService.EventWrapper();
            String username = hour.User__c != null? hour.User__r.Name : 'N/A';
            Boolean takenByMe = hour.User__c == userInfo.getUserId() ? true : false;

            ew.eventReservation = hour;
            ew.thisDate = hour.Date__c;
            ew.userName = username;
            ew.workingTime = new Map<Integer,GeneralService.HourWrapper>();
            for(Decimal currTime = hour.StartTime_Min__c; 
                                currTime<hour.EndTime_Min__c; 
                                                currTime = currTime+manager.Time_Step_Unit__c ){
                                                    
                integer thisTimeMin = Integer.ValueOf(currTime);  
                takenHours.put(thisTimeMin, new GeneralService.HourWrapper(thisTimeMin, username, takenByMe));
                ew.workingTime.put(thisTimeMin, new GeneralService.HourWrapper(thisTimeMin, username, takenByMe));
                freeHours.remove(thisTimeMin);
            }
            ewl.add(ew);
        }
        der.dayEvents = ewl;
        der.availableHours = freeHours;
        der.takenHours = takenHours;
        return der;
    }

    /** 
     * mathod name : saveTimeReservation - currently not in use
     * description: creates time reservation record on a specific day, time and seat
     * used by : wizard tab
     */
    public static String saveTimeReservation(Date thisDate, Id seat, Integer startTime, Integer endTime){
        Time_Reservation__c tr = new Time_Reservation__c();
        tr.Seat__c = seat;
        tr.Date__c = thisDate;
        tr.StartTime__c = GeneralService.getTimeValue(startTime);
        tr.StartTime_Min__c = startTime;
        tr.EndTime__c = GeneralService.getTimeValue(startTime);
        tr.EndTime_Min__c = endTime;
        insert tr;
        return 'success';
    }

    /** 
     * mathod name : freeTimeReservation - currently not in use
     * description: deletes time reservation record on a specific day, time and seat (coords + floor)
     * used by : wizard tab
     */
    public static void freeTimeReservation(Date thisDate, Integer myHour, String seat, Id floor){
        Seat__c st = GeneralService.getSeatByFloorAndCoords(seat,floor);
        delete [SELECT Id FROM Time_Reservation__c WHERE Seat__c =: st.Id AND Date__c=:thisDate AND StartTime_Min__c =:myHour Limit 1];
    }

    //// HIERARCHY SECTION ////

    /** 
     * mathod name : getHierarchyCoWorkers
     * description: returns hierarchy of all users under the running user
     * used by : wizard tab
     */
    public static Map<Integer, List<HierarchyWorkerDetail>> getHierarchyCoWorkers(){
        Map<Integer, List<HierarchyWorkerDetail>> mymap = new Map<Integer, List<HierarchyWorkerDetail>>();
        Map<Integer, Set<Id>> mapHierarchy = getHierarchy().userByLevel;
        Map<Id, Set<Id>> usersByDirectManager = getHierarchy().usersByDirectManager;
        Map<Id, User> Allusers = getHierarchy().Allusers;// all users under current user
        Map<Id, Integer> userToLevel = getHierarchy().userToLevel;// all users under current user
        system.debug(mapHierarchy);
        //for (Integer position : mapHierarchy.keySet()) {
        for(Integer position :mapHierarchy.keySet()){
            mymap.put(position,new List<HierarchyWorkerDetail>());
        }

        Map<String,List<HierarchyReservation>> coworkermaps = new Map<String,List<HierarchyReservation>>();
        Map<Id,List<HierarchyReservation>> coworkermaps2 = new Map<Id,List<HierarchyReservation>>();

        for(Id userId : Allusers.keySet()){
            if(!coworkermaps2.containsKey(userId)){
                coworkermaps2.put(userId,new List<HierarchyReservation>());
            }
        }

        for (Seat_Reservation__c seat :[SELECT Id, Reservation_Date__c, Seat__r.Floor__r.Name,Seat__r.Name,User__c,User__r.Name, Week__c 
                            FROM Seat_Reservation__c WHERE (User__c IN: Allusers.keySet()) AND (Reservation_Date__c >= TODAY)]) 
        {
            if(!coworkermaps2.containsKey(seat.User__c)){
                coworkermaps2.put(seat.User__c,new List<HierarchyReservation>());
            }
            HierarchyReservation reserve = new HierarchyReservation();
            reserve.Seat = seat.Seat__r.Name;
            reserve.Floor = seat.Seat__r.Floor__r.Name;
            reserve.resDate = seat.Reservation_Date__c;
            reserve.UserName = seat.User__r.Name;
            coworkermaps2.get(seat.User__c).add(reserve);
        }

        system.debug('userToLevel '+userToLevel);
        for (Id userId : coworkermaps2.keySet()) {
            HierarchyWorkerDetail WorkerDetail = new HierarchyWorkerDetail();
            WorkerDetail.Name = Allusers.get(userId).Name;
            WorkerDetail.Reservations = coworkermaps2.get(userId);
            system.debug('518 userId '+userId);
            Integer position = userToLevel.get(userId);
            mymap.get(position).add(WorkerDetail);
        }
        return mymap;
    }

    /** 
     * mathod name : getHierarchy
     * description: getHierarchyCoWorkers helper method
     * used by : wizard tab
     */
    public static HierarchyWrap getHierarchy(){
        FloorManager__mdt manager = [SELECT Hierarchy_Depth__c FROM FloorManager__mdt WHERE MasterLabel = 'Settings'];
        Integer Depth = Integer.valueOf(manager.Hierarchy_Depth__c);
        Map<Integer, Set<Id>> userByLevel = new Map<Integer, Set<Id>>();
        Set<id> users = new Set<Id>();
        users.add(userInfo.getUserId());
        Map<id, User> Allusers = new Map<id, User>();
        Map<id, Integer> userToLevel = new Map<id, Integer>();
        Map<id, Set<id>> usersByDirectManager = new Map<id, Set<id>>();

		for(Integer iteration=0; iteration<Depth ; iteration=iteration+3){
            Set<id> usersTemp = new Set<Id>();  
            Decimal relativeQueries = Limits.getQueries()*100/Limits.getLimitQueries();
            system.debug('relativeQueries '+relativeQueries); // ensuring we not using too many queries in current transaction
            if(relativeQueries > 50 && iteration>2){
                system.debug('broken');
                break; // if we did at list 1 iteration and found that we passed 50 queries in current transaction
                        // we stop querieng for Hierarchy 
            }
            if(users.isEmpty() ){ 
                system.debug('Hierarchy ended');
                break; // no users? i.e no more Hierarchy to query                                                                         
            }else{
                for(user u : [SELECT Name, UserName, Id, Manager.Name, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.Profile.Name FROM User WHERE 
                                                                                    ( (ManagerId in:users) OR
                                                                                        (Manager.ManagerId in:users) OR 
                                                                                            (Manager.Manager.ManagerId in:users))]){
                    if(users.contains(u.ManagerId)){
                        if(!userByLevel.containsKey(iteration)){
                            userByLevel.put(iteration, new Set<Id>());
                        }
                        userByLevel.get(iteration).add(u.Id);
                        userToLevel.put(u.Id,iteration);                    
                    }

                    else if(users.contains(u.Manager.ManagerId)){
                        if(!userByLevel.containsKey(iteration+1)){
                            userByLevel.put(iteration+1, new Set<Id>());
                        }
                        userByLevel.get(iteration+1).add(u.Id);
                        userToLevel.put(u.Id,iteration+1);                    

                    }else if(users.contains(u.Manager.Manager.ManagerId)){
                        if(!userByLevel.containsKey(iteration+2)){
                            userByLevel.put(iteration+2, new Set<Id>());
                        }
                        userByLevel.get(iteration+2).add(u.Id);
                        usersTemp.add(u.Id);
                        userToLevel.put(u.Id,iteration+2);                    
                    }
                    Allusers.put(u.Id, u);

                    if(!usersByDirectManager.containsKey(u.ManagerId)){
                        usersByDirectManager.put(u.ManagerId, new Set<Id>());
                    }
                    usersByDirectManager.get(u.ManagerId).add(u.Id);
                }
            }
            users = usersTemp;
        }

        HierarchyWrap hw = new HierarchyWrap();
        hw.userByLevel = userByLevel;
        hw.userToLevel = userToLevel;
        hw.Allusers = Allusers;
        hw.usersByDirectManager = usersByDirectManager;
        return hw;
    }

    
    //// My SEAT RESERVATION SECTION //// 


    /**getMyReservations
     * retrives all of the user reservations of current day and forward
     * returns seat reservation wrapper list
     * used by My Seat Reservations tab
     */
    public static List<SeatResrvation> getMyReservations(){
        List<SeatResrvation> myRes= new List<SeatResrvation>();
        for(Seat_Reservation__c sr : [SELECT Id, Reservation_Date__c, Seat__c,  Seat__r.name, Seat__r.Floor__r.name, User__c,User__r.Name, Week__c 
                                        FROM Seat_Reservation__c 
                                            WHERE (User__c =: UserInfo.getUserId()) AND (Reservation_Date__c >= TODAY) ORDER BY Reservation_Date__c ASC]){
            myRes.add(new SeatResrvation(sr));
        }
        return myRes;
    }


    /**RemoveSeatResrvation
     * delete seat reservation by Id
     * used by My Seat Reservations tab - remove button
     */
    public static string RemoveSeatResrvation (String recordid){
        delete new Seat_Reservation__c(Id = recordid);
        return 'success';
    }

    /**getMyTimeReservations
     * retrives all of the user reservations of current day and forward
     * returns seat reservation wrapper list
     * used by My Seat Reservations tab
     */
    public static List<SeatTimeResrvation> getMyTimeReservations(){
        List<SeatTimeResrvation> myRes= new List<SeatTimeResrvation>();
        for(Time_Reservation__c sr : [SELECT Id, Date__c, Seat__c,  Seat__r.name, Seat__r.Floor__r.name, User__c,User__r.Name, StartTime__c, EndTime__c, StartTime_MIN__c, EndTime_MIN__c  
                                        FROM Time_Reservation__c 
                                            WHERE (User__c =: UserInfo.getUserId()) AND (Date__c >= TODAY) ORDER BY Date__c ASC]){
            myRes.add(new SeatTimeResrvation(sr));
        }
        return myRes;
    }


    /**RemoveSeatTimeResrvation
     * delete seat reservation by Id
     * used by My Seat Reservations tab - remove button
     */
    public static string RemoveSeatTimeResrvation (String recordid){
        system.debug('recordid '+recordid);
        delete new Time_Reservation__c(Id = recordid);
        return 'success';
    }

    //// WRAPPER CLASSES

    public class SeatTimeResrvation{
        @AuraEnabled public Id id ;
        @AuraEnabled public string name;
        @AuraEnabled public string dDate;
        @AuraEnabled public string cardName;
        @AuraEnabled public string floor;
        @AuraEnabled public string day;
        @AuraEnabled public string week;
        @AuraEnabled public Date thisDate;
        @AuraEnabled public String startTime;
        @AuraEnabled public String endTime;

        public SeatTimeResrvation (Time_Reservation__c tr){
            this.thisDate = tr.Date__c;
            DateTime dt = DateTime.newInstance(tr.Date__c.year(), tr.Date__c.month(), tr.Date__c.day());
            this.id = tr.Id;
            this.name = tr.Seat__r.name;
            this.dDate = dt.format('dd/MM/yyyy');
            this.day = dt.format('EEEE');
            this.floor = tr.Seat__r.Floor__r.name;
            this.week = dt.format('w');
            this.cardName = this.day+' '+this.dDate; 
            this.startTime = GeneralService.getTimeFormatNoTZ(Integer.ValueOf(tr.StartTime_MIN__c));
            this.endTime = GeneralService.getTimeFormatNoTZ(Integer.ValueOf(tr.EndTime_MIN__c));
        }
    }

    public class SeatResrvation{
        @AuraEnabled public Id id ;
        @AuraEnabled public string name;
        @AuraEnabled public string dDate;
        @AuraEnabled public string cardName;
        @AuraEnabled public string floor;
        @AuraEnabled public string day;
        @AuraEnabled public string week;
        @AuraEnabled public Date thisDate;

        public SeatResrvation (Seat_Reservation__c sr){
            this.thisDate = sr.Reservation_Date__c;
            DateTime dt = DateTime.newInstance(sr.Reservation_Date__c.year(), sr.Reservation_Date__c.month(), sr.Reservation_Date__c.day());
            this.id = sr.Id;
            this.name = sr.Seat__r.name;
            this.dDate = dt.format('dd/MM/yyyy');
            this.day = dt.format('EEEE');
            this.floor = sr.Seat__r.Floor__r.name;
            this.week = dt.format('w');
            this.cardName = this.day+' '+this.dDate;
        }
    }

    public class HierarchyWrap{
        public Map<Integer, Set<Id>> userByLevel;
        public Map<Id, Integer> userToLevel;
        public Map<Id, User> Allusers;
        public Map<Id, Set<Id>> usersByDirectManager;
    }

    
    public class HierarchyWorkerDetail{
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public List<HierarchyReservation> Reservations;
    }

    public class HierarchyReservation{
        @AuraEnabled
        public String UserName;
        @AuraEnabled
        public String Seat;
        @AuraEnabled
        public String Floor;
        @AuraEnabled
        public Date resDate;
    }
}