stream = require "stream"
MQTT   = require "mqtt"


class MQTTStreamClient extends stream.Writable
  logPrefix: "(MQTTStream Client)"

  log:   console.log
  error: console.error
  port:  1883
  qos:   1

  constructor: (o) ->
    throw new Error "server parameter required" unless o.server
    @[key] = value for key, value of o
    @log "creating"
    super highWaterMark: @highWaterMark
    @connectMqtt()

  connectMqtt: ->
    server = "mqtt://#{@server}:#{@port}"
    @log "connecting to MQTT server #{server}"
    @mqttClient = MQTT.connect server
    @mqttClient.on "connect", @openValves
    @mqttClient.on "error", (args...) => @error args...

  openValves: =>
    @log "connected"
    @log "laying pipe to #{@topic}"

  _write: (chunk, encoding, callback) =>
    @log "received NULL, ending stream" unless chunk?
    @mqttClient.publish @topic, chunk, qos: @qos
    callback()


module.exports = MQTTStreamClient
