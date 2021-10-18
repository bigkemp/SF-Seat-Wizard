import { LightningElement,api } from 'lwc';

export default class DrawingToolMenu extends LightningElement {
    choseSticky = false;
    choseRectangle = false;
    @api editiisactive = false;

    handleButtonClick(event){
        const toolType = event.target.dataset.buttonType;
        this.setSelected(toolType);
        this.shootEvent(toolType);
    }

    resetSelected(){
        this.choseSticky = false;
        this.choseRectangle = false;
    }

    setSelected(type){
        this.resetSelected();
        if(type =="Sticky"){
            this.choseSticky = true;
        }else if(type =="Rectangle"){
            this.choseRectangle = true;
        }else{
            //future tools
        }
    }

    shootEvent(value){
        const selectedEvent = new CustomEvent("chosetype", {
            detail : value
          });
        this.dispatchEvent(selectedEvent);
    }
}