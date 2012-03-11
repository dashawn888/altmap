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

initialize = ->
  directionsDisplay = new google.maps.DirectionsRenderer()
  chicago = new google.maps.LatLng 37.7749295, -122.4194155
  myOptions =
    zoom: 13
    mapTypeId: google.maps.MapTypeId.ROADMAP
    center: chicago

  map = new google.maps.Map document.getElementById("map_canvas"), myOptions
  directionsDisplay.setMap map
  directionsDisplay.setPanel document.getElementById("directionsPanel")
  geocoder = new google.maps.Geocoder()
  google.maps.event.addListener map, 'click', (event) ->
    if origin == null
      i = 0
      origin = event.latLng
      addMarker origin
      latori = origin.lat()
      lngori = origin.lng()
    else if destination == null
      destination = event.latLng
      latdest = destination.lat()
      lngdest = destination.lng()
      addMarker(destination)
    else
      if waypoints.length < 9
        waypoints.push {location: destination, stopover: true}
        destination = event.latLng
        i = waypoints.length
        wayPointLat[i] = destination.lat()
        wayPointLng[i] = destination.lng()
        addMarker(destination)
      else
        alert("Maximum number of waypoints reached");

getLatLng = ->
  addressStart = document.getElementById("start").value

  latstart = ""
  lngstart = ""
  latend = ""
  lngend = ""

  geocoder.geocode {'address': addressStart}, (results, status) ->
    if status == google.maps.GeocoderStatus.OK
      loc = parseLocation results[0].geometry.location
      latstart = loc[0]
      lngstart = loc[1]

      if latend != ""
        drawRoute()

  addressEnd = document.getElementById("end").value
  geocoder.geocode {'address': addressEnd}, (results, status) ->
    if status == google.maps.GeocoderStatus.OK
      loc = parseLocation results[0].geometry.location
      latend = loc[0]
      lngend = loc[1]

      if latstart != ""
        drawRoute()

parseLocation = (location) ->
  lat = location.lat().toString().substr 0, 12
  lng = location.lng().toString().substr 0, 12
  return [lat, lng]

addMarker = (latlng) ->
  markers.push new google.maps.Marker {
    position: latlng
    map: map
    icon: "http://maps.google.com/mapfiles/marker" +
        "#{String.fromCharCode markers.length + 65}.png"
  }

calcRoute = ->
  origin = document.getElementById("start").value
  destination = document.getElementById("end").value
selectedMode = document.getElementById("mode").value;

  request = {
    origin: origin
    destination: destination
    waypoints: waypoints
    travelMode: google.maps.DirectionsTravelMode[selectedMode]
    optimizeWaypoints: document.getElementById('optimize').checked
  }

  getLatLng origin
  getLatLng destination

drawRoute = ->
  console.log latstart
  console.log latend
  console.log lngstart
  console.log lngend

  directionsService.route request, (response, status) ->
    if status == google.maps.DirectionsStatus.OK
      directionsDisplay.setDirections response

  clearMarkers()
  directionsVisible = true

clearMarkers = ->
  for marker in markers
    marker.setMap null

clearWaypoints = ->
  markers = []
  origin = null
  destination = null
  waypoints = []
  directionsVisible = false
  wayPointLat = []
  wayPointLng = []

reset = ->
  clearMarkers()
  clearWaypoints()
  directionsDisplay.setMap null
  directionsDisplay.setPanel null
  directionsDisplay = new google.maps.DirectionsRenderer()
  directionsDisplay.setMap map
  directionsDisplay.setPanel document.getElementById("directionsPanel")

buildRouteHash = (cordinates) ->
  sortedCordinates = sortCordinatesArray cordinates

  hashableString = concat cordinate for cordinate in sortedCordinates

  return Crypto.SHA1 hashableString

# TODO(shlee) bring this function over and cleanup.
sortCordinatesArray = (cordinates) ->
  sortedCordinates = []
  originaLength = cordinates.length

randomBetween = (x, y) ->
  larger = 0
  smaller = 0

  if x > y
    larger = x
    smaller = y
  else
    larger = y
    smaller = x

  delta = larger - smaller

  randomDelta = Math.random() * delta
  return larger - randomDelta

addRandomWaypoint = (p, q, deviationRange) ->
  # Use slope intercept form to get equation
  # Then calculate the newY.
  # y = mx + b
  # b = y - mx
  lineSlope = slopeOfLine p, q
  b = p[1] - lineSlope * p[0]

  # Now put b back in the equation using newX to get newY.
  # y = mx + b
  newX = randomBetween p[0], q[0]
  newY = lineSlope * newX + b

  # Now we need to get a perpendicular line of the equation going through
  # point newX, newY
  invertedLineSlope = -1 * (1 / lineSlope)
  b = newY - invertedLineSlope * newX
  newX = randomBetween(
      newX, newX + deviationRange * 2) - deviationRange
  newY = invertedLineSlope * newX + b

  return [newX, newY]

slopeOfLine = (p, q) ->
  y = q[1] - p[1]
  x = q[0] - p[0]

  return y / x

showUpdate = ->
  newWayPoint = addRandomWaypoint(
      [latstart, lngstart],
      [latend, lngend],
      0.01)

  myLatlng = new google.maps.LatLng newWayPoint[0], newWayPoint[1]

  waypoints.push { location: myLatlng, stopover: true }

  calcRoute()
