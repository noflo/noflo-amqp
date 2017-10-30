noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'paper-plane'
  c.description = 'Publish a message into a specified queue'
  c.inPorts.add 'channel',
    datatype: 'object'
    description: 'AMQP channel connection'
    control: true
  c.inPorts.add 'queue',
    datatype: 'string'
    description: 'Message queue name'
    control: true
  c.inPorts.add 'payload',
    datatype: 'string'
    description: 'Message to send'
  c.outPorts.add 'error',
    datatype: 'object'
    required: false
  c.process (input, output) ->
    return unless input.hasData 'channel', 'queue', 'payload'
    [channel, queue, payload] = input.getData 'channel', 'queue', 'payload'
    channel.sendToQueue queue, new Buffer payload
    output.done()
