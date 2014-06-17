noflo = require 'noflo'
amqp = require 'amqplib/callback_api.js'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Connect to an AMQP server'

  c.inPorts.add 'url',
    datatype: 'string'
  c.outPorts.add 'connection',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern c,
    in: ['url']
    out: 'connection'
    async: true
    forwardGroups: true
  , (data, groups, out, callback) ->
    amqp.connect data, (err, conn) ->
      return callback err if err
      out.beginGroup data
      out.send conn
      out.endGroup()
      callback()

  c
