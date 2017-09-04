console.log("hello world");
server = new Object();
server.hostname = "192.168.1.101";
server.port = 30831;
server.topic = "paho/test/simple"
// Create a client instance
client = new Paho.MQTT.Client(server.hostname, Number(server.port), "mqtt_js_client_test");
writeServerInfo(server);

// set callback handlers
client.onConnectionLost = onConnectionLost;
client.onMessageArrived = onMessageArrived;

// connect the client
client.connect({onSuccess:onConnect});


// called when the client connects
function onConnect() {
  // Once a connection has been made, make a subscription and send a message.
  console.log("onConnect");
  updateStatus("Connected");
  client.subscribe(server.topic);
  message = new Paho.MQTT.Message("Hello");
  message.destinationName = server.topic;
  client.send(message);
}

// called when the client loses its connection
function onConnectionLost(responseObject) {
  updateStatus("Connection Lost");
  if (responseObject.errorCode !== 0) {
    console.log("onConnectionLost:" + responseObject.errorMessage);
  }
}

// called when a message arrives
function onMessageArrived(message) {
  console.log("onMessageArrived:" + message.payloadString);
  writeMessage(message.payloadString);
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
  el_host.innerHTML = "host:" + server.hostname;

  el_port = document.getElementById("server_port");
  el_port.innerHTML = "port:" + server.port;

  el_topic = document.getElementById("server_topic");
  el_topic.innerHTML = "topic:" + server.topic;

}

// update connection status
function updateStatus(status) {
  el_status = document.getElementById("server_status");
  el_status.innerHTML = "status:" + status;

}