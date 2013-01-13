request = require('request')
cheerio = require('cheerio')
haltestellen = require('./haltestellenwien');
convert = require('data2xml')();

###
# doesnt work - only html (?)
util = require 'util'
batik = require 'batik'
dateTemplate = batik () ->
  @year   2013
  @month   "05"
  @day       6
  @hour      9
  @minute  "00"

util.puts dateTemplate()
###

umgebungsReq = '<?xml version="1.0" encoding="UTF-8"?><ft><request clientId="123" apiName="api_search_location_stops_nearby" apiVersion="2.0"> <client clientId="123"/>        <requestType>api_search_location_stops_nearby</requestType>         <outputCoords>WGS84</outputCoords>         <fromCoordName>WGS84</fromCoordName>         <fromType>coords</fromType>     <fromWgs84Lat>{{lat}}</fromWgs84Lat>     <fromWgs84Lon>{{long}}</fromWgs84Lon>     </request> </ft>';
stopReq = '<?xml version="1.0" encoding="UTF-8"?><ft>    <request clientId="123" apiName="api_get_monitor" apiVersion="2.0">        <client clientId="123"/>        <requestType>api_get_monitor</requestType>        <monitor>            <outputCoords>WGS84</outputCoords>            <type>stop</type>            <name>{{stop}}</name>            <year>2012</year>            <month>01</month>            <day>11</day>            <hour>08</hour>            <minute>00</minute>            <line></line>            <sourceFrom>stoplist</sourceFrom>        </monitor>    </request></ft>'

routeReqFromCoordBlock = '<from>Aktueller Standort</from><fromType>coords</fromType><fromCoordName>WGS84</fromCoordName><fromWgs84Lat>{{fromLat}}</fromWgs84Lat><fromWgs84Lon>{{fromLon}}</fromWgs84Lon>'
routeReqToStationBlock = '<to>60201040</to>        <toType>stop</toType>'
routeReq = '<?xml version="1.0" encoding="UTF-8"?> <ft>     <request clientId="{{clientId}}" apiName="api_get_route" apiVersion="2.0">         <client clientId="{{clientId}}"/>         <requestType>api_get_route</requestType>         <outputCoords>WGS84</outputCoords>        {{fromBlock}}        {{toBlock}}        {{when}}        <deparr>{{deparr}}</deparr>        <modality>pt</modality>        <sourceFrom>stoplist</sourceFrom>        <sourceTo>stoplist</sourceTo>    </request></ft>'
# sourceFrom gps
# deparr dep
class Quando
  constructor: () ->


  GetStationsByCoordinate: (long, lat) ->
    reqData = umgebungsReq.replace('{{lat}}', lat).replace('{{long}}', long);
    @reqQuando reqData, (err, data)->
      console.log data


  GetStationMonitor: (station) ->
    stop = station + 60200000
    reqData = stopReq.replace('{{stop}}', stop)
    @reqQuando reqData, (err, data)->
      #console.log data
      $ = cheerio.load(data, { ignoreWhitespace: true })
      console.log 'lines: ' +$('lines').attr('count')
      $('line').each (index, line) ->
        line = $(line)
        console.log {
          name: line.attr('name')
          towards: line.attr('towards')
          direction: line.attr('direction')
          barrierFree: line.attr('barrierFree')
        }


  GetRoute: (fromStop, toStop) ->
    # fromBlock = 48.22
    from =
      from : fromStop
      fromType: "stop"
    to =
      to : toStop
      toType : "stop"
    time =
      year :  2013
      month :  "05"
      day :      6
      hour :     9
      minute : "00"

    fromBlock = '<from>'+from.from+"</from><fromType>"+from.fromType+"</fromType>"
    toBlock   = '<to>'+to.to+"</to><toType>"+to.toType+"</toType>"
    whenBlock = '<year>'+time.year+'</year><month>'+time.month+'</month><day>'+time.day+'</day><hour>'+time.hour+'</hour><minute>'+time.minute+'</minute>'
    reqData = routeReq.replace('{{fromBlock}}', fromBlock)
    reqData = reqData.replace('{{toBlock}}', toBlock)
    reqData = reqData.replace('{{when}}', whenBlock)
    reqData = reqData.replace('{{clientId}}', 918273) # 123
    reqData = reqData.replace('{{clientId}}', 918273) # 123
    reqData = reqData.replace('{{deparr}}', "arr")
    console.log reqData
    @reqQuando reqData, (err, data)->
      console.log "DATA: " +data
      $ = cheerio.load(data, { ignoreWhitespace: true })
      console.log 'lines: ' +$('lines').attr('count')
      $('line').each (index, line) ->
        line = $(line)
        console.log {
        name: line.attr('name')
        towards: line.attr('towards')
        direction: line.attr('direction')
        barrierFree: line.attr('barrierFree')
        }

#<line name="U1" type="ptMetro" towards="Leopoldau" direction="H" platform="U1_H" barrierFree="1" realtimeSupported="1">

  reqQuando: (reqData, complete) ->
    request.post 'http://webservice.qando.at/2.0/webservice.ft', {body: reqData },  (error, response, body) ->
      if !error && response.statusCode == 200
        complete(null, body)
      else
        console.log('error request' + error)
        complete(error, null)



module.exports = Quando