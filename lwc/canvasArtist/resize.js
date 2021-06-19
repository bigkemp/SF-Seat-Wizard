var ctx;
    var rect = {
         x: 150,
         y: 100,
         w: 123,
         h: 58
     }
    var hdc;
    var handlesSize = 8;
    var currentHandle = false;
    var drag = false;
    var imgctx;
    var wasInitialized = false;
    var canvasEle;

    export function GetContext(canvasctx,coords){
        ctx = canvasctx;
        if(!wasInitialized){
            init(coords);
        }
    }
    
    export function resetInitialized(){
        wasInitialized = false;
    }

    export function saveAndEndEditMode(){
        wasInitialized = false;
        //ctx.editIsActive = false;
        return convertRectformatToCoords();
    }
    
function convertRectformat(array){
    var xValues=[]
    var yValues=[]
    var splittedArray = array.split(',');
    for (var i = 0; i < splittedArray.length; i++) {
        if(i % 2 === 0) { // index is even
            xValues.push(parseInt(splittedArray[i]));
        }else{
            yValues.push(parseInt(splittedArray[i]));
        }
    }
    var width = Math.max(...xValues)-Math.min(...xValues)
    var height = Math.max(...yValues)-Math.min(...yValues)
    var xMin = Math.min(...xValues)
    var yMin = Math.min(...yValues)
    rect.x = xMin;
    rect.y = yMin;
    rect.w = width;
    rect.h = height;
}

function convertRectformatToCoords(){
    var arr = [];
    arr.push(parseInt(rect.x));
    arr.push(parseInt(rect.y));
    arr.push(parseInt(rect.x+rect.w));
    arr.push(parseInt(rect.y));
    arr.push(parseInt(rect.x+rect.w));
    arr.push(parseInt(rect.y+rect.h));
    arr.push(parseInt(rect.x));
    arr.push(parseInt(rect.y+rect.h));
    arr.push(parseInt(rect.x));
    arr.push(parseInt(rect.y));
    return arr;
}

function init(coords) {
    ctx.editIsActive = true;
    canvasEle = ctx.byClass('myCanvas');
    hdc = canvasEle.getContext('2d');
    convertRectformat(coords);
    imgctx = ctx.byClass('mymap');
    imgctx.addEventListener('mousedown', mouseDownResize, false);
    imgctx.addEventListener('mouseup', mouseUpResize, false);
    imgctx.addEventListener('mousemove', mouseMoveResize, false);
    wasInitialized = true;
    draw();
}

function point(x, y) {
    return {
        x: x,
        y: y
    };
}

function dist(p1, p2) {
    return Math.sqrt((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y));
}

function getHandle(mouse) {
    if (dist(mouse, point(rect.x, rect.y)) <= handlesSize) return 'topleft';
    if (dist(mouse, point(rect.x + rect.w, rect.y)) <= handlesSize) return 'topright';
    if (dist(mouse, point(rect.x, rect.y + rect.h)) <= handlesSize) return 'bottomleft';
    if (dist(mouse, point(rect.x + rect.w, rect.y + rect.h)) <= handlesSize) return 'bottomright';
    if (dist(mouse, point(rect.x + rect.w / 2, rect.y)) <= handlesSize) return 'top';
    if (dist(mouse, point(rect.x, rect.y + rect.h / 2)) <= handlesSize) return 'left';
    if (dist(mouse, point(rect.x + rect.w / 2, rect.y + rect.h)) <= handlesSize) return 'bottom';
    if (dist(mouse, point(rect.x + rect.w, rect.y + rect.h / 2)) <= handlesSize) return 'right';
    return false;
}

function mouseDownResize(e) {
    if(!ctx.isResize) { imgctx.removeEventListener("mousedown", mouseDownResize);return} 

    if (currentHandle) drag = true;
    draw();
}

function mouseUpResize() {
    if(!ctx.isResize) { imgctx.removeEventListener("mouseup", mouseUpResize);return} 
    drag = false;
    currentHandle = false;
    draw();
}

function mouseMoveResize(e) {
    if(!ctx.isResize) { imgctx.removeEventListener("mousemove", mouseMoveResize);return} 

    var previousHandle = currentHandle;
    const recti = ctx.myimage.getBoundingClientRect();
    let myx = (e.clientX - recti.left)/ctx.baseScale;
    let myy = (e.clientY - recti.top)/ctx.baseScale;
    if (!drag) currentHandle = getHandle(point(myx, myy));
    if (currentHandle && drag) {
        var mousePos = point(myx, myy);
        switch (currentHandle) {
            case 'topleft':
                rect.w += rect.x - mousePos.x;
                rect.h += rect.y - mousePos.y;
                rect.x = mousePos.x;
                rect.y = mousePos.y;
                break;
            case 'topright':
                rect.w = mousePos.x - rect.x;
                rect.h += rect.y - mousePos.y;
                rect.y = mousePos.y;
                break;
            case 'bottomleft':
                rect.w += rect.x - mousePos.x;
                rect.x = mousePos.x;
                rect.h = mousePos.y - rect.y;
                break;
            case 'bottomright':
                rect.w = mousePos.x - rect.x;
                rect.h = mousePos.y - rect.y;
                break;

            case 'top':
                rect.h += rect.y - mousePos.y;
                rect.y = mousePos.y;
                break;

            case 'left':
                rect.w += rect.x - mousePos.x;
                rect.x = mousePos.x;
                break;

            case 'bottom':
                rect.h = mousePos.y - rect.y;
                break;

            case 'right':
                rect.w = mousePos.x - rect.x;
                break;
        }
    }
    if (drag || currentHandle != previousHandle) draw();

}

function draw() {
    hdc.clearRect(0, 0, canvasEle.width, canvasEle.height);
    hdc.fillStyle = 'black';
    hdc.fillRect(rect.x, rect.y, rect.w, rect.h);
    if (currentHandle) {
        var posHandle = point(0, 0);
        switch (currentHandle) {
            case 'topleft':
                posHandle.x = rect.x;
                posHandle.y = rect.y;
                break;
            case 'topright':
                posHandle.x = rect.x + rect.w;
                posHandle.y = rect.y;
                break;
            case 'bottomleft':
                posHandle.x = rect.x;
                posHandle.y = rect.y + rect.h;
                break;
            case 'bottomright':
                posHandle.x = rect.x + rect.w;
                posHandle.y = rect.y + rect.h;
                break;
            case 'top':
                posHandle.x = rect.x + rect.w / 2;
                posHandle.y = rect.y;
                break;
            case 'left':
                posHandle.x = rect.x;
                posHandle.y = rect.y + rect.h / 2;
                break;
            case 'bottom':
                posHandle.x = rect.x + rect.w / 2;
                posHandle.y = rect.y + rect.h;
                break;
            case 'right':
                posHandle.x = rect.x + rect.w;
                posHandle.y = rect.y + rect.h / 2;
                break;
        }
        hdc.globalCompositeOperation = 'xor';
        hdc.beginPath();
        hdc.arc(posHandle.x, posHandle.y, handlesSize, 0, 2 * Math.PI);
        hdc.fill();
        hdc.globalCompositeOperation = 'source-over';
    }
}