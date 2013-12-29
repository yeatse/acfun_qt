var commentPool = [];
var commentIndex = 0;
var commentVisual = [];

function intToColor(colorInt){
    var str = colorInt.toString(16);
    while(str.length < 6){
        str = "0"+str;
    }
    return "#"+str;
}

function addToScreen(){
    var i = 0;
    while(commentVisual[i]===1){
        i ++;
    }
    commentVisual[i] = 1;
    return i;
}

function clearFromScreen(i){
    commentVisual[i] = 0;
}
