console.log("hello world");

// server info
server = new Object();
server.hostname = "192.168.1.101";
server.port = 30831;
server.topic = "paho/test/simple"

client = new Paho.MQTT.Client(server.hostname, Number(server.port), "mqtt_js_client_test");

document.getElementById("connect_btn").addEventListener("click", OnconnectBtnClick);
document.getElementById("msg_log_btn").addEventListener("click", OnMsgLogBtnClick);

isConnected = false;
isLogMsg = true;

function OnconnectBtnClick() {
  if (isConnected == false)
    ConnectToServer(client, server);
  else
    disConnect(client);
}

function OnMsgLogBtnClick() {
  btn_item = document.getElementById("msg_log_btn")
  if (isLogMsg == true) {
    btn_item.innerText = "disabled"
  } else {
    btn_item.innerText = "enabled"
  }
  isLogMsg = !isLogMsg;
}
// connect to the server 
function ConnectToServer(client, server) {
  console.log("connect btn clicked");
  // Create a client instance
  writeServerInfo(server);

  // set callback handlers
  client.onConnectionLost = onConnectionLost;
  client.onMessageArrived = onMessageArrived;

  // connect the client
  client.connect({onSuccess:onConnect});
}

// called when the client connects
function onConnect() {
  // Once a connection has been made, make a subscription and send a message.
  console.log("onConnect");
  updateStatus(true);
  client.subscribe(server.topic);
  message = new Paho.MQTT.Message("Hello");
  message.destinationName = server.topic;
  client.send(message);
  isConnected = true;
}

function disConnect(client) {
  console.log("disconnect");
  client.disconnect();
}

// called when the client loses its connection
function onConnectionLost(responseObject) {
  updateStatus(false);
  if (responseObject.errorCode !== 0) {
    console.log("onConnectionLost:" + responseObject.errorMessage);
  }
  isConnected = false;
}

// called when a message arrives
function onMessageArrived(message) {
  console.log("onMessageArrived:" + message.payloadString);
  var msg = message.payloadString;
  if (isLogMsg)
     writeMessage(msg);
  // get ecg data
  ecg_data = msg.split(',')[1];
  updatePYval(ecg_data);

}

// write message to web page
function writeMessage(message) {
    list = document.getElementById("messageList");

    var item = document.createElement('li');

    item.appendChild(document.createTextNode(message));

    list.appendChild(item);

    list.scrollTop = list.scrollHeight;
}

// write server info
function writeServerInfo(server) {
  el_host = document.getElementById("server_host");
  el_host.innerHTML = "host: " + server.hostname;

  el_port = document.getElementById("server_port");
  el_port.innerHTML = "port: " + server.port;

  el_topic = document.getElementById("server_topic");
  el_topic.innerHTML = "topic: " + server.topic;

}

// update connection status
function updateStatus(status) {
  if (status == true) {
    msg = "Connected";
    document.getElementById("connect_btn").innerText = "Disconnect"
  }
  else {
    msg = "Connection Lost";
    document.getElementById("connect_btn").innerText = "Connect"
  }

  el_status = document.getElementById("server_status");
  el_status.innerHTML = "status: " + msg;
}