noflo = require 'noflo'
chai = require 'chai' unless chai
Consume = require '../components/Consume.coffee'
amqp = require 'amqplib/callback_api.js'

rabbitUrl = 'amqp://localhost'
topic = 'consume_test'

describe 'Consume component', ->
  c = null
  channel = null
  queue = null
  message = null
  chan = null
  conn = null
  beforeEach (done) ->
    c = Consume.getComponent()
    channel = noflo.internalSocket.createSocket()
    queue = noflo.internalSocket.createSocket()
    message = noflo.internalSocket.createSocket()
    c.inPorts.channel.attach channel
    c.inPorts.queue.attach queue
    c.outPorts.message.attach message
    amqp.connect rabbitUrl, (err, con) ->
      conn = con
      conn.createChannel (err, ch) ->
        ch.assertQueue topic,
          durable: true
        , (err) ->
          chan = ch
          done()
  afterEach ->
    c.shutdown()
    conn.close()

  describe 'receiving a message', ->
    it 'should send the message as a packet', (done) ->
      payload = "Hello NoFlo, this is message #{Math.random()}"
      message.on 'data', (data) ->
        chai.expect(data).to.equal payload
        done()
      channel.send chan
      queue.send topic
      conn.createChannel (err, ch) ->
        ch.assertQueue topic,
          durable: true
        , (err) ->
          ch.sendToQueue topic, new Buffer payload

  describe 'receiving multiple messages', ->
    it 'should send the messages as packets', (done) ->
      expected = [
        'foo'
        'bar'
        'baz'
      ]
      message.on 'data', (data) ->
        chai.expect(data).to.equal expected.shift()
        return if expected.length
        done()
      channel.send chan
      queue.send topic
      conn.createChannel (err, ch) ->
        ch.assertQueue topic,
          durable: true
        , (err) ->
          ch.sendToQueue topic, new Buffer 'foo'
          ch.sendToQueue topic, new Buffer 'bar'
          process.nextTick ->
            ch.sendToQueue topic, new Buffer 'baz'
