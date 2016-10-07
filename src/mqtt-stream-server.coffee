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
    @[key] = value for key, value of o
    @log "creating"
    super highWaterMark: @highWaterMark

    if @server then @connectMqtt()
    else
      @mqttServer or= new MQTTServer
        readyHandler: @connectMqtt
        port:         @sourcePort
        log:          @log

  connectMqtt: =>
    @server or= "#{@mqttServer.ascoltatore.host}"
    @server   = "mqtt://#{@server}" unless /mqtt:/.exec @server
    @log "connecting to #{@server}"
    @mqttClient = MQTT.connect @server
    @mqttClient.on "connect", @subscribe
    @mqttClient.on "error", (args...) => @error args...

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
