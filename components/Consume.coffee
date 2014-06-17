noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'stack-overflow'
  c.description = 'Consume messages from a specified queue'
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
      return unless event is 'data'
      unless c.channel
        c.error new Error 'No channel available'
        return
      c.channel.consume payload, (msg) ->
        c.channel.ack msg
        c.outPorts.message.beginGroup payload
        c.outPorts.message.send msg.content.toString()
        c.outPorts.message.endGroup()

  c.outPorts.add 'message',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  c.shutdown = ->
    return unless c.channel
    c.outPorts.message.disconnect()
    c.channel.close()

  c
