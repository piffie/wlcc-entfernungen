async = require('async')
_ = require('underscore')._


demofile = [{
  "connections": [
    {from:1234, to: 1235, time: 2}
    {from:1235, to:1236, time:2}
    {from:1236, to:1237, time:2}
    {from:1237, to:1238, time:2}
    {from:1238, to:1239, time:2}
  ]
  "lineName": "ASTAX 19A"
  "stops": [{
    id: 1234
    name: "1234"
  }
  {id:1235, name:"1235"}
    {id:1236, name:"1236"}
    {id:1237, name:"1237"}
    {id:1238, name:"1238"}
    {id:1239, name:"1239"}
  ]
  "lineType": "ASTAX"
}]

class Pathfinder
  constructor: () ->
    @stops = {}
    @travelTimes = []

  Init: (complete) ->
    @loadNodes demofile, () =>
      console.log(@stops)
      @calculateTimes(complete)

  loadNodes: (lines, complete) ->
    _.each lines, (line)=>
      _.each line.stops, (stop)=>
        node = @stops[stop.id]
        if !node?
          node = _.clone(stop)
          node.connections = []
          @stops[stop.id] = node
      _.each line.connections, (connection)=>
        node = @stops[connection.from]
        con = _.clone(connection)
        con.line = line.name
        node.connections.push con
    complete()

  calculateTimes: (complete) ->
    @travelTimes = []
    console.log('calc times')
    stops = _.toArray(@stops)
    async.forEach(stops, @calculateTravelTime, complete)

  calculateTravelTime: (stop, complete) =>
    #console.log(stop.connections)
    _.each stop.connections, (connection) =>
      @travelTimes.push {
        from: stop.id
        to: connection.to
        time: connection.time
      }
      console.log('startconnection added ' + connection.to)
      @followConnections [stop.id], connection, stop.id, connection.time,
    complete()

  followConnections: (path, connectionFrom, startid, time) =>
    stop = @stops[connectionFrom.to]
    _.each stop.connections, (connection) =>
      if path.indexOf(connection.to) > -1
        return
      newTime = time + connection.time
      if connection.line != connectionFrom.line
        newTime = newTime + 3
      newPath = _.clone(path)
      newPath.push(stop.id)
      @travelTimes.push {
        from: startid
        to: connection.to
        time: newTime
        path: newPath
      }
      console.log('connection added ' + startid + ' to ' + connection.to + ' time: ' + newTime)
      @followConnections newPath, connection, startid, newTime

module.exports = Pathfinder