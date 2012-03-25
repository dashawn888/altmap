destination = null
directionsDisplay = null
directionsService = null
directionsVisible = false
distanceMatrixService = null
geocoder = null
latEnd = null
latStart = null
lngEnd = null
lngStart = null
map = null
markers = []
maxDelay = null
myOptions = null
origin = null
request = null
routeDistances = []
travelMode = google.maps.TravelMode.DRIVING
travelMode = null
wayPointCount = 0
wayPointLat = []
wayPointLng = []
wayPoints = []

window.util = {}

window.util.init = ->
    chicago = new google.maps.LatLng 37.7749295, -122.4194155
    myOptions =
        zoom: 13
        mapTypeId: google.maps.MapTypeId.ROADMAP
        center: chicago

    destination = null
    directionsDisplay = new google.maps.DirectionsRenderer()
    directionsService = new google.maps.DirectionsService()
    directionsVisible = false
    distanceMatrixService = new google.maps.DistanceMatrixService()
    geocoder = new google.maps.Geocoder()
    latEnd = 0
    latStart = 0
    lngEnd = 0
    lngStart = 0
    map = new google.maps.Map document.getElementById("map_canvas"),
        myOptions
    markers = []
    maxDelay = 0
    origin = null
    request = null
    routeDistances = []
    travelMode = google.maps.TravelMode.DRIVING
    wayPointCount = 0
    wayPointLat = []
    wayPointLng = []
    wayPoints = []

    directionsDisplay.setMap map
    directionsDisplay.setPanel document.getElementById("directionsPanel")
    google.maps.event.addListener map, "click", (event) ->
        if origin == null
            wayPointCount = 0
            origin = event.latLng
            addMarker origin
            latori = origin.lat()
            lngori = origin.lng()
        else if destination == null
            destination = event.latLng
            latdest = destination.lat()
            lngdest = destination.lng()
            addMarker destination
        else
            if wayPoints.length < 9
                wayPoints.push {location: destination, stopover: true}
                destination = event.latLng
                wayPointCount = wayPoints.length
                wayPointLat[wayPointCount] = destination.lat()
                wayPointLng[wayPointLng] = destination.lng()
                addMarker(destination)
            else
                alert("Maximum number of way points reached");

window.util.setMode = ->
    mode = document.getElementById("travelmode").value
    travel = []
    # Get the selected travel mode.
    if mode == "DRIVING"
        travelMode = google.maps.DirectionsTravelMode.DRIVING
    else if mode == "WALKING"
        travelMode = google.maps.DirectionsTravelMode.WALKING
    else if mode == "BICYCLING"
        travelMode = google.maps.DirectionsTravelMode.BICYCLING

window.util.setDelay = ->
    maxDelay = parseInt(document.getElementById("maxdelay").value) * 60

# This function requires the origin and destination to be set.
window.util.drawRoute = (wayPointLatLng=null) ->
    origin = document.getElementById("start").value
    destination = document.getElementById("end").value

    wayPoints = []    
    if wayPointLatLng != null
        wayPoints.push({
            location: wayPointLatLng
            stopover: true
            })

    request = {
        origin: origin
        destination: destination
        travelMode: travelMode
        waypoints: wayPoints
        avoidHighways: false
        avoidTolls: false}
    directionsService.route request, (response, status) ->
        if status == google.maps.DirectionsStatus.OK
            directionsDisplay.setDirections response

window.util.findRoute = ->
    origin = document.getElementById("start").value
    destination = document.getElementById("end").value
    
    origin_loc = null
    destination_loc = null

    withLatLng origin, (loc) ->
        origin_loc = loc

        if destination_loc != null
            getDestinations origin_loc, destination_loc

    withLatLng destination, (loc) ->
        destination_loc = loc

        if origin_loc != null
            getDestinations origin_loc, destination_loc

getDestinations = (origin, destination) ->
    found = false
    MAX_ROUTES = 20
    originalDuration = null
    routes = []
    routesRequested = 0

    # Get the original route time
    withRouteDistance(
        origin,
        destination,
        [],
        (distance, duration, wayPointLatLng) ->
            originalDuration = duration

            for _ in [0..MAX_ROUTES]
                withRandomWayPoint(
                    origin,
                    destination,
                    (wayPoint) -> 
                        # Just skip through the rest if it's found.
                        if not found
                            withRouteDistance(
                                origin,
                                destination,
                                wayPoint,
                                (distance, duration, wayPointLatLng) ->
                                    routesRequested += 1
                                    if not found and 
                                      duration - maxDelay < originalDuration
                                        found = true
                                        window.util.drawRoute wayPointLatLng
                                    else if not found and
                                      routesRequested == MAX_ROUTES
                                        alert("No route found.")
                            )
                )
    )

