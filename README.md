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
See the [London Bus Flowprint][flowprint] example. For trip playback, see the [London Oyster Flows][oyster], for topology view, see the [Boris Bikes][boris] flowprint.

Basic Setup
------

For basic topology and simulated flows functionality, you need two plain-text files:

* Place an [NCOL][ncol] network representation in the 'dat' subfolder, with the naming convention MyNetworkName.ncol. In default mode, the third column of this file is a 'line' variable describing the route number an edge belongs to. This is useful for public transit networks. In attributes mode the third column can be an edge weight (see below).
* Place a CSV file with "latitude", "longitude" (or alternatively, "northing"/"easting") and "id" headers describing the location of nodes in the 'dat' subfolder, with the naming convention MyNetworkName_stops.csv.
* The station IDs in the previous two files should correspond.
* Simulated flows will be based on routes constructed by Flowprint from your NCOL file. Flowprint doesn't support loops or forks in routes right now. You'll have to define them as new routes.

Trip Playback
--------------

* Add a trips CSV file in the 'dat' subfolder, with the naming convention MyNetworkName.trips, of the format:
	
	TripID, originID, destID, startTime, endTime

* The network will then try to load a shortest path description file. You can produce this using [iGraph][igraph]. This is a tab delimited (TSV) file of the form:

	[PATH1]\t[PATH2]\t[PATH3]

* Where each path is a comma delimited list of node IDs. The file describes a matrix Tij where each entry describes the shortest path from node i to node j. New rows in the matrix are delimited by a newline. Node IDs should correspond to those in the previous two files.
* This gives Flowprint the routing information required to visualise a trip from an origin to a destination.

* Flowprint will search for your shortest paths file in the 'dat' subfolder, with naming convention MyNetworkName_shortest_paths.rdat
* Support for multiple trip files exist. More doc on that soon.

Weighted Networks
-----------------

* You can use the third column in your NCOL file to represent edge weights for visualisation. Switch on the 'attribs' configuration variable to visualise these weights in topology view.
* Other node attributes can be loaded in via CSV files of the form MyNetworkName_attribute.csv. More doc on this soon, although this functionality is generally covered by other network packages such as [Gephi][gephi].


Configuration
-------------

* Coming soon...


Dependencies
------------

You'll need the [Processing][processing] visualisation framework, as well as the [ControlP5][controlp5] and [gicentre-utils][spatial] libraries.

[processing]:http://processing.org
[flowprint]:http://www.urbagram.net/v1/show/Flowprint
[ncol]:http://lgl.sourceforge.net/#FileFormat
[spatial]:http://code.google.com/p/gicentreutils/
[controlp5]:http://www.sojamo.de/libraries/controlP5/
[igraph]: http://igraph.sourceforge.net/
[gephi]:http://gephi.org/
[oyster]:http://www.urbagram.net/v1/show/Oyster
[boris]:http://www.urbagram.net/v1/show/Boris