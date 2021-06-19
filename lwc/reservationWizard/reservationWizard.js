import { LightningElement,track } from 'lwc';
import getDates from '@salesforce/apex/reservationWiz.getDates';
import getFloors from '@salesforce/apex/reservationWiz.getFloors';
import TakeSeatMulti from "@salesforce/apex/reservationWiz.TakeSeatMulti";
import freeSeat from "@salesforce/apex/reservationWiz.freeSeat";
import getAvailableSeats from "@salesforce/apex/reservationWiz.getAvailableSeats";
import getDayEvents from "@salesforce/apex/reservationWiz.getDayEvents";
import availableSeatDates from "@salesforce/apex/reservationWiz.availableSeatDates";
import freeTimeReservation from "@salesforce/apex/reservationWiz.freeTimeReservation";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';


export default class ReservationWizard extends LightningElement {
    @track dateObj = [];
    @track seatTimeObj = [];
    weekNum = '';
    day ="1990-02-02";
    floor;
    hour;
    maskfloor;
    floorOptions = [];
    ChoseFloor = false;
    ChoseDay = false;
    isDay = false;
    isPermanent = false;
    isHourly = false;
    isNonReservable = false;
    @track selectionReady= false;
    @track publishedCoords=[];
    @track MultiReserveDatesValues=[];
    isBuilder=false;
    @track chosenSeat;
    @track selectedSeat;
    MultiReserveDates;
    modalmaintitle;
    @track ele;
    @track pos = { top: 0, left: 0, x:  0, y: 0 };
    currentSeat = false;
    startDrag = false;
    loaded = true;
    isMultiReserv = false;
    selectedReservationTypes = 'Single Reservation';
    reservationTypes = [{label:"Single Reservation",value:"Single Reservation"},{label:"Multi Reservation",value:"Multi Reservation"}];

    startLoading(){
        this.loaded = false;
    }

    endLoading(){
        this.loaded = true;
    }

    connectedCallback(){
        this.startLoading();
        getDates().then((res) =>{
            this.endLoading();
            for(var week in res){
                this.dateObj.push({key:week,value:res[week]});
                this.day = res[week][0].userDate;
            }
        })
        getFloors().then((res) =>{
            this.endLoading();
            let localfloorarray = [];
            res.forEach(floor => {
                let newObj = {label:floor.Name,value:JSON.stringify(floor)};
                localfloorarray.push(newObj);
            });
            this.floorOptions = localfloorarray;
        })
    }

    renderedCallback(){
        this.ele = this.byClass('mapContainer');
        this.ele.addEventListener('mousedown', e => {
            this.startDrag = true;
            this.pos = {
                // The current scroll 
                left: this.ele.scrollLeft,
                top: this.ele.scrollTop,
                // Get the current mouse position
                x: e.clientX,
                y: e.clientY,
            };
            this.ele.style.cursor = 'grabbing';
            this.ele.style.userSelect = 'none';
            this.ele.addEventListener('mousemove', this.mouseMoveHandler.bind(this));
            this.ele.addEventListener('mouseup', this.mouseUpHandler.bind(this));
          });
    }

    byClass(e){return this.template.querySelector('.'+e);}

    resetModalParams(){
        this.currentSeat = false;
        this.isMultiReserv = false;
        this.selectedReservationTypes = "Single Reservation";
    }

    mouseMoveHandler(e) {
        if(!this.startDrag){
            return;
        }
            // How far the mouse has been moved
            const dx = e.clientX - this.pos.x;
            const dy = e.clientY - this.pos.y;
    
            // Scroll the element
            this.ele.scrollTop = this.pos.top - dy;
            this.ele.scrollLeft = this.pos.left - dx;
    };

    mouseUpHandler(e) {
        this.startDrag = false;
        this.ele.style.cursor = 'grab';
        this.ele.style.removeProperty('user-select');
    };

    reservationTypesChange(event){
        this.selectedReservationTypes = event.target.value;
        if(this.selectedReservationTypes === "Single Reservation"){
            this.isMultiReserv = false;
        }else{
            this.isMultiReserv = true;
        }   
    }

    chooseFloor(event){
        this.maskfloor = event.target.value;
        this.floor = JSON.parse(this.maskfloor);
        this.ChoseFloor = true;
        this.selectionReady = this.ChoseDay && this.ChoseFloor? true : false;
        if(this.selectionReady){
            this.getCoordsFromServer();
        }

    }

    chooseDay(event){
        this.day = event.detail;
        this.ChoseDay=true;
        this.selectionReady = this.ChoseDay && this.ChoseFloor? true : false;
        if(this.selectionReady){
            this.getCoordsFromServer();
        }
    }

    getCoordsFromServer(){
        this.startLoading();
        getAvailableSeats({
            day:this.day,
            floor:this.floor.Id
            }
        ).then((res) =>{
            this.publishedCoords = res;
            this.endLoading();
        })
    }

    seatchosen(event){
        this.selectedSeat =event.detail;
        this.openSeat()
    }

