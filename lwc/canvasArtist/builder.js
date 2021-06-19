var newCoords = [];
var savedCoords = [];
var ctx;
var previousX
var previousY
var wasInitialized = false;

export function getSavedSeats(){
    return savedCoords;
}

export function ClearSavedDrawings(){
    savedCoords = [];
    return savedCoords;
}


export function GetContext(canvasctx){
    ctx = canvasctx;
    if(!wasInitialized){
        initCBuilder();
    }
}

function initCBuilder(){
    wasInitialized = true;
    window.addEventListener('keydown', (event) => {
        if (event.ctrlKey && event.key === 'z') {
            newCoords.pop();
            newCoords.pop();
            refresh();
            if(newCoords.length === 0){
                previousY = undefined;
                previousX = undefined;
            }else{
                drawLinesAfterCtrlZ(newCoords,'darkblue');
            }
        }

        if (event.ctrlKey && event.key === 'q') {
            ctx.invokeClear()
        }

        if (event.ctrlKey && event.key === 's') {
            ctx.invokeSave()
        }
    });
}

export function saveDrawing(currentSavedDrawings,isUpdate){
    cleanCanvas();
    if(isUpdate){
        savedCoords = currentSavedDrawings;
    }else{
        let currentDrawingCords = [...newCoords];
        if(newCoords.length>7){
            let alignedCords = currentDrawingCords.slice(0, -2);
            // let alignedCords = currentDrawingCords;
            savedCoords = currentSavedDrawings;
            savedCoords.push({Name: "",Coord:alignedCords});
            ctx.drawPoly(alignedCords,'darkblue',true,false,undefined,undefined);
        }else{
            console.log('err')
            ctx.showToast('Error','Insufficient coordinates to create a contour','error')
        }
    }

    newCoords =[];
    ctx.reDrawPublishedSeats();
    reDrawSavedSeats();
}


export function deleteDrawing(coord){
    let newSavedCords = [];
    savedCoords.forEach(element => {
        let stringCoord = element.Coord+"";
        if(stringCoord != coord){
            newSavedCords.push(element);
        }
    });
    savedCoords = newSavedCords;
    refresh();
}

function refresh(){
    cleanCanvas();
    ctx.reDrawPublishedSeats();
    reDrawSavedSeats();
}

export function refreshDrawing(clearNewCoords){
    if(clearNewCoords){
        newCoords = [];
    }
    cleanCanvas();
    ctx.reDrawPublishedSeats();
    reDrawSavedSeats();
}

function drawLinesAfterCtrlZ(mCoords,color)
{
    var i, n;
    n = mCoords.length;
    ctx.hdc.beginPath();
    ctx.hdc.moveTo(mCoords[0], mCoords[1]);
    ctx.hdc.arc(newCoords[0], newCoords[1], 1, 0, 2 * Math.PI);
    for (i=2; i<n; i+=2)
    {
        ctx.hdc.lineTo(mCoords[i], mCoords[i+1]);
    }
    ctx.hdc.strokeStyle = color;
    ctx.hdc.stroke();
}


function cleanCanvas()
{
    var canvas = ctx.byClass('myCanvas');
    ctx.hdc.clearRect(0, 0, canvas.width, canvas.height);
}

function reDrawSavedSeats(){
    savedCoords.forEach(coord => {
        ctx.drawPoly(coord.Coord+'','darkblue',true,false,undefined,undefined);
    });
}



export function drawNewCords(){
    ctx.drawPoly(newCoords+'','darkblue',false,false,undefined,undefined);
}

export function getNewCords(){
    return newCoords;
}

export function updateNewCoords(pointX, pointY){
    newCoords.push(parseInt(pointX));
    newCoords.push(parseInt(pointY));
}