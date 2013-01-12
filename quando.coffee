request = require('request')
cheerio = require('cheerio')
haltestellen = require('./haltestellenwien');
umgebungsReq = '<?xml version="1.0" encoding="UTF-8"?><ft><request clientId="123" apiName="api_search_location_stops_nearby" apiVersion="2.0"> <client clientId="123"/>        <requestType>api_search_location_stops_nearby</requestType>         <outputCoords>WGS84</outputCoords>         <fromCoordName>WGS84</fromCoordName>         <fromType>coords</fromType>     <fromWgs84Lat>{{lat}}</fromWgs84Lat>     <fromWgs84Lon>{{long}}</fromWgs84Lon>     </request> </ft>';
stopReq = '<?xml version="1.0" encoding="UTF-8"?><ft>    <request clientId="123" apiName="api_get_monitor" apiVersion="2.0">        <client clientId="123"/>        <requestType>api_get_monitor</requestType>        <monitor>            <outputCoords>WGS84</outputCoords>            <type>stop</type>            <name>{{stop}}</name>            <year>2012</year>            <month>01</month>            <day>11</day>            <hour>08</hour>            <minute>00</minute>            <line></line>            <sourceFrom>stoplist</sourceFrom>        </monitor>    </request></ft>'

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

#<line name="U1" type="ptMetro" towards="Leopoldau" direction="H" platform="U1_H" barrierFree="1" realtimeSupported="1">

  reqQuando: (reqData, complete) ->
    request.post 'http://webservice.qando.at/2.0/webservice.ft', {body: reqData },  (error, response, body) ->
      if !error && response.statusCode == 200
        complete(null, body)
      else
        console.log('error request' + error)
        complete(error, null)



module.exports = Quando