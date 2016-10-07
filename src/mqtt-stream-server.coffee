stream = require "stream"
MQTT   = require "mqtt"


class MQTTStreamServer extends stream.PassThrough
  logPrefix: "(MQTTStream Server)"

  log:           console.log
  error:         console.error
  port:          8000
  sourcePort:    1883
  highWaterMark: 16384
  qos:           1

  constructor: (o) ->
    throw new Error "topic required" unless o.topic
    @[key] = value for key, value of o
    @log "creating"
    super highWaterMark: @highWaterMark

  connectMqtt: (callback = ->) =>
    @server   = "mqtt://#{@server}" unless /mqtt:/.exec @server
    @log "connecting to #{@server}"
    @mqttClient = MQTT.connect @server
    @mqttClient.on "error", (args...) => @error args...
    @mqttClient.on "connect", @subscribe
    @mqttClient.once "connect", callback

  subscribe: =>
    @log "connected"
    @log "subscribing to #{@topic}"
    await @mqttClient.subscribe @topic, {qos: @qos}, defer err, grantedlist
    throw new Error err if err
    @log "subscription granted to #{granted.topic} with QOS #{granted.qos}" for granted in grantedlist
    @mqttClient.on "message", @fill

  fill: (topic, message, packet) =>
    # @log "received message"
    @log "received NULL, ending stream" unless message
    success = @write message
    unless success then @error "buffer full"


module.exports = MQTTStreamServer
