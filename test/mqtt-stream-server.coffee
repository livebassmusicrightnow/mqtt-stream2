events     = require "events"
stream     = require "stream"
{expect}   = require "chai"
{spy}      = require "sinon"
MQTT       = require "mqtt"
Server     = require "../src/mqtt-stream-server"


MQTT.connect = ->
  connection = new events.EventEmitter
  setTimeout (-> connection.emit "connect"), 50
  connection.subscribe = ->
  connection


describe "MQTTStreamServer", ->
  server = null
  log    = ->
  topic  = "HolyRomanEmpire"

  beforeEach ->
    server = new Server {log, topic}

  afterEach ->
    server = null

  describe "##constructor", ->
    it "should set defaults", ->
      defaults = ["log", "error", "port", "sourcePort", "highWaterMark", "qos"]
      expect(server[key]).to.exist for key in defaults

    it "should set options", ->
      options =
        log:           ->
        error:         ->
        topic:        "RhodeIsland"
        port:          8001
        sourcePort:    1884
        highWaterMark: 16385
        qos:           2

      server = new Server options

      expect(server[key]).to.equal value for key, value of options

    it "should throw an error if required parameters are missing", ->
      options =
        log:     ->
        error:   ->
        port:    8001

        qos:     2

      thrower = -> new Server options

      expect(thrower).to.throw /topic required/

  describe "##connectMqtt", ->
    it "should create a MQTT Server", ->
      server.connectMqtt()

      expect(server.mqttClient).to.exist

    it "should bind to the MQTT Server events and callback when connected", (done) ->

      await
        server.connectMqtt defer()
        {mqttClient} = server
        expect(mqttClient.listeners "error").to.have.length 1
        expect(mqttClient.listeners "connect").to.contain server.subscribe

      done()

  describe "##fill", ->
    it "should push a message from the MQTT topic", (done) ->
      message = "mqtttest"

      await
        server.write = defer _message
        server.fill null, message, null

      expect(_message).to.equal message

      done()
