
/**
* @class NetworkImporter
* @desc Constructs a collection of routes from an NCOL format network representation.
* @desc Imports geographic location of nodes via a CSV file.
*/

class NetworkImporter extends Importer
{

  String ncolSuffix = "ncol";
  public static final int NORTHING_INDEX = 3;
  public static final int EASTING_INDEX = 2;
  public static final int ID_INDEX = 0;
  public static final int NAME_INDEX = 6;      
  public static final String DATA_DIR = "dat";
  private HashMap indexes;
  int[] attribList;
  public int[][] weights;
  public java.util.List networkNames;      
  private String filePrefix;      
  private int idIndex,nameIndex,eastingIndex,longIndex,latIndex,northingIndex;                              
  private TripsImporter tripsImporter;
  
  public NetworkImporter(int id)
  {        
   this.scanDataDirectory();
   this.setFilePrefix(id);       
  }

  public Stop[] loadStops()
  {      
   String file = this.getStopsFile();
   debug("LOADING STOPS... " + file);      
   this.initIndexes();
    String[] lines = loadStrings(file);
    String[] head = this.getHeaders(lines);
    this.parseHeaders(head);
    int startIndex = this.headers.contains("id") ? 1 : 0;                
    Stop[] stops = new Stop[lines.length-startIndex];        

    for (int i = startIndex; i < lines.length; i++) {          
      String[] pieces = split(lines[i], ','); 
      String id = this.clean(pieces[this.getIdIndex()]);          
      Stop oStop = new Stop(id);
      int northing = 0;
      int easting = 0;

      if(this.hasNorthingHeader() || !this.hasHeaders()) {
        northing = int(pieces[this.getNorthingIndex()]);
        easting = int(pieces[this.getEastingIndex()]);             
      } else if(this.hasLatitudeHeader()) {
        Point p = this.parseLatLong(float(pieces[this.getLatitudeIndex()]),float(pieces[this.getLongitudeIndex()]));
        easting = int(p.x);
        northing = int(p.y);
        //debug(easting);
      } 

      oStop.setNorthing(Math.round(northing));
      oStop.setEasting(Math.round(easting));
      oStop.setName(pieces[this.getNameIndex()]);
      stops[i-startIndex] = oStop;
    }

    for (int i = 0; i < stops.length; i++) {
      stops[i].locate();        
    }

    debug("HEADERS DETECTED: " + " ID(" + idIndex +"), NORTHING(" + northingIndex + "), EASTING(" + eastingIndex + "), LAT(" + latIndex + "), LONG(" + longIndex + "), NAME (" + nameIndex + ")");        
    debug(stops.length + " STOPS LOADED... ");
    this.printCoordRange();

    return stops;
  }

  public void scanDataDirectory()
  {
  final Collection<File> all = new ArrayList<File>();      
  String path = getClass().getResource("").getPath();      
  File file = new File(ROOT_DIR + "/" + NetworkImporter.DATA_DIR + "/");
  File[] children = file.listFiles();
  this.networkNames = new ArrayList<String>();
  if (children != null) {
    for (File child : children) {
      if(child.getName().indexOf("ncol") > 0 || child.getName().indexOf("routes") > 0) {
        String netname = child.getName().substring(0,child.getName().indexOf("."));
        this.networkNames.add(netname);
      }
      debug(child.getName());
    }
  }
  }

  public List<String> getNetworkNames()
  {
  return this.networkNames;
  }

  public String getNetworkName()
  {
    return this.filePrefix;
  }

  public void setFilePrefix(int networkID)
  {
   this.filePrefix = (String)networkNames.get(networkID);
  }

  private String getStopsFile()
  {
   return "./" + NetworkImporter.DATA_DIR + "/" + this.filePrefix + "_stops.csv";
  }

  private String getEdgesFile(Boolean ncol)
  {
   String suffix = ncol ? ncolSuffix : "routes";
   return "./" + NetworkImporter.DATA_DIR + "/" + this.filePrefix + "." + suffix;
  }     

