# MQTT

## Notes

> There are no queues as in traditional message queuing solutions. However, it is possible to queue message in certain cases
[introducing mqtt](http://www.hivemq.com/blog/mqtt-essentials-part-1-introducing-mqtt)

=
> Of course the broker is able to __store messages__ for clients that are not online. (This requires two conditions: client has connected once and its session is persistent and it has subscribed to a topic with Quality of Service greater than 0). [publish-subscribe](http://www.hivemq.com/blog/mqtt-essentials-part2-publish-subscribe)

=
> Depending on the concrete implementation, a broker can handle up to thousands of concurrently connected MQTT clients.
[client-broker-connection](http://www.hivemq.com/blog/mqtt-essentials-part-3-client-broker-connection-establishment)

### broker ports

Port 1883 (MQTT) 9001 (Websocket MQTT)

> You should only need to run MQTT over websockets if you intend to publish/subscribe to messages directly from within webapps (in page).
[stackoverflow](https://stackoverflow.com/questions/30624897/direct-mqtt-vs-mqtt-over-websocket)