import { updateNewCoords,refreshDrawing,getNewCords } from './builder';

var canvasEle;
var context;
// let startPosition = {x: 0, y: 0};
// let lineCoordinates = {x: 0, y: 0};
// let isDrawStart = false;
//var canvas;
var wasInitialized = false;
var ctx;
var drag =false;
var rectPointArr = []
var rect = {}
var imgctx

export function GetContext(canvasctx){
    ctx = canvasctx;
    if(!wasInitialized){
        init();
    }
}

export function resetInitialized(){
    wasInitialized = false;
}

function init() {
    canvasEle = ctx.byClass('myCanvas');
    imgctx = ctx.byClass('mymap');
    imgctx.addEventListener('mousedown', mouseDownRect);
    imgctx.addEventListener('mouseup', mouseUpRect);
    imgctx.addEventListener('mousemove', mouseMoveRect);

    window.addEventListener('keydown', ctrlQListener);
    window.addEventListener('keydown', ctrlSListener);

    context = canvasEle.getContext('2d');
    context.strokeStyle = "darkblue";
    wasInitialized = true;
}


function ctrlSListener(event){
    if(!ctx.isRect) { window.removeEventListener("keydown", ctrlSListener);return} 
    if (event.ctrlKey && event.key === 'z') {
        refreshDrawing(true)
    }
}

function ctrlQListener(event){
    if(!ctx.isRect) { window.removeEventListener("keydown", ctrlQListener);return} 
    if (event.ctrlKey && event.key === 'q') {
        refreshDrawing(true)
    }
}


function mouseDownRect(event) {
  if(!ctx.isRect) { imgctx.removeEventListener("mousedown", mouseDownRect);return} 
  const rectImg = ctx.myimage.getBoundingClientRect();
  let x = (event.clientX - rectImg.left)/ctx.baseScale;
  let y = (event.clientY - rectImg.top)/ctx.baseScale;
  rect.startX = x;
  rect.startY = y;
  drag = true;
}
function mouseUpRect() {
    if(!ctx.isRect) { imgctx.removeEventListener("mouseup", mouseUpRect);return} 
    drag = false;
    sendRectCoords();
    //ctx.clearRect(0,0,canvasEle.width,canvasEle.height);
}
function mouseMoveRect(e) {
    if(!ctx.isRect) { imgctx.removeEventListener("mousemove", mouseMoveRect);return} 
    if (drag) {
        const rectImg = ctx.myimage.getBoundingClientRect();
        rect.w = (e.clientX - rectImg.left)/ctx.baseScale - rect.startX;
        rect.h = (e.clientY - rectImg.top)/ctx.baseScale - rect.startY;
        context.clearRect(0,0,canvasEle.width,canvasEle.height);
        refreshDrawing(true);
        drawRect();
    }
}
function drawRect() {
    // context.setLineDash([6]);
    context.strokeRect(rect.startX, rect.startY, rect.w, rect.h);
}
function getRectPoints(){
    var arr = [];
    arr.push(parseInt(rect.startX));
    arr.push(parseInt(rect.startY));
    arr.push(parseInt(rect.startX+rect.w));
    arr.push(parseInt(rect.startY));
    arr.push(parseInt(rect.startX+rect.w));
    arr.push(parseInt(rect.startY+rect.h));
    arr.push(parseInt(rect.startX));
    arr.push(parseInt(rect.startY+rect.h));
    return arr;
}

function sendRectCoords(){
    rectPointArr = getRectPoints()
    for (var i = 0; i <= rectPointArr.length-2; i+=2) {
        updateNewCoords(rectPointArr[i], rectPointArr[i+1])
    }
    updateNewCoords(rectPointArr[rectPointArr.length-2], rectPointArr[rectPointArr.length-1])// added for slice fix

}