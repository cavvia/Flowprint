/*
* @class Route
* @desc An undirected collection of transport access nodes (Stops)
*/

class Route {

public String[] stops;
public HashMap links;
public String name;
public int busCount = 0;
public float totalLength;
public int nullStops = 0;
public int maxBusCount = 0;
private String originID;
private boolean constructed = false;
java.util.List stopList;

public Route(String name) {
  this.name = name;
  this.links = new HashMap();
  this.stopList = new ArrayList();
}

public String[] getStops() {
  if(!this.hasConstructedRoute()) this.construct();
  return this.stops; 
}

public float getRouteLength() {
  if(this.totalLength == 0) {
  this.totalLength = 0;
    for (int i=0; i < this.stops.length-1;i++) {
      Stop oStopFrom = (Stop) net.aStop.get(ltrim(this.stops[i]));
      Stop oStopTo = (Stop) net.aStop.get(ltrim(this.stops[i+1]));
      this.totalLength += oStopFrom.getDistanceTo(oStopTo);
    }           
  }
  return this.totalLength;
}

public void addStops(String[] pieces) 
{
  this.stops = new String[pieces.length-1];
  this.name = pieces[0];
  for(int i =1; i < pieces.length;i++) {
    this.stops[i-1]= (pieces[i]);
  } 
  this.constructed = true;
}

public int getMaxBusCount(float routeAverage)
{
  if(this.maxBusCount == 0) {
    this.maxBusCount = min((int)round(routeAverage*1.3),round(2.5*(this.stops.length - this.nullStops)));
  }
  return this.maxBusCount;
}

private boolean hasConstructedRoute()
{
  return (this.constructed); 
}

public void printme()
{
print("ROUTE "+this.name+"\n");
  for (int t=0; t < this.stops.length-1;t++) {
    String s = this.stops[t];
    Stop stopx = (Stop) net.aStop.get(ltrim(s));
    Point p = stopx.getCoords();
    print(ltrim(s)+"," + p.x+","+p.y + "\n");
}
}

/*
* @desc Incrementally build the route when parsing ncol files.
*/
public void addLink(String id, String id2)
{
//try {
  if(this.links.containsKey(id)) {
    List linkList = (List)this.links.get(id);
    linkList.add(id2);
    this.links.put(id,linkList); 
    this.addStop(id);
    this.addStop(id2);              
    } else {
      List aList    = new ArrayList();
      aList.add(id2);
      this.addStop(id);
      this.addStop(id2);                           
      this.links.put(id,aList);

  }

//} catch(Exception o) {
//debug("tried to link invalid stops: " + id + ","+id2,DEBUG_WARN);
//}
}

private void addStop(String stopID)
{
  if(!this.stopList.contains(ltrim(stopID))) {
    this.stopList.add(stopID); 
  }
}

/*
* @desc Constructs a route from a set of links (or edges) specified in an ncol style file.
*/
public void construct()
{
  try {
    this.originID = this.findRouteOrigin();
  } catch(Exception o) {
    debug(o.getMessage(),DEBUG_WARN);
    this.originID = (String)this.stopList.get(0);
  }
  debug("found route origin " + originID + " for ROUTE ID " + this.name);

  this.stopList = new ArrayList();
  this.addStop(originID);         
  this.followRoute(originID);
  this.stops = new String[this.stopList.size()]; //reset this           

  for(int i=0;i<this.stopList.size();i++) {
    this.stops[i] = (String)this.stopList.get(i);
  }
  //this.printStops();
  this.constructed = true;
}

/*
* @desc Recursive path finding algorithm
*/
private void followRoute(String origin)
{
  List linkDestinations = (List)this.links.get(origin);
  if(linkDestinations == null) return;
  String dest = null;

  if (linkDestinations.size() == 1 && !this.isOrigin(origin)) return; //base case                    

  for(int i=0; i < linkDestinations.size(); i++) {
    dest = (String)linkDestinations.get(i);
    //debug("evaluating dest " + dest);
    if(!this.stopList.contains(dest)) {
      this.addStop(dest);
      Stop originStop = (Stop)net.aStop.get(origin);
      Stop destStop = (Stop)net.aStop.get(dest);              
      if(this.name.equals("2")) {
        debug("CONSTRUCTING LINK " + originStop.name + "(" + origin + ") - " + destStop.name + "(" + dest + ")");              
      }
      this.followRoute(dest);              
    }
  }
}

private boolean isOrigin(String id)
{
  return this.originID.equals(id); 
}

private void printStops() 
{
  String out = new String();
  for (int i=0;i< this.stops.length;i++) {

    Stop s = (Stop)net.aStop.get(ltrim(this.stops[i]));
    out += s.name + "(";

    out += this.stops[i];
    out += "),";
  }
  debug(this.name + ": " +out);
}

private boolean containsStop(String stopID)
{
  for (int i=0; i < this.stops.length;i++) {
    if(this.stops[i].equals(stopID)) return true;
  }         
  return false;
}

private String findRouteOrigin() throws Exception
{
  for (int i=0; i < this.stopList.size();i++) {
    List stopLinks = (List)this.links.get(this.stopList.get(i));
    if(stopLinks != null && stopLinks.size() == 1) return (String) this.stopList.get(i);
  }
  throw (Exception) new Exception("DID NOT DETECT A ROUTE ORIGIN FOR ROUTE");
}

public void draw() {
  float zoomScale = 1.0;     

  for (int i=0; i < this.stops.length-1;i++) {
    Stop oStopFrom = (Stop) net.aStop.get(ltrim(this.stops[i]));
    Stop oStopTo = (Stop) net.aStop.get(ltrim(this.stops[i+1]));

    if(cp.flags[ControlPanel.NODES] || net.firstRun) {
      try {
        oStopFrom.draw(zoomScale,net.hasAttribs());         
        }catch(Exception o) {
          continue; 
        }
      }

      if(!cp.flags[ControlPanel.ROUTES] && !net.firstRun) continue;

      try {
        float dim = net.getDimension();
        float dimY = net.getYDimension();
        float offset = 0;
        if(!trueAspectRatio) dimY = dim;
        int xFrom = int(map(oStopFrom.easting,MinX,MaxX,offset,dim));
        int yFrom = int(map(oStopFrom.northing,MinY,MaxY,offset,dimY));      
        int xTo = int(map(oStopTo.easting,MinX,MaxX,offset,dim));
        int yTo = int(map(oStopTo.northing,MinY,MaxY,offset,dimY));

        strokeWeight(1);
        stroke(100,100);
        if(net.firstRun) stroke(0,0);
        float yOffset = (trueAspectRatio) ? -(height-dimY)/2 : net.getYOffset();
        line(xFrom + net.getXOffset(),height-yFrom - yOffset,xTo + net.getXOffset(),height-yTo - yOffset);
      } catch(Exception o) {
      }   
      }  
    } 

  }
