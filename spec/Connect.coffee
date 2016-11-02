noflo = require 'noflo'
chai = require 'chai' unless chai
Connect = require '../components/Connect.coffee'

rabbitUrl = 'amqp://localhost'

describe 'Connect component', ->
  c = null
  url = null
  connection = null
  beforeEach ->
    c = Connect.getComponent()
    url = noflo.internalSocket.createSocket()
    connection = noflo.internalSocket.createSocket()
    c.inPorts.url.attach url
    c.outPorts.connection.attach connection

  describe 'connecting to an existing AMQP server', ->
    it 'should be able to connect', (done) ->
      groups = []
      connection.on 'begingroup', (group) ->
        groups.push group
      connection.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.createChannel).to.be.a 'function'
        data.close()
      connection.on 'disconnect', ->
        chai.expect(groups).to.eql [
          'foo'
          rabbitUrl
        ]
        done()

      url.beginGroup 'foo'
      url.send rabbitUrl
      url.endGroup()
      url.disconnect()
  describe 'connecting to a missing AMQP server', ->
    it 'should send error', (done) ->
      @timeout 10000
      error = noflo.internalSocket.createSocket()
      c.outPorts.error.attach error
      error.on 'data', (data) ->
        chai.expect(data).to.be.an.instanceOf Error
        done()
      url.send 'amqp://localhost:12345'
