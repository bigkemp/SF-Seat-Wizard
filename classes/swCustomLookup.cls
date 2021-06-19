public with sharing class swCustomLookup {
    @AuraEnabled(cacheable=true)
    public static List<User> getCustomLookupUser (String usrName){
       List<User> usrLookupList =  new List<User>();
       if(usrName != ''){
           String userName = '%' + usrName + '%';
           usrLookupList = [Select Name,Email From User Where Name like:userName];
           return usrLookupList;
       }
       return usrLookupList;
    }
}