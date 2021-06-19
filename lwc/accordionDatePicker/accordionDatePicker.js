import { LightningElement, track } from 'lwc';
import getDates from '@salesforce/apex/reservationWiz.getDates';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class AccordionDatePicker extends LightningElement {
    @track weeks=[];

    connectedCallback(){
        getDates({})
        .then((res) =>{            
            getDates().then((res) =>{
                for(var week in res){
                    this.weeks.push({key:'Week '+week,value:res[week]});
                    this.day = res[week][0].userDate;
                }
            })
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

    dayPicked(event){
        let buttons = this.byClass("dateButton");
        this.day = event.target.dataset.date;
        buttons.forEach(btn => {
            btn.style.background ="white";
        });
        event.target.style.background  = "lightsteelblue";
        this.dispatchEvent(new CustomEvent('daychosen', { detail: this.day}));
    }

    byClass(e){return this.template.querySelectorAll('.'+e);}
}