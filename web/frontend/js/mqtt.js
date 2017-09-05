console.log("hello world");

// connection info
var connection = new Object();
connection.hostname = "192.168.1.101";
connection.port = 30831;
connection.topic = "paho/test/simple"
connection.client_id = "mqtt_js_client_test"

var client;

writeDefaultConnectionInfo(connection);

document.getElementById("connect_btn").addEventListener("click", OnconnectBtnClick);
document.getElementById("msg_log_btn").addEventListener("click", OnMsgLogBtnClick);
document.getElementById("msg_clear_btn").addEventListener("click", OnMsgClearBtnClick);

var isConnected = false;
var isLogMsg = true;

function OnconnectBtnClick() {
  if (isConnected == false) {
    getConnectionInfo();
    client = new Paho.MQTT.Client(connection.hostname, Number(connection.port), connection.client_id);
    ConnectToServer(client, connection);
  }
  else
    disConnect(client);
}

function OnMsgLogBtnClick() {
  var btn_item = document.getElementById("msg_log_btn")
  if (isLogMsg == true) {
    btn_item.innerText = "disabled";
    btn_item.className = "label label-warning";
  } else {
    btn_item.innerText = "enabled"; 
    btn_item.className = "label label-success";
  }
  isLogMsg = !isLogMsg;
}

function OnMsgClearBtnClick() {
  var btn_item = document.getElementById("messageList");
  btn_item.innerHTML = "";
}
// connect to the server
function ConnectToServer(client, connection) {
  console.log("connect btn clicked");

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
  client.subscribe(connection.topic);
  var message = new Paho.MQTT.Message("Hello " + connection.client_id);
  message.destinationName = connection.topic;
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
  var ecg_data = msg.split(',')[1];
  if (typeof ecg_data != 'undefined')
    updatePYval(ecg_data);

}

// write message to web page
function writeMessage(message) {
    var list = document.getElementById("messageList");

    var item = document.createElement('li');

    item.appendChild(document.createTextNode(message));

    list.appendChild(item);

    list.scrollTop = list.scrollHeight;
}


function writeDefaultConnectionInfo(connection) {
  document.getElementById("server_host").value = connection.hostname;

  document.getElementById("server_port").value = connection.port;

  document.getElementById("server_topic").value = connection.topic;

  document.getElementById("client_id").value = connection.client_id;

}

function getConnectionInfo() {

  connection.hostname = document.getElementById("server_host").value;
  console.log("host:" + connection.hostname);

  connection.port = document.getElementById("server_port").value;

  connection.topic = document.getElementById("server_topic").value;

  connection.client_id = document.getElementById("client_id").value;

}

// update connection status
function updateStatus(status) {
  if (status == true) {
    var msg = "Connected";
    var clsname = "label label-success";
    document.getElementById("connect_btn").innerText = "Disconnect"
    document.getElementById("server_host").disabled = true;
    document.getElementById("server_port").disabled = true;
    document.getElementById("server_topic").disabled = true;
    document.getElementById("client_id").disabled = true;
  }
  else {
    msg = "Connection Lost";
    clsname = "label label-warning";
    document.getElementById("connect_btn").innerText = "Connect"
    document.getElementById("server_host").disabled = false;
    document.getElementById("server_port").disabled = false;
    document.getElementById("server_topic").disabled = false;
    document.getElementById("client_id").disabled = false;
  }

  var el_status = document.getElementById("server_status");
  el_status.className = clsname;
  el_status.innerHTML = "status: " + msg;
}