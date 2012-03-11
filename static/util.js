var addMarker, addRandomWaypoint, buildRouteHash, calcRoute, clearMarkers, clearWaypoints, destination, directionsDisplay, directionsService, directionsVisible, drawRoute, geocoder, getLatLng, i, initialize, latend, latstart, lngend, lngstart, map, markers, origin, parseLocation, randomBetween, request, reset, showUpdate, slopeOfLine, sortCordinatesArray, wayPointLat, wayPointLng, waypoints;

directionsService = new google.maps.DirectionsService();

map = null;

origin = null;

destination = null;

waypoints = [];

markers = [];

directionsVisible = false;

wayPointLat = [];

wayPointLng = [];

i = 0;

latstart = 0;

latend = 0;

lngstart = 0;

lngend = 0;

geocoder = null;

request = null;

directionsDisplay = null;

initialize = function() {
  var chicago, myOptions;
  directionsDisplay = new google.maps.DirectionsRenderer();
  chicago = new google.maps.LatLng(37.7749295, -122.4194155);
  myOptions = {
    zoom: 13,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    center: chicago
  };
  map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
  directionsDisplay.setMap(map);
  directionsDisplay.setPanel(document.getElementById("directionsPanel"));
  geocoder = new google.maps.Geocoder();
  return google.maps.event.addListener(map, 'click', function(event) {
    var latdest, latori, lngdest, lngori;
    if (origin === null) {
      i = 0;
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
      if (waypoints.length < 9) {
        waypoints.push({
          location: destination,
          stopover: true
        });
        destination = event.latLng;
        i = waypoints.length;
        wayPointLat[i] = destination.lat();
        wayPointLng[i] = destination.lng();
        return addMarker(destination);
      } else {
        return alert("Maximum number of waypoints reached");
      }
    }
  });
};

getLatLng = function() {
  var addressEnd, addressStart;
  addressStart = document.getElementById("start").value;
  latstart = "";
  lngstart = "";
  latend = "";
  lngend = "";
  geocoder.geocode({
    'address': addressStart
  }, function(results, status) {
    var loc;
    if (status === google.maps.GeocoderStatus.OK) {
      loc = parseLocation(results[0].geometry.location);
      latstart = loc[0];
      lngstart = loc[1];
      if (latend !== "") return drawRoute();
    }
  });
  addressEnd = document.getElementById("end").value;
  return geocoder.geocode({
    'address': addressEnd
  }, function(results, status) {
    var loc;
    if (status === google.maps.GeocoderStatus.OK) {
      loc = parseLocation(results[0].geometry.location);
      latend = loc[0];
      lngend = loc[1];
      if (latstart !== "") return drawRoute();
    }
  });
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

calcRoute = function() {
  origin = document.getElementById("start").value;
  destination = document.getElementById("end").value;
  
  request = {
    origin: origin,
    destination: destination,
    waypoints: waypoints,
    travelMode: updateMode(),
    optimizeWaypoints: document.getElementById('optimize').checked
  };
  getLatLng(origin);
  return getLatLng(destination);
};

drawRoute = function() {
  console.log(latstart);
  console.log(latend);
  console.log(lngstart);
  console.log(lngend);
  directionsService.route(request, function(response, status) {
    if (status === google.maps.DirectionsStatus.OK) {
      return directionsDisplay.setDirections(response);
    }
  });
  clearMarkers();
  return directionsVisible = true;
};

clearMarkers = function() {
  var marker, _i, _len, _results;
  _results = [];
  for (_i = 0, _len = markers.length; _i < _len; _i++) {
    marker = markers[_i];
    _results.push(marker.setMap(null));
  }
  return _results;
};

clearWaypoints = function() {
  markers = [];
  origin = null;
  destination = null;
  waypoints = [];
  directionsVisible = false;
  wayPointLat = [];
  return wayPointLng = [];
};

reset = function() {
  clearMarkers();
  clearWaypoints();
  directionsDisplay.setMap(null);
  directionsDisplay.setPanel(null);
  directionsDisplay = new google.maps.DirectionsRenderer();
  directionsDisplay.setMap(map);
  return directionsDisplay.setPanel(document.getElementById("directionsPanel"));
};

buildRouteHash = function(cordinates) {
  var cordinate, hashableString, sortedCordinates, _i, _len;
  sortedCordinates = sortCordinatesArray(cordinates);
  for (_i = 0, _len = sortedCordinates.length; _i < _len; _i++) {
    cordinate = sortedCordinates[_i];
    hashableString = concat(cordinate);
  }
  return Crypto.SHA1(hashableString);
};

sortCordinatesArray = function(cordinates) {
  var originaLength, sortedCordinates;
  sortedCordinates = [];
  return originaLength = cordinates.length;
};

randomBetween = function(x, y) {
  var delta, larger, randomDelta, smaller;
  larger = 0;
  smaller = 0;
  if (x > y) {
    larger = x;
    smaller = y;
  } else {
    larger = y;
    smaller = x;
  }
  delta = larger - smaller;
  randomDelta = Math.random() * delta;
  return larger - randomDelta;
};

addRandomWaypoint = function(p, q, deviationRange) {
  var b, invertedLineSlope, lineSlope, newX, newY;
  lineSlope = slopeOfLine(p, q);
  b = p[1] - lineSlope * p[0];
  newX = randomBetween(p[0], q[0]);
  newY = lineSlope * newX + b;
  invertedLineSlope = -1 * (1 / lineSlope);
  b = newY - invertedLineSlope * newX;
  newX = randomBetween(newX, newX + deviationRange * 2) - deviationRange;
  newY = invertedLineSlope * newX + b;
  return [newX, newY];
};

slopeOfLine = function(p, q) {
  var x, y;
  y = q[1] - p[1];
  x = q[0] - p[0];
  return y / x;
};

updateMode =  function() {
  var travelmode = document.getElementById("travelmode").value;
  var travel=[];
// get the selected travel mode
if (travelmode == "DRIVING")
   travel = google.maps.DirectionsTravelMode.DRIVING;
else if (travelmode == "WALKING")
   travel = google.maps.DirectionsTravelMode.WALKING;
else if (travelmode == "BICYCLING")
   travel = google.maps.DirectionsTravelMode.BICYCLING;
  //console.log(travel);
   return travel;
};

showUpdate = function(travelmode) {
  var myLatlng, newWayPoint;
  newWayPoint = addRandomWaypoint([latstart, lngstart], [latend, lngend], 0.01);
  myLatlng = new google.maps.LatLng(newWayPoint[0], newWayPoint[1]);
  waypoints.push({
    location: myLatlng,
    stopover: true
  });
  return calcRoute();
};
