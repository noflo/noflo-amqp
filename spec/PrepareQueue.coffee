noflo = require 'noflo'
chai = require 'chai' unless chai
PrepareQueue = require '../components/PrepareQueue.coffee'
amqp = require 'amqplib/callback_api.js'

rabbitUrl = 'amqp://localhost'
topic = 'queue_test'

describe 'PrepareQueue component', ->
  c = null
  connection = null
  queue = null
  channel = null
  conn = null
  beforeEach (done) ->
    connection = noflo.internalSocket.createSocket()
    queue = noflo.internalSocket.createSocket()
    channel = noflo.internalSocket.createSocket()
    c = PrepareQueue.getComponent()
    c.inPorts.connection.attach connection
    c.inPorts.queue.attach queue
    c.outPorts.channel.attach channel
    amqp.connect rabbitUrl, (err, con) ->
      conn = con
      done()
  afterEach ->
    conn.close()

  describe 'preparing a queue', ->
    it 'should send out the channel', (done) ->
      channel.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.assertQueue).to.be.a 'function'
        data.deleteQueue topic
        done()
      queue.send topic
      connection.send conn