    showToast(mytitle, mymessage, variant) {
        const event = new ShowToastEvent({
            title: mytitle,
            message: mymessage,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    
    openSeat(){
        this.MultiReserveDatesValues = [];
        this.modalmaintitle = "Make a reservation";
        this.startLoading();
        this.publishedCoords.forEach(seat => {
            if(seat.Name === this.selectedSeat.name){
                this.isDay = false;
                this.isPermanent = false;
                this.isHourly = false;
                this.isNonReservable = false;
                this.chosenSeat = seat;
                this.currentSeat = true;
                if(this.chosenSeat.Type == "Hourly"){
                    getDayEvents({thisDate:this.day, cords:this.chosenSeat.Coordinates,floor:this.floor.Id}).then((res)=>{
                        this.isHourly = true;
                        this.isMultiReserv = true;
                        let free = res.availableHours;
                        let availabletimes = [];
                        for(var hour in free){
                            availabletimes.push(free[hour]);
                        }
                        let taken = res.takenHours;
                        let takenhours = [];
                        for(var hour in taken){
                            takenhours.push(taken[hour]);
                        }
                        this.seatTimeObj = {Available:availabletimes,Taken:takenhours}
                        this.hour = this.seatTimeObj.Available[0].timeLabel+ '-' + this.seatTimeObj.Available[1].timeLabel;
                        let datesArray = [];
                        for (let index = 0; index < this.seatTimeObj.Available.length; index++) {
                            if(index+1 >= this.seatTimeObj.Available.length){
                                break;
                            }
                            let timeArray = this.seatTimeObj.Available[index].timeLabel +'-'+this.seatTimeObj.Available[index+1].timeLabel;
                            datesArray.push({label:timeArray,value:timeArray});
                        }
                        this.MultiReserveDates = datesArray;
                        this.openModal();
                        this.endLoading();
                    }).catch(err =>{
                        console.log(err);
                    })
                }else if(this.chosenSeat.Type == "Daily"){
                    availableSeatDates({ Cords:this.chosenSeat.Coordinates, floor: this.floor.Id}).then((res)=>{
                        let datesArray = [];
                        this.isDay = true;
                        res.forEach(openDate => {
                            let newvalue = { label: openDate, value: openDate };
                            datesArray.push(newvalue);
                        });
                        this.MultiReserveDates = datesArray;
                        this.openModal();
                        this.endLoading();
                    })
                }else if(this.chosenSeat.Type == "Non Reservable"){
                    this.openModal();
                    this.endLoading();
                }else if(this.chosenSeat.Type == "Permanent"){
                    this.openModal();
                    this.endLoading();
                }
            }
        });
    }

    MultiReserveDatesChange(event){
        this.MultiReserveDatesValues = event.detail.value;
    }

    freeHour(event){
        let callJson = {floor:this.floor.Id,myHour:event.target.dataset.hour,seat:this.selectedSeat.cords,thisDate:this.day};
        this.startLoading();
        freeTimeReservation(callJson).then((res) =>{
            this.endLoading();
            this.showToast('Success','Reservation freed.','success');
            this.closeModal();
        }).catch(err =>{
            this.endLoading();
            console.log(err);
        });
    }

    saveSeat(){
        this.startLoading();
            let tempstring = this.MultiReserveDatesValues+"";
            let callJSON;
            if(this.chosenSeat.Type == "Hourly"){
                let hours;
                if(this.MultiReserveDatesValues.length > 0){
                    hours = tempstring;
                }else{
                    hours = this.hour;
                }
                callJSON = {
                    SeatName: this.chosenSeat.Name,
                    availableDates:this.day,
                    floor:this.floor.Id,
                    seatType:this.chosenSeat.Type,
                    availableHours: hours
                    };
            }else{
                let dates;
                if(this.MultiReserveDatesValues.length > 0){
                    dates = tempstring;
                }else{
                    dates = this.day;
                }
                callJSON = {
                    SeatName: this.chosenSeat.Name,
                    availableDates:dates,
                    floor:this.floor.Id,
                    seatType:this.chosenSeat.Type,
                    availableHours: null
                    };
            }
            TakeSeatMulti(callJSON).then((res) =>{
                this.endLoading();
                this.showToast('Success','Reservation Saved.','success');
                this.closeModal();
            }).catch(err =>{
                this.endLoading();
                console.log(err);
            });
    }

    leaveSeat(){
        this.startLoading();
        freeSeat({
            day:this.day
            }
        ).then((res) =>{
            this.endLoading();
            this.showToast('Success','Seat Freed.','success');
            this.closeModal();
        }).catch(err =>{
            this.endLoading();
            console.log(err);
        });
    }

    getModal(){
        const elm = this.template.querySelector('c-sw-lwc-modal');
        return elm;
    }

    openModal(){
        let elm = this.getModal();
        elm.openmodal();
    }

    closeModal(){
        this.isMultiReserv = false;
        let elm = this.getModal();
        elm.closemodal();
        this.getCoordsFromServer();
    }

    drawsearchedlocation(event){
        const ca =this.template.querySelector('c-canvas-artist');
        ca.outlineMarker(event.detail.result,event.detail.marker);
    }

    zoomIN(){
        const ca =this.template.querySelector('c-canvas-artist');
        ca.zoomIn();
    }
    zoomOUT(){
        const ca =this.template.querySelector('c-canvas-artist');
        ca.zoomOut();
    }

}