noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'exclamation-circle'
  c.description = 'Unacknowledge a message'

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
    async: true
  , (data, groups, out, callback) ->
    unless typeof groups[0] is 'number'
      return callback new Error 'No deliveryTag found'

    c.params.channel.nack
      fields:
        deliveryTag: groups[0]

    out.send data
    do callback
