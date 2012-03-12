directionsService = new google.maps.DirectionsService()
map = null
origin = null
destination = null
waypoints = []
markers = []
directionsVisible = false
wayPointLat = []
wayPointLng = []
i = 0
latstart = 0
latend = 0
lngstart = 0
lngend = 0
geocoder = null
request = null
directionsDisplay = null

  initialize: ->
    chicago = new google.maps.LatLng 37.7749295, -122.4194155
    myOptions =
      zoom: 13
      mapTypeId: google.maps.MapTypeId.ROADMAP
      center: chicago

    util.map = new google.maps.Map document.getElementById("map_canvas"),
      myOptions
    util.directionsDisplay.setMap util.map
    util.directionsDisplay.setPanel document.getElementById("directionsPanel")
    google.maps.event.addListener util.map, "click", (event) ->
      if util.origin == null
        util.wayPointCount = 0
        util.origin = event.latLng
        util.addMarker util.origin
        latori = util.origin.lat()
        lngori = util.origin.lng()
      else if util.destination == null
        util.destination = event.latLng
        latdest = util.destination.lat()
        lngdest = util.destination.lng()
        util.addMarker util.destination
      else
        if util.waypoints.length < 9
          util.waypoints.push {location: util.destination, stopover: true}
          util.destination = event.latLng
          util.wayPointCount = util.waypoints.length
          util.wayPointLat[wayPointCount] = util.destination.lat()
          util.wayPointLng[wayPointLng] = util.destination.lng()
          util.addMarker(util.destination)
        else
          alert("Maximum number of waypoints reached");

  getLatLng: ->
    util.addressStart = document.getElementById("start").value

    util.latStart = ""
    util.lngStart = ""
    util.latEnd = ""
    util.lngEnd = ""

    util.geocoder.geocode {address: util.addressStart}, (results, status) ->
      if status == google.maps.GeocoderStatus.OK
        loc = util.parseLocation results[0].geometry.location
        util.latStart = loc[0]
        util.lngStart = loc[1]

        if util.latEnd != ""
          util.drawRoute()

    util.addressEnd = document.getElementById("end").value
    util.geocoder.geocode {address: util.addressEnd}, (results, status) ->
      if status == google.maps.GeocoderStatus.OK
        loc = util.parseLocation results[0].geometry.location
        util.latEnd = loc[0]
        util.lngEnd = loc[1]

        if util.latStart != ""
          util.drawRoute()

  getRouteDistance: (origin, destination) ->
    distanceMatrixService = new google.maps.DistanceMatrixService()
    distanceMatrixService.getDistanceMatrix {
      origins: [origin, util.addressStart]
      destinations: [destination, util.addressEnd]
      travelMode: google.maps.TravelMode.DRIVING
      avoidHighways: false
      avoidTolls: false
    }, (response, status) ->
      if status == google.maps.DistanceMatrixStatus.OK
        return [response.rows[0].elements[0].distance.value,
            response.rows[0].elements[0].duration.value]

  parseLocation: (location) ->
    lat = location.lat().toString().substr 0, 12
    lng = location.lng().toString().substr 0, 12
    return [lat, lng]

  addMarker: (latlng) ->
    util.markers.push new google.maps.Marker {
      position: latlng
      map: util.map
      icon: "http://maps.google.com/mapfiles/marker" +
          "#{String.fromCharCode util.markers.length + 65}.png"
    }

  calcRoute: ->
    origin = document.getElementById("start").value
    destination = document.getElementById("end").value

    util.request = {
      origin: origin
      destination: destination
      waypoints: util.waypoints
      travelMode: google.maps.DirectionsTravelMode.DRIVING
      optimizeWaypoints: document.getElementById("optimize").checked
    }

    util.getLatLng origin
    util.getLatLng destination

  directionsService.route request, (response, status) ->
    if status == google.maps.DirectionsStatus.OK
      directionsDisplay.setDirections response

  # This function requires the origin and destination to be set.
  drawRoute: ->
    console.log util.latStart
    console.log util.latEnd
    console.log util.lngStart
    console.log util.lngEnd

    directionsService = new google.maps.DirectionsService()
    directionsService.route util.request, (response, status) ->
      if status == google.maps.DirectionsStatus.OK
        util.directionsDisplay.setDirections response

clearWaypoints = ->
  markers = []
  origin = null
  destination = null
  waypoints = []
  directionsVisible = false
  wayPointLat = []
  wayPointLng = []

    util.clearMarkers()

    util.routeDistance = util.getRouteDistance new google.maps.LatLng(
      util.latStart, util.lngStart),
      new google.maps.LatLng(util.latEnd, util.lngEnd)

  clearMarkers: ->
    for marker in util.markers
      marker.setMap null

  clearWaypoints: ->
    util.markers = []
    util.origin = null
    util.destination = null
    util.waypoints = []
    util.wayPointLat = []
    util.wayPointLng = []

  reset: ->
    util.clearMarkers()
    util.clearWaypoints()
    util.directionsDisplay.setMap null
    util.directionsDisplay.setPanel null
    util.directionsDisplay = new google.maps.DirectionsRenderer()
    util.directionsDisplay.setMap util.map
    util.directionsDisplay.setPanel document.getElementById("directionsPanel")

  buildRouteHash: (cordinates) ->
    sortedCordinates = util.sortCordinatesArray cordinates

    hashableString = concat cordinate for cordinate in sortedCordinates

    return Crypto.SHA1 hashableString

  # TODO(shlee) bring this function over and cleanup.
  sortCordinatesArray:  (cordinates) ->
    sortedCordinates = []
    originaLength = cordinates.length

  randomBetween: (x, y) ->
    return Math.random() * Math.abs(x - y) + Math.min(x, y)

  addRandomWaypoint: (p, q, deviationRange) ->
    # Use slope intercept form to get equation
    # Then calculate the newY.
    # y = mx + b
    # b = y - mx
    lineSlope = util.slopeOfLine p, q
    b = p[1] - lineSlope * p[0]

    # Now put b back in the equation using newX to get newY.
    # y = mx + b
    newX = util.randomBetween p[0], q[0]
    newY = lineSlope * newX + b

    # Now we need to get a perpendicular line of the equation going through
    # point newX, newY
    invertedLineSlope = -1 * (1 / lineSlope)
    b = newY - invertedLineSlope * newX
    newX = util.randomBetween(
        newX, newX + deviationRange * 2) - deviationRange
    newY = invertedLineSlope * newX + b

    return [newX, newY]

  slopeOfLine: (p, q) ->
    y = q[1] - p[1]
    x = q[0] - p[0]

  updateMode: ->
    travelmode = document.getElementById("travelmode").value
    travel = []
    #get the selected travel mode
    if travelmode == "DRIVING"
     travel = google.maps.DirectionsTravelMode.DRIVING
    else if travelmode == "WALKING"
     travel = google.maps.DirectionsTravelMode.WALKING
    else if travelmode == "BICYCLING"
     travel = google.maps.DirectionsTravelMode.BICYCLING
    return travel

  showUpdate: ->
    newWayPoint = util.addRandomWaypoint(
        [util.latStart, util.lngStart],
        [util.latEnd, util.lngEnd],
        0.01)

    myLatlng = new google.maps.LatLng newWayPoint[0], newWayPoint[1]

    util.waypoints.push { location: myLatlng, stopover: true }

    util.calcRoute()
}
