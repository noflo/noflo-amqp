noflo = require 'noflo'
chai = require 'chai' unless chai
Publish = require '../components/Publish.coffee'
amqp = require 'amqplib/callback_api.js'

rabbitUrl = 'amqp://localhost'
topic = 'publish_test'

describe 'Publish component', ->
  c = null
  channel = null
  queue = null
  payload = null
  chan = null
  conn = null
  beforeEach (done) ->
    c = Publish.getComponent()
    channel = noflo.internalSocket.createSocket()
    queue = noflo.internalSocket.createSocket()
    payload = noflo.internalSocket.createSocket()
    c.inPorts.channel.attach channel
    c.inPorts.queue.attach queue
    c.inPorts.payload.attach payload
    amqp.connect rabbitUrl, (err, con) ->
      conn = con
      conn.createChannel (err, ch) ->
        ch.assertQueue topic,
          durable: true
        , (err) ->
          chan = ch
          done()
  afterEach ->
    conn.close()

  describe 'sending to a queue', ->
    it 'should result in a receivable message', (done) ->
      message = "Hello NoFlo, this is message #{Math.random()}"
      conn.createChannel (err, ch) ->
        ch.assertQueue topic,
          durable: true
        , (err) ->
          ch.consume topic, (msg) ->
            ch.ack msg
            chai.expect(msg.content.toString()).to.equal message
            ch.close()
            done()
      channel.send chan
      queue.send topic
      payload.send message
      payload.disconnect()

  describe 'sending multiple messages to a queue', ->
    it 'should result in a receivable messages', (done) ->
      expected = [
        'foo'
        'bar'
        'baz'
      ]
      conn.createChannel (err, ch) ->
        ch.assertQueue topic,
          durable: true
        , (err) ->
          ch.consume topic, (msg) ->
            ch.ack msg
            chai.expect(msg.content.toString()).to.equal expected.shift()
            return if expected.length
            ch.close()
            done()
      channel.send chan
      queue.send topic
      payload.send 'foo'
      payload.send 'bar'
      payload.send 'baz'
      payload.disconnect()