  private String getAttribFile(String attrib)
  {
   String suffix = "csv";
   return "./" + NetworkImporter.DATA_DIR + "/" +this.filePrefix + "_" + attrib + "." + suffix;
  }         

  private void initIndexes()
  {
    northingIndex=-1;idIndex=-1;nameIndex=-1;eastingIndex=-1;latIndex=-1;longIndex=-1;          
  }
  
  //long=easting,lat=northing 
  private Point parseLatLong(float _lat, float _long)
  {        
      UTM convertor = new UTM(new Ellipsoid(Ellipsoid.WGS_84),0.0,0.0);
      PVector p = new PVector(_long,_lat);
      PVector p2 = convertor.latLongToUTM(p);
      //debug(_long + ","+_lat+" = "+p2.x + "," + p2.y);
      return new Point(p2.x,p2.y);
  }

  public int getLongitudeIndex()
  {
   if(this.longIndex == -1) {
    this.longIndex = (headers.indexOf("longitude") > -1) ? headers.indexOf("longitude") : (headers.indexOf("long") > -1) ? headers.indexOf("long") : NetworkImporter.EASTING_INDEX;       
   }
    return this.longIndex;
  }

  public int getLatitudeIndex()
  {
   if(this.latIndex == -1) {       
    this.latIndex = (headers.indexOf("latitude") > -1) ? headers.indexOf("latitude") : (headers.indexOf("lat") > -1) ? headers.indexOf("lat") : NetworkImporter.NORTHING_INDEX;       
   }
    return this.latIndex;
  }     

  public int getNorthingIndex()
  {
   if(this.northingIndex == -1) {              
    this.northingIndex = (headers.indexOf("northing") > -1) ? headers.indexOf("northing") : NetworkImporter.NORTHING_INDEX;
   }
    return this.northingIndex;
  }

  public int getEastingIndex()
  {
   if(this.eastingIndex == -1) {                     
    this.eastingIndex = (headers.indexOf("easting") > -1) ? headers.indexOf("easting") : NetworkImporter.EASTING_INDEX;
   }
    return this.eastingIndex;        
  }

  public int getIdIndex()
  {
   if(this.idIndex == -1) {                            
    this.idIndex = (headers.indexOf("id") > -1) ? headers.indexOf("id") : NetworkImporter.ID_INDEX;
   }
    return this.idIndex;        
  }

  public int getNameIndex()
  {
   if(this.nameIndex == -1) {
    this.nameIndex = (headers.indexOf("name") > -1) ? headers.indexOf("name") : NetworkImporter.NAME_INDEX;
   }
    return this.nameIndex;        
  }

  private String getTripsFilePath() {
    //return ROOT_DIR + "/" + NetworkImporter.DATA_DIR + "/xaa";
    return ROOT_DIR + "/" + NetworkImporter.DATA_DIR + "/" + this.filePrefix + "_trips.csv";
  }
  
  public boolean hasTrips() {
    try {
      File file = new File(this.getTripsFilePath());
      return file.isFile();
    } catch(Exception o) {
       return false; 
      }
  }  

  public void loadTrips() {
    try {
      this.tripsImporter = new TripsImporter(this.getTripsFilePath());
      //this.tripsImporter.showTrips();
    } catch(Exception o) {
      debug("ERROR LOADING TRIPS: " + o.getMessage());
    }
  }
  
  public List getTrips(int dayOfWeek)
  {
    return this.tripsImporter.getTrips(dayOfWeek);
  }

  public Route[] loadRoutes()
  {
   debug("LOADING ROUTES... ");
   Route[] r;
   try {
     debug("SCANNING FOR "+this.getEdgesFile(false));
     r= this.loadRouteFile(this.getEdgesFile(false));
     debug("FOUND "+this.getEdgesFile(false));         
   } catch(Exception o) {
     debug("SCANNING FOR "+this.getEdgesFile(true));         
     r= this.loadNCOL(this.getEdgesFile(true));
     debug("FOUND "+this.getEdgesFile(true));              
   }
    debug(r.length + " ROUTES LOADED");
    return r;
  }

