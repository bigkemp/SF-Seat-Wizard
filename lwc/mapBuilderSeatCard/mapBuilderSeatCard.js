import { LightningElement, api, track } from 'lwc';

export default class MapBuilderSeatCard extends LightningElement {
    
    @api coor;
    EditName = false;
    seatIsPermanentType = false;
    modaltitle
    grabSeatCords
    hasError = false;
    @api seattypes;
    @api seatattributes;
    @api seatneighborhood;
    @track savedValues = {newType:"",newAttributes:[],newName:"",newNeighborhood:"",newPermanentOwner:""};
    connectedCallback(){
        if(this.coor.hasError){
            this.locate();
        }
        this.savedValues.newType = this.seattypes[0].value;
    }

    handleAttributesChange(event){
        this.savedValues.newAttributes = event.target.value;
    }

    handleNeighborhoodChange(event){
        this.savedValues.newNeighborhood = event.target.value;
    }

    handleTypeChange(event){
        this.seatIsPermanentType = false;
        this.savedValues.newType = event.target.value;
        if(this.savedValues.newType == "Permanent"){
            this.seatIsPermanentType = true;
        }
    }
    myLookupHandle(event){
        this.savedValues.newPermanentOwner = event.detail.userId;
    }

    updateTempName(event){
        this.savedValues.newName = event.target.value;
    }

    locate(){
        this.dispatchEvent(new CustomEvent('locateseat',{detail: this.coor.Coord}));
    }

    saveNew(){
        const details = {coords: this.coor.Coord, seatvalues : this.savedValues}
        this.dispatchEvent(new CustomEvent('updateseat',{detail: details}));
        this.closeModal();
    }

    deleteSavedDrawing(){
        this.dispatchEvent(new CustomEvent('removeseat',{detail: this.coor.Coord}));
    }

    modalcloseHandler(){
        this.EditName = false;
    }

    openEditNameModal(event){
        event.target.blur();
        this.modaltitle="Set Seat Name";
        this.grabSeatCords = this.coor.coord;
        let elm = this.getModal();
        elm.openmodal();
        this.EditName = true;
    }

    getModal(){
        const elm = this.template.querySelector('c-sw-lwc-modal');
        return elm;
    }

    closeModal(){
        let elm = this.getModal();
        elm.closemodal();
        this.modalcloseHandler();

    }
}