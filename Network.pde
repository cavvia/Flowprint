/*
* @class Network
* @desc The network pane
*/

class Network
{

  Route[] routes;
  Stop[] stops;
  Vessel[] vessels;
  public HashMap aStop;
  String[] aRoute;
  String[] lines;
  int totalStops = 24690;
  float zoomScale = 1.0;
  int routeNum = 0;
  int maxBusNum = 8300;
  int activeVesselNum = 0;
  public boolean firstRun = true;
  public boolean peaked = false;
  public final float SIM_SPEED = 10;
  NetworkImporter importer;   
  public int selectedNode = 0;
  private List tripVessels;
  private TripsTimer timer;
  
  public Network()
  {
  }

  public void init()
  {
      this.setup(DEFAULT_NET);                   
  }

  public void run() {

      if(cp.flags[ControlPanel.VEHICLES] && this.shouldRenderFlows()) {
          this.updateVessels();          
      }


      if(cp.flags[ControlPanel.NODES] && this.hasAttribs()) {
          this.drawDataLayer(); 
          //noLoop();
      }

      if(cp.flags[ControlPanel.ROUTES] || cp.flags[ControlPanel.NODES] || this.firstRun) {     
          this.drawRoutes(); 
          this.firstRun = false;      
      }

  }

  public void refreshNetwork(int netID) 
  {
      noLoop();
      this.reset();
      this.setup(netID);
      loop();
  }

  private void reset()
  {
      this.firstRun = true; 
      this.peaked = false;
      this.routeNum = 0;          
      this.activeVesselNum = 0;
      MinX=0;MaxX=0;MinY=0;MaxY=0;
  }

  public void setup(int networkID){
      this.importNet(networkID);
      int t = this.maxBusNum + 1;
      this.vessels = new Vessel[t];
      this.createVessels();            
      if(this.shouldShowTrips()) {
        this.timer = new TripsTimer();
        this.startTripsMode();
      }  
  }

  public void importNet(int netID) {
      this.importer = new NetworkImporter(netID);                  
      this.loadStops();
      this.loadRoutes();
      if(this.hasAttribs()) {
          this.importer.loadDataLayer();
      }
      
      if(this.importer.hasTrips()) {
        this.importer.loadTrips();
      }
  }
  
  public boolean shouldShowTrips() 
  {
    return cp.tripsFlag && this.importer.hasTrips();
  }
   
  public String getName()
  {
    return this.importer.getNetworkName();
  }

  public float getAttribById(int ID) {
      return this.importer.getAttribByID(ID); 
  }

  private void drawDataLayer()
  {
      for (int i=0;i < this.importer.weights.length;i++) {
          if(this.importer.weights[i] == null) continue;
          Stop fromStop = (Stop)this.aStop.get(""+i);
          if(fromStop == null) continue;
          for (int j=0;j < this.importer.weights[i].length;j++) {
              if(this.importer.getWeight(i,j) == 0) continue;
              Stop toStop = (Stop)this.aStop.get(""+j);    
              if(toStop == null) continue;            
              fromStop.drawEdge(toStop,this.importer.getWeight(i,j));
          }          
      }
  }

  public boolean hasAttribs()
  {
      return attribs; 
  }

  public float getDimension()
  {
      float dim = PANE_WIDTH - ControlPanel.WIDTH;           
      return dim;
  }

  public float getXOffset() 
  {
      float x = (screen.width - PANE_WIDTH)/2 + 50;            
      return x;
  }

  public float getYOffset() 
  {
      float x = (screen.height - PANE_HEIGHT)/2;            
      return x;
  }

  public float getYDimension()
  {
      float aspect = (float)800/(MaxX - MinX);
      float ydim = aspect * (MaxY - MinY);
      return ydim;
  }

  public List<String> getNetworkNames()
  {
    return this.importer.getNetworkNames();
  }

  public void findNode(float x,float y) {
    float yOffset = this.getYOffset();
    float xOffset = this.getXOffset();
    debug("FINDING NODE NEAR "+ x + "," + y);
    for (int i = 0; i < this.stops.length; i++) {
       Point p = this.stops[i].getCoords();
        if(abs(p.x + xOffset - x) < 3 && (abs((p.y - yOffset) - y) < 10)) {
          debug("SELECT NODE "+ this.stops[i].ID + ": " + this.stops[i].name);
          this.selectedNode = this.stops[i].ID;
        }
    }
  }

