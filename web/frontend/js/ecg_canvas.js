var demo = document.getElementById("demo");

var ctx, w, h, px, opx, speed, py, opy, scanBarWidth;

initCanvas();

window.addEventListener('resize', initCanvas, true);

function initCanvas() {

    var parent_el = demo.parentElement;
    var parent_width = parent_el.offsetWidth;
    //var parent_height = parent_el.offsetHeight;
    var parent_padding = $(parent_el).css('padding-left');
    
    demo.width = parent_width - 2 * parseInt(parent_padding);
    //demo.height = parent_height - 2 * parseInt(parent_padding);

    initCtx();
}

function initCtx() {

    ctx = demo.getContext('2d');
    w = demo.width;
    h = demo.height;
    px = 0, opx = 0, speed = 1;
    py = h * 0.8, opy = py;
    scanBarWidth = 15;
    
    ctx.strokeStyle = '#00bd00';
    ctx.lineWidth = 1;

}

var i = 0;
var data = ecg_data;

function randomPYval(){
    //py = (parseInt(Math.round(data[i])/h));
    py = (parseInt(data[i].data) / 1000 * h);
    i++;
    if(i == data.length - 1)
        i = 0;
}

function updatePYval(yVal) {
    py = h - (parseInt(yVal) / 1000 * h * 0.8);
}

loop();

function loop() {

    //randomPYval();

    px += speed;

    ctx.clearRect(px, 0, scanBarWidth, h);
    ctx.beginPath();
    ctx.moveTo(opx, opy);
    ctx.lineTo(px, py);
    ctx.stroke();

    opx = px;
    opy = py;

    if (opx > w) {
        px = opx = -speed;
    }

    requestAnimationFrame(loop);
}
