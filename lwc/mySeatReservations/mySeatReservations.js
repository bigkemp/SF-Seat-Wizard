import { LightningElement, track, api } from 'lwc';
import getMyDailyReservations from "@salesforce/apex/mySeatReservationsCtrl.getMyReservations";
import getMyHourlyAvailableSeats from "@salesforce/apex/mySeatReservationsCtrl.getMyTimeReservations";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class MySeatReservations extends LightningElement {
    @track myDaysByWeek=[];
    @track myHoursByWeek=[];
    @api byWeek = false;
    hasDayReservations = false;
    hasTimeReservations = false;
    loaded = true;

    async connectedCallback(){
        this.startLoading();
        await this.refreshMySeats();
        this.endLoading();
    }

    async getSeats(){
        this.myDaysByWeek=[]
        getMyDailyReservations({})
        .then((res) =>{
            this.hasDayReservations = res.length > 0 ? true : false;
            const output = res.reduce((seat, a) => ((seat[a.week] = seat[a.week] || []).push(a), seat), {});
            for (const [key, value] of Object.entries(output)) {
                if(key && key!='' && key!= undefined && value.length>0 && value)
                    this.myDaysByWeek.push({key:'Week '+key,value:value});
            }         
        })
        .catch((err) => {
            this.showToast("Error","Something went wrong.","error");
            console.log(err);
        })
    }

    async getHours(){
        this.myHoursByWeek=[]
        getMyHourlyAvailableSeats({})
        .then((res) =>{
            this.hasTimeReservations = res.length > 0 ? true : false;
            const output = res.reduce((seat, a) => ((seat[a.week] = seat[a.week] || []).push(a), seat), {});
            for (const [key, value] of Object.entries(output)) {
                if(key && key!='' && key!= undefined && value.length>0 && value)
                    this.myHoursByWeek.push({key:'Week '+key,value:value});
            }         
        })
        .catch((err) => {
            this.showToast("Error","Something went wrong.","error");
            console.log(err);
        })
    }


    showToast(mytitle, mymessage, variant) {
        const event = new ShowToastEvent({
            title: mytitle,
            message: mymessage,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    startLoading(){
        this.loaded = false;
    }

    endLoading(){
        this.hasTimeReservations =
        this.loaded = true;
    }
    async refreshMySeats(){
        this.startLoading();
        await this.getSeats();
        await this.getHours();
        this.endLoading();
    }
}