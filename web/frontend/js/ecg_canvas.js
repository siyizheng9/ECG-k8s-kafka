demo = document.getElementById("demo")
var ctx = demo.getContext('2d'),
w = demo.width,
h = demo.height,
px = 0, opx = 0, speed = 3,
py = h * 0.8, opy = py,
scanBarWidth = 20;

ctx.strokeStyle = '#00bd00';
ctx.lineWidth = 3;

demo.onmousemove = function(e) {
var r = demo.getBoundingClientRect();
py = e.clientY - r.top;
}
loop();

function loop() {

px += speed;

ctx.clearRect(px,0, scanBarWidth, h);
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