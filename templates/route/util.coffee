util = {
  initialize: ->
    chicago = new google.maps.LatLng 37.7749295, -122.4194155
    myOptions =
      zoom: 13
      mapTypeId: google.maps.MapTypeId.ROADMAP
      center: chicago

    util.destination = null
    util.directionsDisplay = new google.maps.DirectionsRenderer()
    util.directionsService = new google.maps.DirectionsService()
    util.directionsVisible = false
    util.distanceMatrixService = new google.maps.DistanceMatrixService()
    util.geocoder = new google.maps.Geocoder()
    util.latEnd = 0
    util.latStart = 0
    util.lngEnd = 0
    util.lngStart = 0
    util.map = new google.maps.Map document.getElementById("map_canvas"),
      myOptions
    util.markers = []
    util.origin = null
    util.request = null
    util.travelMode = google.maps.TravelMode.DRIVING
    util.wayPointCount = 0
    util.wayPointLat = []
    util.wayPointLng = []
    util.waypoints = []

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
    util.distanceMatrixService.getDistanceMatrix {
      origins: [origin, util.addressStart]
      destinations: [destination, util.addressEnd]
      travelMode: util.travelMode
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
      travelMode: util.travelMode
      optimizeWaypoints: document.getElementById("optimize").checked
    }

    util.getLatLng origin
    util.getLatLng destination

  # This function requires the origin and destination to be set.
  drawRoute: ->
    console.log util.latStart
    console.log util.latEnd
    console.log util.lngStart
    console.log util.lngEnd

    util.directionsService.route util.request, (response, status) ->
      if status == google.maps.DirectionsStatus.OK
        util.directionsDisplay.setDirections response

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
    # Use slope intercept form to get equation. Then calculate the newY.
    # y = mx + b
    # b = y - mx
    lineSlope = util.slopeOfLine p, q
    b = p[1] - lineSlope * p[0]

    # Now put b back in the equation using newX to get newY.
    # y = mx + b
    newX = util.randomBetween p[0], q[0]
    newY = lineSlope * newX + b

    # Now we need to get a perpendicular line of the equation going through
    # point newX, newY.
    invertedLineSlope = -1 * (1 / lineSlope)
    b = newY - invertedLineSlope * newX
    newX = util.randomBetween(
        newX, newX + deviationRange * 2) - deviationRange
    newY = invertedLineSlope * newX + b

    return [newX, newY]

  slopeOfLine: (p, q) ->
    y = q[1] - p[1]
    x = q[0] - p[0]
    return y / x

  updateMode: ->
    mode = document.getElementById("travelmode").value
    travel = []
    # Get the selected travel mode.
    if mode == "DRIVING"
     util.travelMode = google.maps.DirectionsTravelMode.DRIVING
    else if mode == "WALKING"
     util.travelMode = google.maps.DirectionsTravelMode.WALKING
    else if mode == "BICYCLING"
     util.travelMode = google.maps.DirectionsTravelMode.BICYCLING

    util.calcRoute()
    util.drawRoute()

  showUpdate: ->
    newWayPoint = util.addRandomWaypoint(
        [util.latStart, util.lngStart],
        [util.latEnd, util.lngEnd],
        0.01)

    myLatLng = new google.maps.LatLng newWayPoint[0], newWayPoint[1]

    util.waypoints.push { location: myLatLng, stopover: true }

    util.calcRoute()
}
