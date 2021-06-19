import { LightningElement, track, wire,api } from 'lwc';
import getCustomLookupUser from '@salesforce/apex/swCustomLookup.getCustomLookupUser';

export default class SwCustomLookup extends LightningElement {

@track userName='';
@api title='';
 @track userEmail='';
 @track userList=[];
 @track objectApiName='User';
 @track userId;
 @track isShow=false;
 @track messageResult=false;
 @track isShowResult = true;
 @track showSearchedValues = false;
 @wire(getCustomLookupUser,{usrName:'$userName'})
 retrieveUsers ({error,data}){
     this.messageResult=false;
     if(data){
         if(data.length>0 && this.isShowResult){
            this.userList =data;
            this.showSearchedValues=true;
            this.messageResult=false;
         }
         else if(data.length == 0){
            this.userList=[];
            this.showSearchedValues=false;
            if(this.userName != ''){
               this.messageResult=true;
            }
         }
         else if(error){
             this.accountId='';
             this.userName='';
             this.userList=[];
             this.showSearchedValues=false;
             this.messageResult=true;
         }

     }
 }



 searchHandleClick(event){
  this.isShowResult = true;
  this.messageResult = false;
}


searchHandleKeyChange(event){
  this.messageResult=false;
  this.userName = event.target.value;
}

parentHandleAction(event){        
    this.showSearchedValues = false;
    this.isShowResult = false;
    this.messageResult=false;
    //Set the parent calendar id
    this.userId =  event.target.dataset.value;
    //Set the parent calendar label
    this.userName =  event.target.dataset.label;      
    this.userEmail =  event.target.dataset.email;      
    let userRecord = {name:this.userName , userId: this.userId}
    const selectedEvent = new CustomEvent('selected', { detail: userRecord });
        // Dispatches the event.
    this.dispatchEvent(selectedEvent);    
}
}