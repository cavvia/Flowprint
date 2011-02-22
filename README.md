Flowprint
=========

Visualise dynamics of spatial networks in Processing. Originally produced to deal with urban networks.

Feature Summary
---------------
* Import network representations in [NCOL][ncol] format, including weighted networks based on euclidean distances.
* Import node locations (lat/long or northing/easting).
* Visualise topology of spatial networks.
* Visualise node attributes.
* Visualise node labels.
* Import and construct network routes.
* Visualise flows of 'vessels' or 'passengers' on network routes.
* Import real trip information for playback of flows.
* Capture vector or video output.

Examples
--------
See the [London Bus Flowprint][flowprint] example.


How-To
------

For basic topology and simulated flows functionality, you need two plain-text files:

* Place an [NCOL][ncol] network representation in the 'dat' subfolder, with the naming convention <MyNetworkName>.ncol
* Place a CSV file with "latitude", "longitude" (or alternatively, "northing"/"easting") and "id" headers describing the location of nodes in the 'dat' subfolder, with the naming convention <MyNetworkName>_stops.csv
* The station ID's in the previous two files should correspond.

For trips:

* Add a trips CSV file in the 'dat' subfolder, with the naming convention <MyNetworkName>.trips, of the format:
	
	TripID, originID, destID, startTime, endTime

* The network will then try to load a shortest path description file. You can produce this using [iGraph][igraph]. This is a tab delimited (TSV) file of the form:

[PATH1]\t[PATH2]\t[PATH3]

Where each path is a comma delimited list of node IDs. The file describes a matrix Tij where each entry describes the shortest path from node i to node j.

* Flowprint will search for your shortest paths file in the 'dat' subfolder, with naming convention <MyNetworkName>_shortest_paths.rdat


Dependencies
------------

You'll need the [Processing][processing] visualisation framework, as well as the [ControlP5][controlp5] and [gicentre-utils][spatial] libraries.

[processing]:http://processing.org
[flowprint]:http://www.urbagram.net/v1/show/Flowprint
[ncol]:http://lgl.sourceforge.net/#FileFormat
[spatial]:http://code.google.com/p/gicentreutils/
[controlp5]:http://www.sojamo.de/libraries/controlP5/
[igraph]: http://igraph.sourceforge.net/