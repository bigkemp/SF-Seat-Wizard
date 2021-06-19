const c = document.getElementById("myCanvas");
const ctx = c.getContext("2d");
const r = 10; // draw radius
ctx.lineWidth = r * 2;
ctx.lineCap = "round";
ctx.fillStyle = "black";
var draw = false;
var lineStart = true;
var lastX, lastY;

export function bGetContext(canvasctx){
    ctx = canvasctx;
    if(!wasInitialized){
        init();
    }
}

function init(){
    var canvas = ctx.byClass('myCanvas');
    ctx.addEventListener('mousedown', yesDraw);
    ctx.addEventListener('mousemove', mouseMoveFL);
    ctx.addEventListener('mouseup', noDraw);

    canvasEle = canvas;
    context = canvasEle.getContext('2d')
    wasInitialized = true;
}

function yesDraw() { draw = true; lineStart = true }

function mouseMoveFL(e) { 
   const bounds = c.getBoundingClientRect();
   const x = e.pageX - bounds.left - scrollX;
   const y = e.pageY - bounds.top - scrollY;
   if(draw && x > -r && x < c.width + r && y > -r && y < c.height + r){
      drawing(x,y);
   }
}

function noDraw() { draw = false }


function drawing(x, y) {
  if(lineStart){
     lastX = x;
     lastY = y;
     lineStart = false;
  }
  ctx.beginPath();
  ctx.lineTo(lastX, lastY);
  ctx.lineTo(x, y);
  ctx.stroke();
  lastX = x;
  lastY = y;
}