
/**
* @class TripsImporter
* @desc Imports real trips data for a network.
*/

class TripsImporter extends Importer
{
  private String path;
  public List[] trips;
  private String[][] shortPaths;
  
  public TripsImporter(String filepath)
  {        
    this.path = filepath;
    this.trips = new List[8];
    
    for(int i=1;i<8;i++) {
      this.trips[i] = new ArrayList<Trip>();
    }
    
    this.load(filepath);
    this.loadShortestPaths();
    this.setShortestPaths();
  }
  
  public TripsImporter (String[] filepath)
  {
    this.path = filepath[0];
    this.trips = new List[8];
    
    for(int i=1;i<8;i++) {
      this.trips[i] = new ArrayList<Trip>();
    }
    
    this.load(filepath);
    this.loadShortestPaths();
    this.setShortestPaths();    
  }

  public void load(String[] filepath) {
    for(int i=0;i<filepath.length;i++) {
      this.load(filepath[i]);
    }
  }
  
  public void load(String filepath) {
    debug("loading trips from " + filepath + "...");
    String[] tripLines = loadStrings(filepath); 
    debug("parsing " + tripLines.length + " trips...");
    this.parseHeaders(split(tripLines[0],","));            
    int startIndex = (this.hasHeaders()) ? 1 : 0;    
    int count=0;
    for (int i = startIndex; i < tripLines.length; i++) {
      String tripStr = tripLines[i];
      String[] tripInfo = split(tripStr,",");
      int dayOfWeek =  int(tripInfo[0]);
        if(dayOfWeek == 3) {
          if(count%4 == 0) {
            this.trips[dayOfWeek].add(new Trip(dayOfWeek,int(tripInfo[1]),int(tripInfo[2]),tripInfo[3],tripInfo[4]));
          }
          count++;
        }
    }
    debug("LOADED TRIPS");
  }
  
  public void showTrips() {
    for (int i=3;i<4; i++) {
      debug("DAY " + i);
      for(int j = 0; j < this.trips[i].size(); j++) {
        debug(this.trips[i].get(j).toString());
      }
    }
  }
  
  private void setShortestPaths()
  {
    for (int i=3;i<4; i++) {    
      for(int j = 0; j < this.trips[i].size(); j++) {    
        Trip trip = (Trip)this.trips[i].get(j);
        String[] path = this.getShortestPath(trip.getOrigin(),trip.getDestination());
        Route r = new Route(j+"");
        if(path.length > 0) {
          r.addStops(path,false);
          trip.setRoute(r);
        }
      }
    }
  }
  
  private String[] getShortestPath(Stop i, Stop j)
  {
    try {
      String[] a = split(this.shortPaths[(int)i.ID][(int)j.ID],",");
      return a;
    } catch(Exception o) {
      debug("no path found for origin " + i.ID + " dest " + j.ID);
      return new String[0];
    }
  }
  
  void loadShortestPaths() {
    String netname = net.getName();
    String[] shortestPaths = loadStrings(ROOT_DIR + "/dat/" + netname + "_shortest_paths.rdat");
    this.shortPaths = new String[shortestPaths.length][shortestPaths.length];    
    
    for(int i =0; i < shortestPaths.length; i++) {
      String[] chunks = split(shortestPaths[i], "\t");
      this.shortPaths[i] = chunks;
    }
    debug("loaded " + this.shortPaths.length + "x" + this.shortPaths.length + " shortest paths");
  }
 
  public List getTrips(int dayOfWeek)
  {
    Object[] tripsArr = this.trips[dayOfWeek].toArray();
    TripComparator tc = new TripComparator();
    Arrays.sort(tripsArr,tc);
    return Arrays.asList(tripsArr);
  }
  
}