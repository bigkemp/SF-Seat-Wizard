import { LightningElement, api } from 'lwc';
import removeSeat from "@salesforce/apex/mySeatReservationsCtrl.RemoveSeatResrvation";
import removeTime from "@salesforce/apex/mySeatReservationsCtrl.RemoveSeatTimeResrvation";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class SeatReservationCard extends LightningElement {
    @api recid
    @api date
    @api floor
    @api name
    @api coords
    @api cardName
    @api startTime
    @api endTime
    @api myIcon

    remove(event){
        var seat = event.target.dataset.recid;
        if(this.startTime){
            removeTime({recordid:seat})
            .then((res) =>{
                this.dispatchEvent(new CustomEvent('refreshseating'));
            })
            .catch((err) => {
                this.showToast("Error","Something went wrong.","error");
                console.log(err);
            })
        }else{
            removeSeat({recordid:seat})
            .then((res) =>{
                this.dispatchEvent(new CustomEvent('refreshseating'));
            })
            .catch((err) => {
                this.showToast("Error","Something went wrong.","error");
                console.log(err);
            })
        }
    }

    showToast(mytitle, mymessage, variant) {
        const event = new ShowToastEvent({
            title: mytitle,
            message: mymessage,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}