# Done with all the exposed functionality.
withLatLng = (address, func) ->
    geocoder.geocode {address: address}, (results, status) ->
        if status == google.maps.GeocoderStatus.OK
            loc = parseLocation results[0].geometry.location
            func(loc)

withRouteDistance = (origin, destination, wayPoint, func) ->
    originLatLng = new google.maps.LatLng(origin[0], origin[1])
    destinationLatLng = new google.maps.LatLng(destination[0], destination[1])
    wayPointLatLng = new google.maps.LatLng(wayPoint[0], wayPoint[1])

    # The distanceMatrixService measures the driving distance between 2 points.
    # With a wayPoint you have to calculate the distance twice.  Between origin
    # to wayPoint and wayPoint to Destination.  Then you sum them together to
    # get the total time.
    if wayPoint.length != 2
        distanceMatrixService.getDistanceMatrix {
            origins: [originLatLng]
            destinations: [destinationLatLng]
            travelMode: travelMode
            avoidHighways: false
            avoidTolls: false}, 
            (response, status) ->
                if status == google.maps.DistanceMatrixStatus.OK
                    func(
                        response.rows[0].elements[0].distance.value,
                        response.rows[0].elements[0].duration.value,
                        wayPointLatLng)
                else
                    console.log("DistanceMatrixStatus FAIL")
    else
        originToWayPoint = null
        wayPointToDestination = null

        distanceMatrixService.getDistanceMatrix {
            origins: [originLatLng]
            destinations: [wayPointLatLng]
            travelMode: travelMode
            avoidHighways: false
            avoidTolls: false}, 
            (response, status) ->
                if status == google.maps.DistanceMatrixStatus.OK
                    originToWayPoint = [
                        response.rows[0].elements[0].distance.value,
                        response.rows[0].elements[0].duration.value]

                    if wayPointToDestination != null
                        func(
                            originToWayPoint[0] + wayPointToDestination[0], 
                            originToWayPoint[1] + wayPointToDestination[1],
                            wayPointLatLng)
                else
                    console.log("DistanceMatrixStatus FAIL")
        
        distanceMatrixService.getDistanceMatrix {
            origins: [wayPointLatLng]
            destinations: [destinationLatLng]
            travelMode: travelMode
            avoidHighways: false
            avoidTolls: false}, 
            (response, status) ->
                if status == google.maps.DistanceMatrixStatus.OK
                    wayPointToDestination = [
                        response.rows[0].elements[0].distance.value,
                        response.rows[0].elements[0].duration.value]

                    if originToWayPoint != null
                        func(
                            originToWayPoint[0] + wayPointToDestination[0], 
                            originToWayPoint[1] + wayPointToDestination[1],
                            wayPointLatLng)
                else
                    console.log("DistanceMatrixStatus FAIL")

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

withRoute = (origin, destination, func, wayPoints=null) ->
    if wayPoints == null
        wayPoints = []

    request = {
        origin: origin
        destination: destination
        waypoints: wayPoints
        travelMode: travelMode
        optimizeWaypoints: document.getElementById("optimize").checked
    }

    latStart = ""
    lngStart = ""
    latEnd = ""
    lngEnd = ""

    withLatLng origin, (loc) ->
        latStart = loc[0]
        lngStart = loc[1]

        if latEnd != ""
            func()

    withLatLng destination, (loc) ->
        latEnd = loc[0]
        lngEnd = loc[1]

        if latStart != ""
            func()

randomBetween = (x, y) ->
   return Math.random() * Math.abs(x - y) + Math.min(x, y)

withRandomWayPoint = (origin, destination, func) ->
    # Use slope intercept form to get equation. Then calculate the newY.
    # y = mx + b
    # b = y - mx
    lineSlope = slopeOfLine origin, destination
    b = origin[1] - lineSlope * origin[0]

    # Now put b back in the equation using newX to get newY.
    # y = mx + b
    newX = randomBetween origin[0], destination[0]
    newY = lineSlope * newX + b

    # Now we need to get a perpendicular line of the equation going through
    # point newX, newY.
    invertedLineSlope = -1 * (1 / lineSlope)
    b = newY - invertedLineSlope * newX
    newX = randomBetween(
        newX, newX + 0.1 * 2) - 0.1
    newY = invertedLineSlope * newX + b

    func([newX, newY])

slopeOfLine = (p, q) ->
    y = q[1] - p[1]
    x = q[0] - p[0]
    return y / x