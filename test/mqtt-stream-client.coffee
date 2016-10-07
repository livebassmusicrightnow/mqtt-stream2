events     = require "events"
stream     = require "stream"
{expect}   = require "chai"
{spy}      = require "sinon"
MQTT       = require "mqtt"
Client     = require "../src/mqtt-stream-client"


MQTT.connect = ->
  connection = new events.EventEmitter
  setTimeout (-> connection.emit "connect"), 50
  connection


describe "MQTTStreamClient", ->
  client = null
  log    = ->
  topic  = "PrinceOfTides"
  server = "mqtt.domain.com"

  beforeEach ->
    client = new Client {log, topic, server}

  afterEach ->
    client = null

  describe "##constructor", ->
    it "should set defaults", ->
      defaults = ["log", "error", "port", "qos"]
      expect(client[key]).to.exist for key in defaults

    it "should set options", ->
      options =
        server:  ->
        topic:   ->

        log:     ->
        error:   ->
        port:    8001

        qos:     2

      client = new Client options

      expect(client[key]).to.equal value for key, value of options

    it "should throw an error if required parameters are missing", ->
      options =
        log:     ->
        error:   ->
        port:    8001

        qos:     2

      thrower = -> new Client options

      expect(thrower).to.throw /server and topic parameters required/

  describe "##connectMqtt", ->
    it "should create a MQTT Client", ->
      client.connectMqtt()

      expect(client.mqttClient).to.exist

    it "should bind to the MQTT Client events and callback when connected", (done) ->

      await
        client.connectMqtt defer()
        {mqttClient} = client
        expect(mqttClient.listeners "error").to.have.length 1
        expect(mqttClient.listeners "connect").to.contain client.openValves

      done()

  describe "##_write", ->
    it "should publish a chunk to the MQTT topic", (done) ->
      chunk = "mqtttest"

      await
        client.mqttClient = publish: defer _topic, _chunk, {qos}
        client._write chunk

      expect(_topic).to.equal client.topic
      expect(qos).to.equal client.qos
      expect(_chunk).to.equal chunk

      done()
