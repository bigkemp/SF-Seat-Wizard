import { LightningElement, track, api } from "lwc";
import searchWorker from "@salesforce/apex/reservationWiz.searchWorker";
import searchWorkerAllDates from "@salesforce/apex/reservationWiz.searchWorkerAllDates";
import getHierarchyCoWorkers from "@salesforce/apex/reservationWiz.getHierarchyCoWorkers";
import getAllOccupiedSeatsOnSpecificDay from "@salesforce/apex/reservationWiz.getAllOccupiedSeatsOnSpecificDay";
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class SearchSection extends LightningElement {
    @track myimage;
    @track hdc;
    @api day;
    @api floor;
    @track foundGeneralResults = [];
    @track foundUsers = [];
    @track foundAllReservationResults = [];
    @track tempres = {};
    selectedUser
    modalmaintitle = "";
    hideclosebutton= false;
    lookingForHierarchy= false;
    lookingForSomeone = false;
    lookingForSomeoneInGeneral = false;
    LookingForAllReservations = false;
    loaded = true;
    searchColor = "orange";
    searchColorOptions = [{label:"orange",value:"orange"},{label:"purple",value:"purple"},{label:"blue",value:"blue"},{label:"pink",value:"pink"},{label:"brown",value:"brown"} ];

    handleColorChange(event){
        this.searchColor = event.target.value;
    }

    startLoading(){
        this.loaded = false;
    }

    endLoading(){
        this.loaded = true;
    }

    openCloseHamburger(){
        var searchbar = this.template.querySelector('.myspecial');
        searchbar.classList.toggle("responsive");
    }

    openTodaysReservationSearch(){
        this.startLoading();
        this.modalmaintitle = "Today's Reservations";
        getAllOccupiedSeatsOnSpecificDay({day: this.day,floor: this.floor.Id}).then((res) =>{
            this.endLoading();
            if(res == null || res == undefined){
                this.showToast("Error","Something Went Wrong.","error");
                this.closeModal();
                return;
            }
            this.resetModalTypes();
            this.LookingForAllReservations = true;
            this.foundAllReservationResults = res;
            this.openModal();
        });
    }

    HierarchyCoWorkers(){
        this.modalmaintitle = "Hierarchy's Reservations";
        this.startLoading();
        getHierarchyCoWorkers().then((res) =>{
            this.endLoading();
            if(res == null || res == undefined){
                this.showToast("Error","Something Went Wrong.","error");
                this.closeModal();
                return;
            }
            this.resetModalTypes();
            console.log(JSON.stringify(res));
            for(var key in res){
                this.foundGeneralResults.push({value:res[key], key:key}); //Here we are creating the array to show on UI.
            }
                this.lookingForHierarchy  = true;
                this.openModal();
        });
    }

    MarkSeat(event){
        var targetDS = event.target.dataset
        this.dispatchEvent(new CustomEvent("drawlocation", { detail: {result:targetDS.coords, marker:"Orange"}}));
        this.closeModal();
    }

    resetModalTypes(){
        this.foundGeneralResults = [];
        this.foundUsers = [];
        this.foundAllReservationResults = [];
        this.lookingForSomeoneInGeneral = false;
        this.lookingForSomeone = false;
        this.lookingForHierarchy = false;
        this.LookingForAllReservations = false;
    }

    myLookupHandle(event){
        this.selectedUser = event.detail.userId;
    }

    openSearch(){
        this.modalmaintitle = "Search for Co-Worker On This Floor";
        this.searchValue = "";
        this.resetModalTypes();
        this.lookingForSomeone = true;
        this.openModal();
    }

    openGeneralSearch(){
        this.resetModalTypes();
        this.lookingForSomeoneInGeneral = true;
        this.modalmaintitle = "Search for Co-Worker Reservations";
        this.searchValue = "";
        this.openModal();
    }

    updateSearchValue(event){
        this.searchValue = event.detail.userId;
        console.log('updateSearchValue '+this.searchValue)
    }

    startSearching(){
        this.startLoading();
        searchWorker({WorkerId:this.searchValue ,day: this.day,floor: this.floor.Id}).then((res) =>{
            this.endLoading();
            if(res == null || res == undefined){
                this.showToast("Error","Sorry, didnt find Co-Worker's reservations.","error");
                this.closeModal();
                return;
            }
            if(res.length > 1){
                this.foundUsers = "Did you mean: "+res;
            }else{
                this.dispatchEvent(new CustomEvent("drawlocation", { detail: {result:res[0]+'', marker:this.searchColor}}));
                this.closeModal();
            }
        }).catch(err =>{
            this.endLoading();
            console.log(err);
        });
    }

    startGeneralSearching(){
        this.startLoading();
        this.foundGeneralResults = []; // clean results before starting again, incase of searching twice.
        searchWorkerAllDates({WorkerId:this.searchValue,floor: this.floor.Id}).then((res) =>{
            this.endLoading();
            if(res == null || res == undefined || JSON.stringify(res) == ""){
                this.showToast("Error","Sorry, didnt find Co-Worker's reservations.","error");
                this.closeModal();
                return;
            }
            for(var key in res){
                if(key == "FoundMultiUsers"){
                    this.foundUsers = "Did you mean: "+res[key];
                    this.foundGeneralResults = []; // if the array didnt find "FoundMultiUsers" first.
                    return;
                }
                this.foundGeneralResults.push({value:res[key], key:key}); //Here we are creating the array to show on UI.
            }
        });
    }

    //// modal functions
    getModal(){
        const elm = this.template.querySelector("c-sw-lwc-modal");
        return elm;
    }

    openModal(){
        let elm = this.getModal();
        elm.openmodal();
    }

    closeModal(){
        let elm = this.getModal();
        elm.closemodal();
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