  private void loadStops()
  {
      this.stops = this.importer.loadStops();
      this.aStop = new HashMap();

      for (int i = 0; i < this.stops.length; i++) {
          this.aStop.put(this.stops[i].idString,this.stops[i]);
      }
  }

  private void drawStops(){
      beginShape(POINTS);
      fill(#FFFFFF);        
      stroke(#FFFFFF);    
      for (int i = 0; i < this.stops.length; i++) {
          this.stops[i].printme();
          this.stops[i].draw(this.zoomScale,this.hasAttribs());
      }

      endShape();
  } 

  private void updateStops(){
      for (int i = 0; i < totalStops-1; i++) {    
          this.stops[i].converge();
      }
  }

  public void setZoomScale(float zoom) {
      this.zoomScale= zoom; 
  }

  public float getZoomScale() {
      return this.zoomScale;
  }

  private Route[] loadRoutes()
  {
      this.routes = this.importer.loadRoutes();
      if(this.routeNum == 0) this.routeNum = this.routes.length;
      return this.routes;
  }

  private void createVessels()
  {
      for (int x = 0; x < this.routeNum; x++) {    
          Vessel vessel = new Vessel(routes[x]);
          if(routes[x].getStops().length > 4) {
              this.addVessel(vessel);
          }
      }
  }

  private void addVessel(Vessel vessel)
  {
      this.vessels[this.activeVesselNum] = vessel;
      this.activeVesselNum++;
  }

  public void createVessel(Route route)
  { 
      if(this.peaked) return;
      //if(this.shouldShowTrips()) return;

      if((this.activeVesselNum < this.maxBusNum)) {
          if(route.busCount < route.getMaxBusCount(this.maxBusNum/this.routeNum)) {
              Vessel vessel = new Vessel(route);
              vessel.setDestinationIndex((route.busCount + route.getStops().length)%(int)route.getStops().length);
              this.addVessel(vessel);
              route.busCount++;
          }
          } else {
              this.peaked = true; 
          }
  }

  private void removeVessel() 
  {
      if(this.activeVesselNum < 1) {
          if(video) {
              mm.finish();             
              debug("finished mov");
          }
          return;
      }
      this.vessels[this.activeVesselNum] = null; 
      this.activeVesselNum--;        
  }

  public void startTripsMode()
  {
    //start timer
    debug("STARTING TRIPS MODE");
    this.tripVessels = new ArrayList<Vessel>();
    this.createTripVessels();
    this.timer.start();
  }
  
  public float getPixelsPerMeter()
  {
    return new Float(PANE_WIDTH)/(MaxX - MinX);
  }
  
  public float getTripSpeed()
  {
    return this.timer.speed;
  }
  
  private void createTripVessels()
  {
    int dayOfWeek = 3;
    List trips = this.importer.getTrips(dayOfWeek);
    for(int i=0;i<1000;i++) {
      Trip trip = (Trip)trips.get(i);
      debug(trip.startTime);
      Route r = trip.getRoute();
      if(r != null) {
        Vessel v = new Vessel(trip);
        this.tripVessels.add(v);
        this.timer.schedule(v,trip);
        r.printStops();
      }
    }
    debug("Loaded " + this.tripVessels.size() + " trips");
  }

  private void updateVessels()
  {
    if(this.shouldShowTrips()) {
      this.timer.update();
    } else {
      for (int i = 0; i < this.activeVesselNum; i++) {    
          this.vessels[i].update();
      }
    }
    cp.update();    
  }


  private void drawRoutes() {

      for (int x = 0; x < routeNum; x++) {
          Route oRoute = routes[x];
          oRoute.draw();
      }
  }

  public boolean isInTripsMode()
  {
    return this.shouldShowTrips();
  }

  public boolean isIncrementalGrowth() 
  {
      return cp.growth == ControlPanel.INCREMENTAL_GROWTH && !this.isInTripsMode(); 
  }
  
  public boolean shouldRenderFlows()
  {
      return cp.mode == ControlPanel.FLOW;     
  }

  public boolean isEvenHeadway() 
  {
      return cp.growth == ControlPanel.EVEN_HEADWAY_GROWTH; 
  }       

  private boolean isOnScreen(Stop stop)
  {
      return true;
      //return (stop.easting*this.zoomScale < MaxX) &&  (stop.northing*this.zoomScale < MaxY);
  }


}
