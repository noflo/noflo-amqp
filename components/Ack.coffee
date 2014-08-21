noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'check-circle'
  c.description = 'Acknowledge a message as handled'

  c.inPorts.add 'in',
    datatype: 'all'
  c.inPorts.add 'channel',
    datatype: 'object'
    required: true
  c.outPorts.add 'out',
    datatype: 'all'
    required: false
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern c,
    in: 'in'
    out: 'out'
    params: 'channel'
    forwardGroups: true
  , (data, groups, out) ->
    unless typeof groups[0] is 'number'
      return c.error new Error 'No deliveryTag found'

    c.params.channel.ack
      fields:
        deliveryTag: groups[0]

    out.send data

  c
