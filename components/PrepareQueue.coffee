noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Prepare a message queue'
  c.durable = false
  c.inPorts.add 'connection',
    datatype: 'object'
    description: 'AMQP connection'
  c.inPorts.add 'queue',
    datatype: 'string'
    description: 'Message queue name'
  c.inPorts.add 'durable',
    datatype: 'boolean'
    description: 'Whether to persist the messages in the queue'
    default: false
    process: (event, payload) ->
      c.durable = payload if event is 'data'

  c.outPorts.add 'channel',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern c,
    in: [
      'connection'
      'queue'
    ]
    out: 'channel'
    async: true
    forwardGroups: true
  , (data, groups, out, callback) ->
    data.connection.createChannel (err, channel) ->
      return callback err if err
      channel.assertQueue data.queue,
        durable: c.durable
      , (err) ->
        return callback err if err
        out.beginGroup data.queue
        out.send channel
        out.endGroup()
        callback()

  c
