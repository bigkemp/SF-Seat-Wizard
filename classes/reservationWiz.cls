public with sharing class reservationWiz {
    static List<String> Permissions = new List<String>{'MapManagerBuilder'}; 

    /// COMMON AND GENERAL METHODS ///

        /** 
         * mathod name : getPermissionSets
         * description: check users permission set - define access to builder tab
         * used by : tab holder
         */
        @AuraEnabled(cacheable=true)
        public static Boolean getPermissionSets(){
            try {   
                return GeneralService.getPermissionSets();
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }

        
        /// FLOOR SELECTION ///
    
        /** 
         * mathod name : getFloors
         * description: returns list of map records
         * used by : builder tab, wizard tab
         */
        @AuraEnabled
        public static List<Map__c> getFloors(){
            try {   
                return GeneralService.getFloors();
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            } 
        }
        
        @AuraEnabled
        public static void updateFloors(Id floor, Decimal newHeight,Decimal newWidth){
            try { 
                GeneralService.updateFloor(floor, newHeight, newWidth);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            } 
        }
        /// CANVAS DEFINITION ///

        /** 
         * mathod name : getLineWidth
         * description: check users permission set - define access to builder tab
         * used by : wizard tab, builder tab
         */
        @AuraEnabled(cacheable=true)
        public static Integer getLineWidth(){
            try {   
                return GeneralService.getLineWidth();
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }

        /// DATE WEEK PANNEL ///

        /** 
         * mathod name : getDates
         * description: defines the available dates for days panel
         * used by : builder tab, wizard tab
         */
        @AuraEnabled
        public static Map<String,List<GeneralService.DateWrapper>> getDates(){
            try {   
                return GeneralService.getDates();
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            } 
        }

        /// SEAT CREATE / EDIT MODAL ///

        /** 
         * mathod name : getNeighborhoods
         * description: returns list of Neighborhood records
         * used by : builder tab, wizard tab
         */
        @AuraEnabled(cacheable=true)
        public static List<Neighborhood__c> getNeighborhoods(){
            try {   
                return BuilderService.getNeighborhoods();
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            } 
        }

        /** 
         * mathod name : getSeatAttributes
         * description: returns list of seat attributes - picklist values
         * used by : builder tab, wizard tab
         */
        @AuraEnabled(cacheable=true)
        public static List<String> getSeatAttributes(){
            try {   
                return GeneralService.getSeatAttributes();
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            } 
        }

        /** 
         * mathod name : getSeatType
         * description: returns list of seat types - picklist values
         * used by : builder tab
         */
        @AuraEnabled(cacheable=true)
        public static List<String> getSeatType(){
            try {   
                return BuilderService.getSeatType();
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            } 
        }

    /// SEARCH METHODS ///

        /** 
         * mathod name : searchWorker
         * description: returns list of searched workers in the floor that selected date - search functionality
         * used by : wizard tab
         */
        @AuraEnabled
        public static List<String> searchWorker(String WorkerId,Date day,Id floor){
            try {
                return SeatService.searchWorker(WorkerId,day,floor);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }

        /** 
         * mathod name : searchWorkerAllDates
         * description: returns list of searched workers in the floor all dates - search functionality
         * used by : wizard tab
         */
        @AuraEnabled
        public static Map<String,List<String>> searchWorkerAllDates(String WorkerId,Id floor){
            try {   
                return SeatService.searchWorkerAllDates(WorkerId,floor);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }

    /// SEAT RESRVATION METHODS ///

        /** 
         * mathod name : getAvailableSeats
         * description: returns list of SeatWrapper from seat and related seat reservations
         * used by : wizard tab
         */
        @AuraEnabled
        public static List<GeneralService.SeatWrapper> getAvailableSeats(Date day,Id floor){
            try {   
                return SeatService.getAvailableSeats(day,floor);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            } 
        }

        /** 
         * mathod name : getAllOccupiedSeatsOnSpecificDay
         * description: returns list of SeatWrapper of seat reservations for a specific day and floor
         * used by : wizard tab
         */
        @AuraEnabled
        public static List<GeneralService.SeatWrapper> getAllOccupiedSeatsOnSpecificDay(Date day,Id floor){
            try {   
                return SeatService.getAllOccupiedSeatsOnSpecificDay(day,floor);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            } 
        }

        /// SEAT MODAL SELECTION AND ACTIONS ///

        /** 
         * mathod name : availableSeatDates
         * description: returns list of avaialable dates the for multi resevation functunality
         * used by : wizard tab
         */
        @AuraEnabled
        public static List<Date> availableSeatDates(String Cords,Id floor){ 
            try {   
                return SeatService.availableSeatDates(Cords,floor);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            } 
        }

        /** 
         * mathod name : TakeSeat
         * description: create Seat Reservation record for the running user on seat for specific date
         * used by : wizard tab
         */
        @AuraEnabled
        public static Boolean TakeSeat(String SeatName,Date day,Id floor){
            try {   
                return SeatService.TakeSeat(SeatName,day,floor);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }

        /** 
         * mathod name : TakeSeatMulti
         * description: create Seat Reservation / Time Reservation records multi selection functionality
         * used by : wizard tab
         */
        @AuraEnabled
        public static Boolean TakeSeatMulti(String SeatName,String availableDates,Id floor,String seatType,String availableHours){
            try {   
                return SeatService.TakeSeatMulti(SeatName,availableDates,floor,seatType,availableHours);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }

        /** 
         * mathod name : freeSeat
         * description: deletes seat reservation under the user for that specific date
         * used by : wizard tab
         */
        @AuraEnabled
        public static Boolean freeSeat(Date day){
            try {   
                return SeatService.freeSeat(day);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }

    /// BUILDER SEAT METHODS ///

        /** 
         * mathod name : saveNewSeats
         * description: save seat records
         * used by : builder tab
         */
        @AuraEnabled
        public static String saveNewSeats(String Json,String floorMap){
            try {   
                return BuilderService.saveNewSeats(Json,floorMap);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }

        /// SEAT MODAL SETTINGS AND ACTIONS ///

        /** 
         * mathod name : deleteSeat
         * description: deletes seat by coords and floor
         * used by : builder tab
         */
        @AuraEnabled
        public static Boolean deleteSeat(String cords,Id floor){
            try {   
                return BuilderService.deleteSeat(cords, floor);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }

        /** 
         * mathod name : updateSeatByCords
         * description: updates seat by coords and floor, with receieved attributes
         * used by : builder tab
         */
        @AuraEnabled
        public static Boolean updateSeatByCords(String cords,Id floor, String changes){
            try {   
                return BuilderService.updateSeatByCords(cords, floor, changes);
            }catch(DMLException e){
                String msg = e.getDmlMessage(0);
                if(msg.containsIgnoreCase('duplicat') && msg.containsIgnoreCase('Key__c')){ msg = 'Duplicate seat name for the same floor';
                }
                throw new AuraHandledException(msg);
            }catch(Exception e){ throw new AuraHandledException(e.getMessage());
            }
        }

        /** 
         * mathod name : updateSeatCords
         * description: updates seat record relaying seat coords before change
         * used by : builder tab
         */
        @AuraEnabled
        public static string updateSeatCords(String floor, String  oldCords, String newCords){
            try {
                return BuilderService.updateSeatCords(floor,oldCords,newCords);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }

    /// TIME HEIRARCEY METHODS ///

        /** 
         * mathod name : getHierarchyCoWorkers
         * description: returns hierarchy of all users under the running user
         * used by : wizard tab
         */
        @AuraEnabled
        public static Map<Integer, List<SeatService.HierarchyWorkerDetail>> getHierarchyCoWorkers(){
            try {   
                return SeatService.getHierarchyCoWorkers();
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }

    /// TIME RESERVETION METHODS ///

        /** 
         * mathod name : getDayEvents
         * description: retrive day seat time reservations
         * used by : wizard tab
         */
        @AuraEnabled
        public static GeneralService.DayEventsWrapper getDayEvents(Date thisDate, String cords,Id floor){
            try {   
                return SeatService.getDayEvents(thisDate, cords, floor);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }

        /** 
         * mathod name : saveTimeReservation - currently not in use
         * description: creates time reservation record on a specific day, time and seat
         * used by : wizard tab
         */

        @AuraEnabled
        public static String saveTimeReservation(Date thisDate, Id seat, Integer startTime, Integer endTime){
            try {   
                return SeatService.saveTimeReservation(thisDate, seat, startTime, endTime);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }

        /** 
         * mathod name : freeTimeReservation - currently not in use
         * description: deletes time reservation record on a specific day, time and seat (coords + floor)
         * used by : wizard tab
         */
        @AuraEnabled
        public static void freeTimeReservation(Date thisDate, Integer myHour, String seat, Id floor){
            try {   
                SeatService.freeTimeReservation(thisDate, myHour, seat, floor);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }
}