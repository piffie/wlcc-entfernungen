app = require('express')()
Quando = require('./quando')
quando = new Quando()
Pathfinder = require('./pathfinder')
pathfinder = new Pathfinder()

#quando.GetStationsByCoordinate(16.389769898563777, 48.173790150890646)

#quando.GetStationMonitor(1)


app.get '/', (req, res) -> res.sendfile __dirname + '/index.html'

app.post '/scrape', (req, res) ->



app.listen(3000)

pathfinder.Init()
