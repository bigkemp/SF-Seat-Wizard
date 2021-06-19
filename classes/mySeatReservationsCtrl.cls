public with sharing class mySeatReservationsCtrl {

    //// DAY RESERVATIONS////

        /**getMyReservations
         * retrives all of the user reservations of current day and forward
         * returns seat reservation wrapper list
         * used by My Seat Reservations tab
         */
        @AuraEnabled
        public static List<SeatService.SeatResrvation> getMyReservations(){
            try {
                return SeatService.getMyReservations();
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }


        /**RemoveSeatResrvation
         * delete seat reservation by Id
         * used by My Seat Reservations tab - remove button
         */
        @AuraEnabled
        public static string RemoveSeatResrvation (String recordid){
            try {
                return SeatService.RemoveSeatResrvation(recordid);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }

    //// TIME RESERVATIONS////

        /**getMyTimeReservations
         * retrives all of the user reservations of current day and forward
         * returns seat reservation wrapper list
         * used by My Seat Reservations tab
         */
        @AuraEnabled
        public static List<SeatService.SeatTimeResrvation> getMyTimeReservations(){
            try {
                return SeatService.getMyTimeReservations();
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }


        /**RemoveSeatTimeResrvation
         * delete seat reservation by Id
         * used by My Seat Reservations tab - remove button
         */
        @AuraEnabled
        public static string RemoveSeatTimeResrvation (String recordid){
            try {
                return SeatService.RemoveSeatTimeResrvation(recordid);
            } catch (Exception e) { throw new AuraHandledException(e.getMessage());
            }
        }
}