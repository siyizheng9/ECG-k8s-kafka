demo = document.getElementById("demo")
var ctx = demo.getContext('2d'),
w = demo.width,
h = demo.height,
px = 0, opx = 0, speed = 1,
py = h * 0.8, opy = py,
scanBarWidth = 15;

ctx.strokeStyle = '#00bd00';
ctx.lineWidth = 1;

var i = 0;
var data = ecg_data;

function updatePYval(){
    //py = (parseInt(Math.round(data[i])/h));
    py = (parseInt(data[i].data) / 1000 * h);
    i++;
    if(i == data.length - 1)
        i = 0;
}

loop();

function loop() {

    updatePYval();

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
