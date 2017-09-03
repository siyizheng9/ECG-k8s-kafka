console.log("hello world");
server = new Object();
server.hostname = "localhost";
server.port = 30831;
// Create a client instance
client = new Paho.MQTT.Client(server.hostname, Number(server.port), "mqtt_js_client_test");

// set callback handlers
client.onConnectionLost = onConnectionLost;
client.onMessageArrived = onMessageArrived;

// connect the client
client.connect({onSuccess:onConnect});


// called when the client connects
function onConnect() {
  // Once a connection has been made, make a subscription and send a message.
  console.log("onConnect");
  client.subscribe("paho/test/simple");
  message = new Paho.MQTT.Message("Hello");
  message.destinationName = "paho/test/simple";
  client.send(message);
}

// called when the client loses its connection
function onConnectionLost(responseObject) {
  if (responseObject.errorCode !== 0) {
    console.log("onConnectionLost:"+responseObject.errorMessage);
  }
}

// called when a message arrives
function onMessageArrived(message) {
  console.log("onMessageArrived:"+message.payloadString);
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