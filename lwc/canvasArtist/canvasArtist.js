import { LightningElement,api,track,wire } from 'lwc';
import * as Builder from './builder';
import * as Sticky from './stickyLine';
import * as Rectangle from './rectangle';
import * as Resizer from './resize';
import getLineWidth from '@salesforce/apex/reservationWiz.getLineWidth';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class CanvasArtist extends LightningElement {
    @api floor;
    @api publishedcoords;
    @track myimage
    @track hdc
    @track pos = { top: 0, left: 0, x: 0, y: 0 };
    @api isbuilder = false;
    loaded = true;
    baseScale = 1;
    isSticky = false;
    isRect = false;
    editIsActive = false;
    isResize = false;
    lineWidth = 0;

    @wire(getLineWidth)
    setCanvasLineWidth({ error, data }) {
        if (data) {
            this.lineWidth = data;
            if(this.hdc != undefined){
                this.hdc.lineWidth = this.lineWidth;
            }
        } else if (error) {
            console.log(error);
            console.log('error:'+JSON.stringify(error));
        }
    }

    renderedCallback(){
        if(this.isResize){
            return;
        }
        if(this.isbuilder){
            Builder.GetContext(this);
        }
        this.initializeCanvas();
    }

    //
    choseseat(event){
        let grabSeatCords = event.target.dataset.seat;
        let SelectedSeatName = event.target.dataset.name;
        this.shootEvent({cords:grabSeatCords,name:SelectedSeatName},'choseseat');
    }

    @api zoomIn(){
        var mapContainer = this.byClass('mapContainer');
        this.baseScale += 0.1;
        mapContainer.style.transform = "scale("+this.baseScale+", "+this.baseScale+")";
    }

    @api saveAndEndEditMode(){
        var newCords = Resizer.saveAndEndEditMode();
        this.resetToolTypes();
        return newCords;
    }

    @api changeTool(type){
        this.resetToolTypes();
        this.Refresh();
        switch (type) {
            case "Rectangle":
                this.isRect = true;
                Rectangle.GetContext(this);
                break;
            case "Sticky":
                this.isSticky = true;
                Sticky.GetContext(this);
                break;
        }
    }

    @api resetToolTypes(){
        Rectangle.resetInitialized();
        Sticky.resetInitialized();
        Resizer.resetInitialized();
        this.isSticky = false;
        this.isRect = false;
        this.isResize = false;
        this.editIsActive = false;
    }

    @api startEdit(targetCoords,isRedraw){
        this.resetToolTypes();
        this.isResize = true;
        Resizer.GetContext(this,targetCoords,isRedraw);
    }

    @api zoomOut(){
        var mapContainer = this.byClass('mapContainer');
        this.baseScale -= 0.1;
        if(this.baseScale < 1){
            this.baseScale = 1;
        }
        mapContainer.style.transform = "scale("+this.baseScale+", "+this.baseScale+")";
    }

    @api SaveDrawing(currentSavedDrawings,isUpdate){
        Builder.saveDrawing(currentSavedDrawings,isUpdate);
        let savedDrawing = Builder.getSavedSeats();
        if(this.isSticky){
            Sticky.stopDrawing();
        }
        return savedDrawing;
    }

    @api RemoveDrawing(coordsToRemove){
        Builder.deleteDrawing(coordsToRemove);
        let savedDrawing = Builder.getSavedSeats();
        return savedDrawing;
    }

    @api ClearSavedDrawings(){
        Builder.refreshDrawing(true);
        return  Builder.ClearSavedDrawings();
    }

    @api Refresh(){
        Builder.refreshDrawing(true);
        if(this.isSticky){
            Sticky.stopDrawing();
        }
    }
 
    shootEvent(value,type){
        const selectedEvent = new CustomEvent(type, {
            detail : value
          });
        this.dispatchEvent(selectedEvent);
    }

    byClass(e){return this.template.querySelector('.'+e);}

    @api outlineMarker(coOrdStr,markerColor)
    {
        if(this.isbuilder){
            Builder.refreshDrawing(false);
            Builder.drawNewCords();
            var mCoords = coOrdStr.split(',');
            var i, n;
            n = mCoords.length;
            this.hdc.beginPath();
            this.hdc.moveTo(mCoords[0], mCoords[1]);
            for (i=2; i<n; i+=2)
            {
                this.hdc.lineTo(mCoords[i], mCoords[i+1]);
            }
            this.hdc.lineTo(mCoords[0], mCoords[1]);
            this.hdc.save();
            this.hdc.strokeStyle = markerColor;
            this.hdc.lineWidth = this.hdc.lineWidth*2;
            this.hdc.stroke();
            this.hdc.restore();
        }else{
            this.publishedcoords.forEach(coord => {
                let strokeColor;
                var displayName
                if(coord.Type == "Daily"){
                    if(!coord.Occupied){
                        displayName = coord.Name;
                        strokeColor = 'green';
                    }else if(coord.mySeat){
                        displayName = this.getInitials(coord.Owner);
                        strokeColor = 'yellow';
                    }else{
                        displayName = this.getInitials(coord.Owner);
                        strokeColor = 'red';
                    }
                }else if(coord.Type == "Hourly"){
                    displayName = coord.Name;
                    strokeColor = 'lightblue';
                }
                else if(coord.Type == "Non Reservable"){
                    displayName = coord.Name;
                    strokeColor = 'lightyellow';
                }
                else if(coord.Type == "Permanent"){
                    if(!coord.Occupied){
                        displayName = coord.Name;
                    }else{
                        displayName = this.getInitials(coord.Owner);
                    }
                    strokeColor = '#DEB887';
                }
                if(coord.Coordinates == coOrdStr){
                    strokeColor = markerColor;
                    var mCoords;
                    if(Array.isArray(coord.CoordinatesCenter)){
                        mCoords = coord.CoordinatesCenter;
                    }else{
                        mCoords = coord.CoordinatesCenter.split(',');
                    }
                    // console.log('marker mCoords '+ mCoords);
                    // console.log('marker oord.Height '+ coord.Height);
                    var markerX = mCoords[0];
                    var markerY = mCoords[1]-coord.Height/2;
                    // console.log('markerX '+ markerX);
                    // console.log('markerY '+ markerX);

                    this.drawMarker(markerX,markerY)
                }
                this.drawPoly(coord.Coordinates,strokeColor,true,true,displayName,coord.CoordinatesCenter,coord.Width,coord.Height);
            });
        }
    }

    drawMarker(x,y) {
        
        var radius = 20;
        this.hdc.beginPath();
        //this.hdc.moveTo(75, 40);
        var startangle  = -Math.PI
        var endangle  = 0
        var arccenterY = y - 2*radius/1.414;
        this.hdc.moveTo(x-radius, arccenterY);
        this.hdc.arc(x, arccenterY, radius, startangle, endangle, false);
        // console.log('marker 2.4')
        this.hdc.lineTo(x, y);
        this.hdc.lineTo(x-radius, arccenterY);
        this.hdc.fillStyle = "#FF0000";
        this.hdc.fill();
        this.hdc.strokeStyle = "#000000";
        this.hdc.lineWidth = this.hdc.lineWidth*2;
        this.hdc.stroke();
    }
            // var mCoords = coOrdStr.split(',');
        // var i, n;
        // n = mCoords.length;
        // this.hdc.beginPath();
        // this.hdc.moveTo(mCoords[0], mCoords[1]);
        // for (i=2; i<n; i+=2)
        // {
        //     this.hdc.lineTo(mCoords[i], mCoords[i+1]);
        // }
        // this.hdc.lineTo(mCoords[0], mCoords[1]);
        // this.hdc.strokeStyle = markerColor;
        // ;
        // this.hdc.stroke();
        // this.hdc.lineWidth = this.hdc.lineWidth/2;

    @api getImage(){
        return this.template.querySelector('.mymap');
    }

    initializeCanvas(){
        this.myimage = this.template.querySelector('.mymap');
        var img = this.myimage;
        var x,y, w,h;
        x = img.offsetLeft;
        y = img.offsetTop;
        w = img.clientWidth;
        h = img.clientHeight;
        var imgParent = img.parentNode;
        var can = this.template.querySelector('.myCanvas');
        imgParent.appendChild(can);
        can.style.zIndex = 1;
        can.style.position = "absolute";
        can.style.left = x+'px';
        can.style.top = '0px';
        if(this.floor.Height__c != undefined && this.floor.Height__c != 0){
            w = this.floor.Width__c;
            h = this.floor.Height__c;
        }
        can.setAttribute('width', w+'px');
        can.setAttribute('height', h+'px');
        this.hdc = can.getContext('2d');
        // this.hdc.lineWidth = this.lineWidth;
        if(this.isbuilder){
            this.reDrawPublishedSeats();
        }else{
            this.publishedcoords.forEach(coord => {
                let strokeColor;
                var displayName;
                if(coord.Type == "Daily"){
                    if(!coord.Occupied){
                        displayName = coord.Name;
                        strokeColor = 'green';
                    }else if(coord.mySeat){
                        displayName = this.getInitials(coord.Owner);
                        strokeColor = 'yellow';
                    }else{
                        displayName = this.getInitials(coord.Owner);
                        strokeColor = 'red';
                    }
                }else if(coord.Type == "Hourly"){
                    displayName = coord.Name;
                    strokeColor = 'lightblue';
                }
                else if(coord.Type == "Non Reservable"){
                    displayName = coord.Name;
                    strokeColor = 'lightyellow';
                }
                else if(coord.Type == "Permanent"){
                    if(!coord.Occupied){
                        displayName = coord.Name;
                    }else{
                        displayName = this.getInitials(coord.Owner);
                    }
                    strokeColor = '#DEB887';
                }
                this.drawPoly(coord.Coordinates,strokeColor,true,true,displayName,coord.CoordinatesCenter,coord.Width,coord.Height);
            });
        }

        window.addEventListener('keydown', (event) => {
            if (event.ctrlKey && event.key === ']') {
                this.zoomIn();
                return
            }
    
            if (event.ctrlKey && event.key === '[') {
                this.zoomOut();
                return
            }
        });
    }

    getInitials(name){
        var initialz = (name.replace(/[^a-zA-Z]/g,' ').replace(/ +/g,' ').split(" ").map((n)=>n[0]).join(".")).toUpperCase();
        return ''+initialz;
    }

    reDrawPublishedSeats(){
        this.publishedcoords.forEach(coord => {
            let strokeColor;
            if(coord.Type == "Daily"){
                strokeColor = 'green';
            }else if(coord.Type == "Hourly"){
                strokeColor = 'lightblue';
            }
            else if(coord.Type == "Non Reservable"){
                strokeColor = 'lightyellow';
            }
            else if(coord.Type == "Permanent"){
                strokeColor = '#DEB887';
            }
            this.drawPoly(coord.Coordinates,strokeColor,true,true,coord.Name,coord.CoordinatesCenter,coord.Width,coord.Height);
        });
    }

    drawPoly(coOrdStr,color,drawClosingLine,FillDrawing,Name,CoordsCenter,Width,Height)
    {
        // console.log('Width '+Width);
        // console.log('Height '+Height);
        var mCoords;
        if(Array.isArray(coOrdStr)){
            mCoords = coOrdStr;
        }else{
            mCoords = coOrdStr.split(',');
        }
        var i, n;
        n = mCoords.length;
        this.hdc.beginPath();
        this.hdc.moveTo(mCoords[0], mCoords[1]);
        for (i=2; i<n; i+=2)
        {
            this.hdc.lineTo(mCoords[i], mCoords[i+1]);
        }
        if(drawClosingLine){
            this.hdc.lineTo(mCoords[0], mCoords[1]);
        }
        this.hdc.strokeStyle = "black";
        this.hdc.stroke();
        if(FillDrawing){
            this.hdc.fillStyle = color;
            this.hdc.fill();
        }
        if(Name != undefined){
             this.hdc.font = "1px Arial";
             this.hdc.textBaseline = "middle";
             this.hdc.textAlign="center"; 
             var textWidth = this.hdc.measureText(Name).width;
             var ratioW = parseInt(Width*0.75/textWidth);
             this.hdc.font = ratioW+"px Arial";
            //  console.log(ratioW);
             var textHeight = this.hdc.measureText('M').width;
             var ratioH = textHeight/Height;
            //  console.log(ratioH);
             if(ratioH > 1){
                this.hdc.font = "1px Arial";
                textHeight = this.hdc.measureText('M').width;
                ratioH = parseInt(Height*0.75/textHeight)
                this.hdc.font = ratioH+"px Arial";
             }
             this.hdc.fillStyle = "#000000";
             let CoordsCenterSplit = CoordsCenter.split(',');
             this.hdc.fillText(Name,CoordsCenterSplit[0],CoordsCenterSplit[1]);
             this.hdc.fillStyle = color;
        }
    }


    // drawPolySticky(coOrdStr,color)
    // {
    //     var mCoords;
    //     if(Array.isArray(coOrdStr)){
    //         mCoords = coOrdStr;
    //     }else{
    //         mCoords = coOrdStr.split(',');
    //     }
    //     var i, n;
    //     n = mCoords.length;
    //     this.hdc.beginPath();
    //     this.hdc.moveTo(mCoords[0], mCoords[1]);
    //     for (i=2; i<n; i+=2)
    //     {
    //         this.hdc.lineTo(mCoords[i], mCoords[i+1]);
    //     }
    //     this.hdc.strokeStyle = color;
    //     this.hdc.stroke();
    // }

    loadingStart(){
        this.loaded = false;
    }

    loadingEnd(){
        this.loaded = true;
    }

    invokeClear(){
        this.dispatchEvent(new CustomEvent('invokeclear'));
    }

    invokeSave(){
        this.dispatchEvent(new CustomEvent('invokesave'));
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