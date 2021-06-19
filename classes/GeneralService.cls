public with sharing class GeneralService {

    static List<String> Permissions = new List<String>{'MapManagerBuilder'}; 

    /** 
     * mathod name : getPermissionSets
     * description: check users permission set - define access to builder tab
     * used by : tab holder
     */
    public static Boolean getPermissionSets(){
        List<PermissionSetAssignment> builderPermissions = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE Assignee.Id =:UserInfo.getUserId()  AND PermissionSet.Name IN: Permissions];
        if(!builderPermissions.isEmpty()){
            return true;
        }else{
            return false;
        }
    }

    /** 
     * mathod name : getLineWidth
     * description: check users permission set - define access to builder tab
     * used by : wizard tab
     */
    public static Integer getLineWidth(){
        FloorManager__mdt manager = [SELECT Line_Width__c FROM FloorManager__mdt WHERE MasterLabel = 'Settings'];
        return Integer.valueOf(manager.Line_Width__c);
    }

    /** 
     * mathod name : getDates
     * description: defines the available dates for days panel
     * used by : builder tab, wizard tab
     */
    public static Map<String,List<DateWrapper>> getDates(){
        
        Map<String,List<DateWrapper>> weeksNworkdays = new Map<String,List<DateWrapper>>();
        FloorManager__mdt manager = [SELECT First_is_Sunday__c,Friday__c,include_Holidays__c,Monday__c,NumOfWeeks__c,Saturday__c,Sunday__c,Thursday__c,Tuesday__c,Wednesday__c FROM FloorManager__mdt WHERE MasterLabel = 'Settings'];
        List<DateWrapper> dates = new List<DateWrapper>();

        Date startOfWeek =Date.Today().addDays(setStartofWeek(manager)).toStartOfWeek(); // start of week = MONDAY
        system.debug('startOfWeek '+startOfWeek);
        if(manager.First_is_Sunday__c){
            startOfWeek = startOfWeek.addDays(-1); // set to SUNDAY
        }
        Date me = Date.today();
        for(Date d = startOfWeek; d < startOfWeek.addDays((Integer.valueOf(manager.NumOfWeeks__c)*7)); d=d.addDays(1)){
            DateWrapper currentDate = new DateWrapper();

            Datetime thisDateTime = DateTime.newInstance(d.year(), d.month(), d.day());
            currentDate.currentDate = d;
            currentDate.dayName = thisDateTime.format('EEEE');
            currentDate.week = String.valueOf(Integer.valueOf(thisDateTime.format('w')));
            currentDate.isInactive = me >= d ? true : false;
            if(checkifDayisWorkday(currentDate.dayName,manager)){
                if(!weeksNworkdays.containsKey(currentDate.week)){
                    weeksNworkdays.put(currentDate.week,new List<DateWrapper>());
                }
                weeksNworkdays.get(currentDate.week).add(currentDate);
            }
        }
        
        return weeksNworkdays;
    }

    
    /** 
     * mathod name : setStartofWeek
     * description: helper method for getDates function, defines the start of the week according to the current date and
     *              the floor manager custom metadata configuration
     * used by : builder tab, wizard tab
     */
    public static integer setStartofWeek(FloorManager__mdt manager){
        Date thisDate = Date.Today();
        Datetime thisDateTime = DateTime.newInstance(thisDate.year(), thisDate.month(), thisDate.day());
        String dayOfWeek = thisDateTime.format('EEEE');
        Integer toStartofWeekFix = 0; // when using date.tostartofweek on sunday we get the last monday
        if(dayOfWeek.endsWithIgnoreCase('Sunday')){
            toStartofWeekFix=1;
        }

        system.debug('thisDate '+thisDate);
        system.debug('dayOfWeek '+dayOfWeek);
        //Boolean isWorkingDay = checkifDayisWorkday(, manager);

        if(manager.First_is_Sunday__c){
            if(dayOfWeek.equalsIgnoreCase('Friday') || dayOfWeek.equalsIgnoreCase('Saturday')){
                return 7+toStartofWeekFix;
            }else{
                return 0+toStartofWeekFix;
            }
        }else{
            if(dayOfWeek.equalsIgnoreCase('Saturday')){
                return 7+toStartofWeekFix;
            }else{
                return 0+toStartofWeekFix;
            }
        }
    }

    /** 
     * mathod name : checkifDayisWorkday
     * description: helper method for getDates function, check if day received is defined as a working day
     *              the floor manager custom metadata configuration
     * used by : builder tab, wizard tab
     */
    public static Boolean  checkifDayisWorkday(String DayName,FloorManager__mdt manager){
        switch on DayName {
            when 'Monday' {
                if(manager.Monday__c){ return true;
                }
            }
            when 'Tuesday' {
                if(manager.Tuesday__c){ return true;
                }
            }
            when 'Wednesday' {
                if(manager.Wednesday__c){ return true;
                }
            }
            when 'Thursday' {
                if(manager.Thursday__c){ return true;
                }
            }
            when 'Friday' {
                if(manager.Friday__c){ return true;
                }
            }
            when 'Saturday' {
                if(manager.Saturday__c){ return true;
                }
            }
            when 'Sunday' {
                if(manager.Sunday__c){ return true;
                }
            }
            when else { return false;
            }
        }
        return false;
    }
    
    /** 
     * mathod name : getSeatAttributes
     * description: returns list of seat attributes - picklist values
     * used by : builder tab, wizard tab
     */
    public static List<String> getSeatAttributes(){
        return getAttributes();
    }

    /** 
     * mathod name : getAttributes
     * description: returns list of seat attributes - picklist values
     * used by : builder tab, wizard tab
     */
    private static List<String> getAttributes(){
        List<String> attb = new List<String>();
        for(Schema.PicklistEntry myvalue :  Seat__c.Attributes__c.getDescribe().getPicklistValues()){
            attb.add(myvalue.getLabel());
        }
        return attb;
    }

    /** 
     * mathod name : getFloors
     * description: returns list of map records
     * used by : builder tab, wizard tab
     */
    public static List<Map__c> getFloors(){
        List<Map__c> maps = [SELECT Name,Map_Image__c FROM Map__c];
        return maps;
    }

    /** 
     * mathod name : getSeatByFloorAndCoords
     * description: return Seat record from coords and floor
     * used by : builder tab, wizard tab
     */
    public static Seat__c getSeatByFloorAndCoords(String cords,Id floor){
        Seat__c seat = [SELECT Id FROM Seat__c WHERE  Floor__c =: floor AND Coordinates__c=:cords Limit 1];
        return seat;
    }


    //// TIME SECTION ////
    /** 
     * mathod name : getMinuetsFromTimeFormat
     * description: calculates minutes from Midnight from time format
     * used by : wizard tab
     */
    public static Integer getMinuetsFromTimeFormat(String timeString){
        List<String> breakTime= timeString.split(':');
        return(Integer.valueOf(breakTime[0])*60 + Integer.valueOf(breakTime[1]));
    }

    /** 
     * mathod name : getTimeFormat
     * description: break minutes base time value to hour format
     * used by : wizard tab
     */
    public static String getTimeFormat(Integer totalMinutes){
        String Hours = String.valueOf(totalMinutes/60).LeftPad(2,'0');
        String Minutes = String.valueOf(totalMinutes-(Integer.valueOf(Hours)*60)).LeftPad(2,'0');
        return Hours+':'+Minutes+':00.000Z';
    }

    public static String getTimeFormatNoTZ(Integer totalMinutes){
        String Hours = String.valueOf(totalMinutes/60).LeftPad(2,'0');
        String Minutes = String.valueOf(totalMinutes-(Integer.valueOf(Hours)*60)).LeftPad(2,'0');
        return Hours+':'+Minutes;
    }

    /** 
     * mathod name : getTimeValue
     * description: return Time type value from minutes representation
     * used by : wizard tab
     */
    public static Time getTimeValue(Integer totalMinutes){
        Integer Hours = totalMinutes/60;
        Integer Minutes = totalMinutes-(Hours*60);
        return Time.newInstance(Hours,Minutes,0,0);
    }

    /** 
     * mathod name : getGeneralHours
     * description: retrive working hour defenition from the floor manager custom metadata configuration
     * used by : wizard tab
     */
    public static Map<Integer,HourWrapper> getGeneralHours(FloorManager__mdt manager){
        Map<Integer,HourWrapper> hours = new  Map<Integer,HourWrapper>();
        for(Decimal currTime = manager.Working_Hours_Start_Time__c; 
                            currTime<=manager.Working_Hours_End_Time__c; 
                                        currTime+=manager.Time_Step_Unit__c ){
            integer thisTimeMin = Integer.ValueOf(currTime);  
            hours.put(thisTimeMin,new HourWrapper(thisTimeMin));
        }
        return hours;
    }

    public class DateWrapper{
        @AuraEnabled
        public String dayName;
        @AuraEnabled
        public String week;
        @AuraEnabled
        public Date currentDate;
        @AuraEnabled
        public Date userDate = Date.Today();
        @AuraEnabled
        public Boolean isInactive = false;
    }
    
    public class SeatWrapper{
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Coordinates;
        @AuraEnabled
        public String CoordinatesCenter;
        @AuraEnabled
        public Decimal Width;
        @AuraEnabled
        public String Owner;
        @AuraEnabled
        public Boolean mySeat = false;
        @AuraEnabled
        public Boolean Occupied = false;
        @AuraEnabled
        public String Floor;
        @AuraEnabled
        public String Msg;
        @AuraEnabled
        public String Type;
        @AuraEnabled
        public List<String> Attributes;
        @AuraEnabled
        public String Neighborhood = '';
        @AuraEnabled
        public String NeighborhoodName = '';
    }

    public class DayEventsWrapper{
        @AuraEnabled public Date thisDate;
        @AuraEnabled public Id seatId;
        @AuraEnabled public List<EventWrapper> dayEvents;
        @AuraEnabled public Map<Integer,HourWrapper> availableHours;
        @AuraEnabled public Map<Integer,HourWrapper> takenHours;
        @AuraEnabled public Map<Integer,HourWrapper> generalHours;

        public DayEventsWrapper(Date thisDate, Id seatId){
            this.thisDate = thisDate;
            this.seatId =seatId;
        }
    }

    public class EventWrapper{
        @AuraEnabled public Date thisDate;
        @AuraEnabled public Time_Reservation__c eventReservation;
        @AuraEnabled public String userName;
        @AuraEnabled public Map<Integer,HourWrapper> workingTime;
    }

    public class dayEventsRes{
        @AuraEnabled public Map<Integer,HourWrapper> availableHours;
        @AuraEnabled public Map<Integer,HourWrapper> takenHours;
        @AuraEnabled public List<EventWrapper> dayEvents;
    }

    public class HourWrapper{
        @AuraEnabled public Integer minutes;
        @AuraEnabled public String timeFormat;
        @AuraEnabled public String timeLabel;
        @AuraEnabled public String userName;
        @AuraEnabled public Boolean takenByMe;
        public HourWrapper(Integer minutes){
            this.minutes = minutes;
            this.timeFormat = getTimeFormat(minutes); 
            this.timeLabel = this.timeFormat.removeEnd(':00.000Z'); 
        }

        public HourWrapper(Integer minutes, String userName, Boolean takenByMe){
            this.minutes = minutes;
            this.timeFormat = getTimeFormat(minutes); 
            this.timeLabel = this.timeFormat.removeEnd(':00.000Z'); 
            this.userName = userName;
            this.takenByMe = takenByMe;
        }
    }
}