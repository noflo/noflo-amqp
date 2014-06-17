noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'paper-plane'
  c.description = 'Publish a message into a specified queue'
  c.channel = null
  c.queue = null

  c.inPorts.add 'channel',
    datatype: 'object'
    description: 'AMQP channel connection'
    process: (event, payload) ->
      c.channel = payload if event is 'data'
  c.inPorts.add 'queue',
    datatype: 'string'
    description: 'Message queue name'
    process: (event, payload) ->
      c.queue = payload if event is 'data'
  c.inPorts.add 'payload',
    datatype: 'string'
    description: 'Message to send'
    process: (event, payload) ->
      return unless event is 'data'
      unless c.channel and c.queue
        c.error new Error 'No channel or queue defined'
        return
      c.channel.sendToQueue c.queue, new Buffer payload
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  c.shutdown = ->
    return unless c.channel
    c.channel.close()

  c
