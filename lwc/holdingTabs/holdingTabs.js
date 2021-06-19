import { LightningElement, track, api,wire} from 'lwc';
import getPermissionSets from '@salesforce/apex/reservationWiz.getPermissionSets';

export default class HoldingTabs extends LightningElement {
    @track isSR = true;
    @track isSet = false;
    @track isMySet = false;
    @track isBuilder = false;
    @track activetab = 'Seat Reservations';

    @wire(getPermissionSets) sortAlignmentMap(res){
        if(res.data === true){
            this.isBuilder = true;
        }else{
            this.isBuilder = false;
        }
    }
    rerenderContent(event) {
        this.activetab  = event.target.dataset.name;
        this.setActiveTab();
    }

    setActiveTab(){
        this.isSR = this.activetab == 'Seat Reservations'? true:false;
        this.isSet = this.activetab == 'Settings'? true:false;
        this.isMySet = this.activetab == 'My Seat Reservations'? true:false;
    }
}