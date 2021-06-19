import { updateNewCoords,refreshDrawing,drawNewCords,getNewCords } from './builder';

var canvasEle;
var context;
let startPosition = {x: 0, y: 0};
let lineCoordinates = {x: 0, y: 0};
let isDrawStart = false;
var wasInitialized = false;
var ctx;
var imgctx;

function init(){
    var canvas = ctx.byClass('myCanvas');
    imgctx = ctx.byClass('mymap');
    imgctx.addEventListener('mousedown', mouseDownSticky);
    imgctx.addEventListener('mousemove', mouseMoveSticky);
    imgctx.addEventListener('mouseup', mouseupSticky);
    window.addEventListener('keydown', escListener);
    window.addEventListener('keydown', ctrlzListener);
    window.addEventListener('keydown', ctrlQListener);
    window.addEventListener('keydown', ctrlSListener);

    canvasEle = canvas;
    context = canvasEle.getContext('2d')
    wasInitialized = true;
}

export function GetContext(canvasctx){
    ctx = canvasctx;
    if(!wasInitialized){
        init();
    }
}

export function resetInitialized(){
    wasInitialized = false;
    isDrawStart = false;
}

function ctrlSListener(event){
    if(!ctx.isSticky) { window.removeEventListener("keydown", ctrlSListener);return} 
    if (event.ctrlKey && event.key === 's') {
        stopDrawing()
    }
}

export function stopDrawing(){
    lineCoordinates = {x: 0, y: 0};
    isDrawStart = false;
}

function ctrlQListener(event){
    if(!ctx.isSticky) { window.removeEventListener("keydown", ctrlQListener);return} 
    if (event.ctrlKey && event.key === 'q') {
        stopDrawing()
    }
}

function ctrlzListener(event){
    if(!ctx.isSticky) { window.removeEventListener("keydown", ctrlzListener);return} 
    if (event.ctrlKey && event.key === 'z') {
        let currentCordsArray = getNewCords();
        if(currentCordsArray.length>1){
            startPosition = {x: currentCordsArray[currentCordsArray.length -2], y: currentCordsArray[currentCordsArray.length -1]};
            isDrawStart = true
            drawLine();        
        }else {     
            stopDrawing()
        }
    }
}

function escListener(event){
    if(!ctx.isSticky) { window.removeEventListener("keydown", escListener);return} 
    if (event.key === 'Escape') {
        isDrawStart = false;
        refreshDrawing(false); // removing the drawline after Escape
        drawNewCords()
        startPosition = {x: 0, y: 0};
        lineCoordinates = {x: 0, y: 0};
    }

}

const getClientOffset = (event) => {
    const rect = ctx.myimage.getBoundingClientRect();
    let x = (event.clientX - rect.left)/ctx.baseScale;
    let y = (event.clientY - rect.top)/ctx.baseScale;
    return {
       x,
       y
    } 
}

const drawLine = () => {
   context.beginPath();
   context.moveTo(startPosition.x, startPosition.y);
   context.lineTo(lineCoordinates.x, lineCoordinates.y);
   context.stroke();
}

const mouseDownSticky = (event) => {
   if(!ctx.isSticky) { imgctx.removeEventListener("mousedown", mouseDownSticky);return} 
   startPosition = getClientOffset(event);
   isDrawStart = true;
}

const mouseMoveSticky = (event) => {
  if(!ctx.isSticky) { imgctx.removeEventListener("mousemove", mouseMoveSticky);return} 
  if(!isDrawStart) return;
  
  lineCoordinates = getClientOffset(event);
  refreshDrawing(false);
  drawNewCords();
  drawLine();
}

const mouseupSticky = (event) => {
  if(!ctx.isSticky) { imgctx.removeEventListener("mouseup", mouseupSticky);return} 
  //isDrawStart = false;
  if(!(lineCoordinates.x == 0 && lineCoordinates.y == 0)){
      startPosition= lineCoordinates
  }
  updateNewCoords(startPosition.x, startPosition.y);
}

const clearCanvas = () => {
   context.clearRect(0, 0, canvasEle.width, canvasEle.height);
}