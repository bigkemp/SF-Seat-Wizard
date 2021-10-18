import { LightningElement,track,api,wire } from 'lwc';
import getAvailableSeats from "@salesforce/apex/reservationWiz.getAvailableSeats";
import saveNewSeats from "@salesforce/apex/reservationWiz.saveNewSeats";
import updateSeatCords from '@salesforce/apex/reservationWiz.updateSeatCords';
import getFloors from '@salesforce/apex/reservationWiz.getFloors';
import updateFloor from '@salesforce/apex/reservationWiz.updateFloors';
import deleteSeat from '@salesforce/apex/reservationWiz.deleteSeat';
import updateSeat from '@salesforce/apex/reservationWiz.updateSeatByCords';
import getSeatAttributes from '@salesforce/apex/reservationWiz.getSeatAttributes';
import getSeatType from '@salesforce/apex/reservationWiz.getSeatType';
import getNeighborhoods from '@salesforce/apex/reservationWiz.getNeighborhoods';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class MapBuilder extends LightningElement {
    @track floorOptions = [];
    maskfloor;
    @track floor;
    @track publishedCoords = [];
    @track savedDrawings = [];
    @track Attributes = [];
    ChoseFloor =false;
    loaded = true;
    isBuilder = true;
    EditName = false;
    selectedSeatIsPermanent = false;
    EditSeat = false;
    editDrawing = false;
    @track SelectedSeat = [];
    @track SeatTypes  = [];
    @track Neighborhoods  = [];
    @track newSeatType
    @track newSeatAttributes
    @track newSelectedSeatName
    @track editNewValues = {newType:"",newAttributes:[],newName:"",newNeighborhood:""};
    @track selectedSeat = {};
    TempName
    
    editIsOff = true;

    refreshCanvas(){
       
    }

    myLookupHandle(event){
        this.SelectedSeat.OwnerId = event.detail.userId;
    }

    @wire(getSeatAttributes)
    setSeatAttributes({ error, data }) {
        if (data) {
            let attributesArray = [];
            data.forEach(att => {
                attributesArray.push({label:att, value:att});
            });
            this.Attributes = attributesArray;
        } else if (error) {
            console.log(error);
            console.log('error:'+JSON.stringify(error));
        }
    }
    
    @wire(getNeighborhoods)
    setNeighborhoods({ error, data }) {
        if (data) {
            let neighborhoodArray = [];
            data.forEach(nei => {
                neighborhoodArray.push({label:nei.Name, value:nei.Id});
            });
            this.Neighborhoods = neighborhoodArray;
        } else if (error) {
            console.log(error);
            console.log('error:'+JSON.stringify(error));
        }
    }

    @wire(getSeatType)
    setSeatType({ error, data }) {
        if (data) {
            let typeArray = [];
            data.forEach(typ => {
                typeArray.push({label:typ, value:typ});
            });
            this.SeatTypes = typeArray;
        } else if (error) {
            console.log(error);
            console.log('error:'+JSON.stringify(error));
        }
    }

    handleTypeChange(event){
        this.editNewValues.newType = event.target.value;
    }
    handleAttributesChange(event){
        this.editNewValues.newAttributes = event.target.value;
    }
    handleNeighborhoodChange(event){
        this.editNewValues.newNeighborhood = event.target.value;
    }

    renderedCallback(){
        let elm = this.getCanvas();
        if(elm != undefined){
            let imgsize = elm.getImage();
            if(imgsize.clientHeight != 0 && imgsize.clientWidth != 0){
                const sidebar = this.template.querySelector('.buildersidebar');
                sidebar.style.height = imgsize.clientHeight+"px";
            }
        }
    }

    handleChangeTool(event){
        let elm = this.getCanvas();
        elm.changeTool(event.detail);
    }

    needToUpdateFloorSize(){
        let elm = this.getCanvas();
        let imgsize = elm.getImage();
        if(imgsize.clientHeight != this.floor.Height__c){
             updateFloor({floor: this.floor.Id, newHeight:imgsize.clientHeight,newWidth:imgsize.clientWidth});
        }else{
            return;
        }
    }
    

    async saveSeats(){
        if(this.savedDrawings.length == 0){
            this.showToast("Warning","Please first save a drawing of a seat.","warning");
            return;
        }
        this.startLoading();
        this.needToUpdateFloorSize();
        var res =  await saveNewSeats({Json:JSON.stringify(this.savedDrawings),floorMap:this.floor.Id});
        await this.getCoordsFromServer();
        let elm = this.getCanvas();
        this.savedDrawings = elm.ClearSavedDrawings();
        if(res!='success'){
            JSON.parse(res).forEach(seat => {
                this.savedDrawings.push({Name:seat.Name, Coord:seat.Coordinates.split(','), hasError:true, Msg:seat.Msg})
            });
            this.savedDrawings = elm.SaveDrawing(this.savedDrawings,true);
        }else{
            this.showToast("Success","Saved New Seats","success");
        }
        this.endLoading();
    }

    saveDrawing(){
        let elm = this.getCanvas();
        this.savedDrawings = elm.SaveDrawing(this.savedDrawings,false);
    }

    clearDrawing(){
        let elm = this.getCanvas();
        elm.Refresh();
    }

    getCanvas(){
        const elm = this.template.querySelector('c-canvas-artist');
        return elm;
    }


    connectedCallback(){
        this.startLoading();
        getFloors().then((res) =>{
            let floors = [];
            res.forEach(floor => {
                let newFloor = {label:floor.Name,value:JSON.stringify(floor)};
                floors.push(newFloor);
            });
            this.floorOptions = floors;
            this.endLoading();
        })
    }

    updateTempName(event){
        this.TempName = event.target.value;
    }

    updateCurSeat(event){
        let curCoords = event.detail.coords
        let curTemp = event.detail.seatvalues
        let newarr = [];
        this.savedDrawings.forEach(element => {
            let stringCoord = element.Coord+"";
            if(stringCoord == curCoords){
                element.Name = curTemp.newName;
                element.Type = curTemp.newType;
                element.Attributes = curTemp.newAttributes;
                element.Neighborhood = curTemp.newNeighborhood;
                if(curTemp.newPermanentOwner != ""){
                    element.PermanentOwnerId = curTemp.newPermanentOwner;
                }
            }
            newarr.push(element);
        });
        this.savedDrawings = newarr;
    }

    deleteCurSavedDrawing(event){
        let curCoords = event.detail+"";
        let elm = this.getCanvas();
        this.savedDrawings =elm.RemoveDrawing(curCoords);
    }

    findCurSeat(event){
        let curCoords = event.detail+"";
        let elm = this.getCanvas();
        elm.outlineMarker(curCoords,'orange');
    }

    saveNewName(){
        let newarr = [];
        this.savedDrawings.forEach(element => {
            let stringCoord = element.Coord+"";
            if(stringCoord == this.SelectedSeat.Coordinates){
                element.Name = this.TempName;
            }
            newarr.push(element);
        });
        this.savedDrawings = newarr;
        this.TempName = "";
        this.closeModal();
    }

    async deleteSelectedSeat(){
        this.closeModal();
        this.startLoading();
        var res = await deleteSeat({cords:this.SelectedSeat.Coordinates ,floor:this.floor.Id})
        await this.getCoordsFromServer();
        this.clearDrawing();
        this.endLoading();
    }


    modalcloseHandler(){
        this.EditName = false;
        this.EditSeat = false;
        this.editIsOff = true;
    }

    getModal(){
        const elm = this.template.querySelector('c-sw-lwc-modal');
        return elm;
    }

    openeEditSeat(event){
        this.editNewValues = {newType:"",newAttributes:[],newName:"",newNeighborhood:""};
        this.modaltitle="Edit Seat";
        this.selectedSeatIsPermanent = false;
        this.publishedCoords.forEach(element => {
            if(element.Coordinates == event.detail.cords && element.Name == event.detail.name){
                this.SelectedSeat = element;
                if(this.SelectedSeat.Type == "Permanent"){
                    this.selectedSeatIsPermanent = true;
                }
            }
        });
        this.EditSeat = true;
        let elm = this.getModal();
        elm.openmodal();
    }

    updateSelectedSeatDrawing(){
        let elm = this.getCanvas();
        elm.startEdit(this.SelectedSeat.Coordinates,false);
        this.editDrawing = true;
        this.closeModal();
    }

    redrawSelectedSeatDrawing(){
        let elm = this.getCanvas();
        elm.startEdit(this.SelectedSeat.Coordinates,true);
        this.editDrawing = true;
        this.closeModal();
    }

    saveEditChanges(){
        let elm = this.getCanvas();
        var newCoords = elm.saveAndEndEditMode();
        // elm.resetToolTypes();
        this.updateResizeSeat(newCoords)
    }

    cancelEditResize(){
        var elm = this.getCanvas();
        elm.resetToolTypes();
        //this.getCoordsFromServer();
        this.editDrawing = false;
    }

    closeModal(){
        let elm = this.getModal();
        elm.closemodal();
        this.modalcloseHandler();

    }

    chooseFloor(event){
        this.maskfloor = event.target.value;
        this.floor = JSON.parse(this.maskfloor);
        this.ChoseFloor = true;
        this.getCoordsFromServer();
    }

    deleteSavedDrawing(event){
        let coord = event.target.dataset.coord;
        let elm = this.getCanvas();
        this.savedDrawings =elm.RemoveDrawing(coord);
    }

    updateResizeSeat(newCords){
        this.startLoading();
        updateSeatCords({
            oldCords:this.SelectedSeat.Coordinates,
            newCords:''+newCords,
            floor:this.floor.Id
            }
        ).then((res) =>{
            this.endLoading();
            var elm = this.getCanvas();
            elm.resetToolTypes();
            this.getCoordsFromServer();
            this.editDrawing = false;
            this.editIsOff = true;
            this.closeModal();

        }).catch((err) => {
            this.endLoading();
            this.showToast("Error","Something went wrong.","error");
            console.log(err);
        })
    }

    async getCoordsFromServer(){
        this.startLoading();
        var res = await getAvailableSeats({day:'1990-02-02',floor:this.floor.Id})
        this.publishedCoords = res;
        this.endLoading();
    }

    handleToggle(event){
        this.editIsOff = false;
    }

    handleSeatNameChange(event){
        this.editNewValues.newName = event.detail.value;
    }
    
    handleSeatEditCancel(){
        this.editIsOff = true;
    }

    handleSeatEditSave(){
        this.startLoading();
        let updateObj = {Type: this.editNewValues.newType,
                        Name: this.editNewValues.newName,
                        Attributes: this.editNewValues.newAttributes,
                        Neighborhood:this.editNewValues.newNeighborhood,
                        OwnerId: this.SelectedSeat.OwnerId};
        updateSeat({
            cords:this.SelectedSeat.Coordinates,
            floor:this.floor.Id,
            changes: JSON.stringify(updateObj)
        }).then((res) =>{
            this.endLoading();
            var elm = this.getCanvas();
            elm.resetToolTypes();
            this.getCoordsFromServer();
            this.editDrawing = false;
            this.editIsOff = true;
            this.closeModal();
        }).catch((err) => {
            this.endLoading();
            if(err && err.body && err.body.message){
                this.showToast("Error",err.body.message,"error");
            }else{
                this.showToast("Error","Something went wrong.","error");
            }
            console.log(err);
        })
    }

    startLoading(){
        this.loaded = false;
    }

    endLoading(){
        this.loaded = true;
    }


    showToast(mytitle, mymessage, variant) {
        const event = new ShowToastEvent({
            title: mytitle,
            message: mymessage,
            variant: variant,
        });
        this.dispatchEvent(event);
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