  private Route[] loadNCOL(String file)
  {
    String[] routeLines = loadStrings(file);        
    this.parseHeaders(split(routeLines[0],","));        
    int startIndex = (this.hasHeaders()) ? 1 : 0;
    debug(startIndex);
    HashMap routemap = new HashMap();
    java.util.List routeList = new ArrayList();
    this.weights = new int[1000][1000];

    for (int i = startIndex; i < routeLines.length; i++) { 
      String[] pieces = split(routeLines[i], ',');             
      String fromID = this.clean(pieces[0]);
      String toID = this.clean(pieces[1]);
      String routeId = this.clean(pieces[2]);
  
      if(net.hasAttribs()) {
       this.addEdgeWeight(int(fromID),int(toID),int(routeId));
      }
  
      if(!routeList.contains(routeId)) {
        routeList.add(routeId);          
      }

      Route r = new Route(routeId);          
      if(routemap.containsKey(routeId)) {
        r = (Route)routemap.get(routeId);
      }            
    
      r.addLink(fromID,toID);
      r.addLink(toID,fromID);
      routemap.put(routeId,r);
    }

    Route[] routes = new Route[routeList.size()];        

    for(int i=0;i < routeList.size();i++) {
      Route r = (Route)routemap.get(routeList.get(i));
      routes[i] = r;
    }
    return routes;
  }

  private void addEdgeWeight(int fromID,int toID,int weight)
  {
   this.weights[fromID][toID] = weight;
  }

  public int getWeight(int i,int j)
  {
  try {
    return this.weights[i][j];
  } catch(Exception o) {
     return 0; 
  }
  }

  public void loadDataLayer()
  {
    this.loadAttrib("strength");
  }

  private void loadAttrib(String attrib)
  {
    debug("loading attrib " + attrib);
    String[] attribLines = loadStrings(this.getAttribFile(attrib));           
    this.parseHeaders(split(attribLines[0],","));
    int startIndex = 0;
    this.attribList = new int[attribLines.length+1];

    for (int i = startIndex; i < attribLines.length; i++) {     
      String[] pieces = split(attribLines[i], ',');
      int ID = i+1;//row number as ID          
      //debug(ID + ": " + pieces[0]);
      this.attribList[ID] = int(clean(pieces[0]));
    }
    debug(this.attribList[335]);
  }
  
  public float getAttribByID(int ID) 
  {
    return float(this.attribList[ID]); 
  }

  private boolean hasLatitudeHeader()
  {
   return (headers.indexOf("lat") != -1 || headers.indexOf("latitude") != -1);
  }

  private boolean hasNorthingHeader()
  {
   return (headers.indexOf("northing") != -1);
  }

  private String[] getHeaders(String[] lines)
  {
    String[] head = split(lines[0],','); 
    for (int i = 0; i < head.length; i++) {
      head[i] = this.clean(head[i]);
    }        
    return head;
  }
  
  private boolean isNCOL(String file)
  {
  return file.substring(file.length()-4,file.length()).equals("ncol");
  }

  private Route[] loadRouteFile(String file)
  {
    String[] routeLines = loadStrings(file); 
    Route[] routes = new Route[routeLines.length];

    for (int i = 0; i < routeLines.length; i++) {
      String[] pieces = split(routeLines[i], ',');
      Route route = new Route(pieces[0]);
      route.addStops(pieces,true);
      routes[i] = route;
    }

    return routes;   
  }

  public void printCoordRange()
  {
  debug("COORD RANGE: X " + MinX + "(" + MinXIndex +") - " + MaxX + "(" + MaxXIndex + ") Y " + MinY + "(" + MinYIndex + ") - " + MaxY + "(" + MaxYIndex + ")"); 
  }      
  }
