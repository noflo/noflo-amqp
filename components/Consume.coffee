noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'stack-overflow'
  c.description = 'Consume messages from a specified queue'
  c.inPorts.add 'channel',
    datatype: 'object'
    description: 'AMQP channel connection'
  c.inPorts.add 'queue',
    datatype: 'string'
    description: 'Message queue name'
      c.channel.consume payload, (msg) ->
        c.outPorts.message.beginGroup msg.fields.deliveryTag
        c.outPorts.message.beginGroup payload
        c.outPorts.message.send msg.content.toString()
        c.outPorts.message.endGroup()
        c.outPorts.message.endGroup()

  c.outPorts.add 'message',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'
    required: false
  c.outPorts.add 'channel',
    datatype: 'object'
    required: false
  c.consumers = {}
  c.tearDown = (callback) ->
    for queue, consumer of c.consumers
      consumer.channel.close()
      consumer.ctx.deactivate()
    c.consumers = {}
    do callback
  c.process (input, output, context) ->
    return unless input.hasData 'channel', 'queue'
    [channel, queue] = input.getData 'channel', 'queue'
    output.send
      channel: channel
    c.consumers[queue] =
      channel: channel
      ctx: context
    channel.consume queue, (msg) ->
      output.send
        message: new noflo.IP 'openBracket', msg.fields.deliveryTag
      output.send
        message: new noflo.IP 'openBracket', queue
      output.send
        message: new noflo.IP 'data', msg.content.toString()
      output.send
        message: new noflo.IP 'closeBracket', queue
      output.send
        message: new noflo.IP 'closeBracket', msg.fields.deliveryTag
