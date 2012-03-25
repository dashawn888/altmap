(function() {
  var addMarker, destination, directionsDisplay, directionsService, directionsVisible, distanceMatrixService, geocoder, getDestinations, latEnd, latStart, lngEnd, lngStart, map, markers, maxDelay, myOptions, origin, parseLocation, randomBetween, request, routeDistances, slopeOfLine, travelMode, wayPointCount, wayPointLat, wayPointLng, wayPoints, withLatLng, withRandomWayPoint, withRoute, withRouteDistance;

  destination = null;

  directionsDisplay = null;

  directionsService = null;

  directionsVisible = false;

  distanceMatrixService = null;

  geocoder = null;

  latEnd = null;

  latStart = null;

  lngEnd = null;

  lngStart = null;

  map = null;

  markers = [];

  maxDelay = null;

  myOptions = null;

  origin = null;

  request = null;

  routeDistances = [];

  travelMode = google.maps.TravelMode.DRIVING;

  travelMode = null;

  wayPointCount = 0;

  wayPointLat = [];

  wayPointLng = [];

  wayPoints = [];

  window.util = {};

  window.util.init = function() {
    var chicago;
    chicago = new google.maps.LatLng(37.7749295, -122.4194155);
    myOptions = {
      zoom: 13,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      center: chicago
    };
    destination = null;
    directionsDisplay = new google.maps.DirectionsRenderer();
    directionsService = new google.maps.DirectionsService();
    directionsVisible = false;
    distanceMatrixService = new google.maps.DistanceMatrixService();
    geocoder = new google.maps.Geocoder();
    latEnd = 0;
    latStart = 0;
    lngEnd = 0;
    lngStart = 0;
    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
    markers = [];
    maxDelay = 0;
    origin = null;
    request = null;
    routeDistances = [];
    travelMode = google.maps.TravelMode.DRIVING;
    wayPointCount = 0;
    wayPointLat = [];
    wayPointLng = [];
    wayPoints = [];
    directionsDisplay.setMap(map);
    directionsDisplay.setPanel(document.getElementById("directionsPanel"));
    return google.maps.event.addListener(map, "click", function(event) {
      var latdest, latori, lngdest, lngori;
      if (origin === null) {
        wayPointCount = 0;
        origin = event.latLng;
        addMarker(origin);
        latori = origin.lat();
        return lngori = origin.lng();
      } else if (destination === null) {
        destination = event.latLng;
        latdest = destination.lat();
        lngdest = destination.lng();
        return addMarker(destination);
      } else {
        if (wayPoints.length < 9) {
          wayPoints.push({
            location: destination,
            stopover: true
          });
          destination = event.latLng;
          wayPointCount = wayPoints.length;
          wayPointLat[wayPointCount] = destination.lat();
          wayPointLng[wayPointLng] = destination.lng();
          return addMarker(destination);
        } else {
          return alert("Maximum number of way points reached");
        }
      }
    });
  };

  window.util.setMode = function() {
    var mode, travel;
    mode = document.getElementById("travelmode").value;
    travel = [];
    if (mode === "DRIVING") {
      return travelMode = google.maps.DirectionsTravelMode.DRIVING;
    } else if (mode === "WALKING") {
      return travelMode = google.maps.DirectionsTravelMode.WALKING;
    } else if (mode === "BICYCLING") {
      return travelMode = google.maps.DirectionsTravelMode.BICYCLING;
    }
  };

  window.util.setDelay = function() {
    return maxDelay = parseInt(document.getElementById("maxdelay").value) * 60;
  };

  window.util.drawRoute = function(wayPointLatLng) {
    if (wayPointLatLng == null) wayPointLatLng = null;
    origin = document.getElementById("start").value;
    destination = document.getElementById("end").value;
    wayPoints = [];
    if (wayPointLatLng !== null) {
      wayPoints.push({
        location: wayPointLatLng,
        stopover: true
      });
    }
    request = {
      origin: origin,
      destination: destination,
      travelMode: travelMode,
      waypoints: wayPoints,
      avoidHighways: false,
      avoidTolls: false
    };
    return directionsService.route(request, function(response, status) {
      if (status === google.maps.DirectionsStatus.OK) {
        return directionsDisplay.setDirections(response);
      }
    });
  };

  window.util.findRoute = function() {
    var destination_loc, origin_loc;
    origin = document.getElementById("start").value;
    destination = document.getElementById("end").value;
    origin_loc = null;
    destination_loc = null;
    withLatLng(origin, function(loc) {
      origin_loc = loc;
      if (destination_loc !== null) {
        return getDestinations(origin_loc, destination_loc);
      }
    });
    return withLatLng(destination, function(loc) {
      destination_loc = loc;
      if (origin_loc !== null) return getDestinations(origin_loc, destination_loc);
    });
  };

  getDestinations = function(origin, destination) {
    var MAX_ROUTES, found, originalDuration, routes, routesRequested;
    routes = [];
    originalDuration = null;
    MAX_ROUTES = 20;
    found = false;
    routesRequested = 0;
    return withRouteDistance(origin, destination, [], function(distance, duration, wayPointLatLng) {
      var _, _results;
      originalDuration = duration;
      _results = [];
      for (_ = 0; 0 <= MAX_ROUTES ? _ <= MAX_ROUTES : _ >= MAX_ROUTES; 0 <= MAX_ROUTES ? _++ : _--) {
        _results.push(withRandomWayPoint(origin, destination, function(wayPoint) {
          if (!found) {
            return withRouteDistance(origin, destination, wayPoint, function(distance, duration, wayPointLatLng) {
              routesRequested += 1;
              if (!found && duration - maxDelay < originalDuration) {
                found = true;
                return window.util.drawRoute(wayPointLatLng);
              } else if (!found && routesRequested === MAX_ROUTES) {
                return alert("No route found.");
              }
            });
          }
        }));
      }
      return _results;
    });
  };

  withLatLng = function(address, func) {
    return geocoder.geocode({
      address: address
    }, function(results, status) {
      var loc;
      if (status === google.maps.GeocoderStatus.OK) {
        loc = parseLocation(results[0].geometry.location);
        return func(loc);
      }
    });
  };

  withRouteDistance = function(origin, destination, wayPoint, func) {
    var destinationLatLng, originLatLng, originToWayPoint, wayPointLatLng, wayPointToDestination;
    originLatLng = new google.maps.LatLng(origin[0], origin[1]);
    destinationLatLng = new google.maps.LatLng(destination[0], destination[1]);
    wayPointLatLng = new google.maps.LatLng(wayPoint[0], wayPoint[1]);
    if (wayPoint.length !== 2) {
      return distanceMatrixService.getDistanceMatrix({
        origins: [originLatLng],
        destinations: [destinationLatLng],
        travelMode: travelMode,
        avoidHighways: false,
        avoidTolls: false
      }, function(response, status) {
        if (status === google.maps.DistanceMatrixStatus.OK) {
          return func(response.rows[0].elements[0].distance.value, response.rows[0].elements[0].duration.value, wayPointLatLng);
        } else {
          return console.log("DistanceMatrixStatus FAIL");
        }
      });
    } else {
      originToWayPoint = null;
      wayPointToDestination = null;
      distanceMatrixService.getDistanceMatrix({
        origins: [originLatLng],
        destinations: [wayPointLatLng],
        travelMode: travelMode,
        avoidHighways: false,
        avoidTolls: false
      }, function(response, status) {
        if (status === google.maps.DistanceMatrixStatus.OK) {
          originToWayPoint = [response.rows[0].elements[0].distance.value, response.rows[0].elements[0].duration.value];
          if (wayPointToDestination !== null) {
            return func(originToWayPoint[0] + wayPointToDestination[0], originToWayPoint[1] + wayPointToDestination[1], wayPointLatLng);
          }
        } else {
          return console.log("DistanceMatrixStatus FAIL");
        }
      });
      return distanceMatrixService.getDistanceMatrix({
        origins: [wayPointLatLng],
        destinations: [destinationLatLng],
        travelMode: travelMode,
        avoidHighways: false,
        avoidTolls: false
      }, function(response, status) {
        if (status === google.maps.DistanceMatrixStatus.OK) {
          wayPointToDestination = [response.rows[0].elements[0].distance.value, response.rows[0].elements[0].duration.value];
          if (originToWayPoint !== null) {
            return func(originToWayPoint[0] + wayPointToDestination[0], originToWayPoint[1] + wayPointToDestination[1], wayPointLatLng);
          }
        } else {
          return console.log("DistanceMatrixStatus FAIL");
        }
      });
    }
  };

  parseLocation = function(location) {
    var lat, lng;
    lat = location.lat().toString().substr(0, 12);
    lng = location.lng().toString().substr(0, 12);
    return [lat, lng];
  };

  addMarker = function(latlng) {
    return markers.push(new google.maps.Marker({
      position: latlng,
      map: map,
      icon: "http://maps.google.com/mapfiles/marker" + ("" + (String.fromCharCode(markers.length + 65)) + ".png")
    }));
  };

  withRoute = function(origin, destination, func, wayPoints) {
    if (wayPoints == null) wayPoints = null;
    if (wayPoints === null) wayPoints = [];
    request = {
      origin: origin,
      destination: destination,
      waypoints: wayPoints,
      travelMode: travelMode,
      optimizeWaypoints: document.getElementById("optimize").checked
    };
    latStart = "";
    lngStart = "";
    latEnd = "";
    lngEnd = "";
    withLatLng(origin, function(loc) {
      latStart = loc[0];
      lngStart = loc[1];
      if (latEnd !== "") return func();
    });
    return withLatLng(destination, function(loc) {
      latEnd = loc[0];
      lngEnd = loc[1];
      if (latStart !== "") return func();
    });
  };

  randomBetween = function(x, y) {
    return Math.random() * Math.abs(x - y) + Math.min(x, y);
  };

  withRandomWayPoint = function(origin, destination, func) {
    var b, invertedLineSlope, lineSlope, newX, newY;
    lineSlope = slopeOfLine(origin, destination);
    b = origin[1] - lineSlope * origin[0];
    newX = randomBetween(origin[0], destination[0]);
    newY = lineSlope * newX + b;
    invertedLineSlope = -1 * (1 / lineSlope);
    b = newY - invertedLineSlope * newX;
    newX = randomBetween(newX, newX + 0.1 * 2) - 0.1;
    newY = invertedLineSlope * newX + b;
    return func([newX, newY]);
  };

  slopeOfLine = function(p, q) {
    var x, y;
    y = q[1] - p[1];
    x = q[0] - p[0];
    return y / x;
  };

}).call(this);
