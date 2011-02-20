    
/**
* @class ControlPanel
* @desc GUI controls
*/

class ControlPanel
{
  public static final int WIDTH = 220;
  public boolean toggleValue = true;
  int myColorBackground = color(#000000);
  public ControlP5 gui;
  public boolean[] flags;
  public boolean tripsFlag = true;
  
  //GUI COMPONENT ID
  public static final int NODES = 0;
  public static final int ROUTES = 1;
  public static final int VEHICLES = 2;
  public static final int FLEET = 3;      
  public static final int HEADWAY = 4;      
  public static final int SPEED = 5;      
  public static final int SPEED_LIMIT = 6; 
  public static final int DYNAMICS = 7; 
  public static final int GROWTH = 8;
  public static final int NET_SELECTOR = 9;
  public static final int MODE = 10;    
  public static final int TRIPS = 11;    
    
  int mode;
  public static final int TOPOLOGY = 1;
  public static final int FLOW = 2;  
  
  int dynamics;
  public static final int SWARM = 0;
  public static final int BUS = 1;
  public static final int TUBE = 1;      

  int growth;
  public static final int EVEN_HEADWAY_GROWTH = 0;
  public static final int INCREMENTAL_GROWTH = 1;      

  int x;

  public ControlPanel(ControlP5 gui)
  {
    this.gui = gui;
    this.dynamics = ControlPanel.SWARM;
    this.growth = ControlPanel.INCREMENTAL_GROWTH;
    this.mode = ControlPanel.TOPOLOGY;
    flags = new boolean[3];
    flags[ControlPanel.NODES] = false;
    flags[ControlPanel.ROUTES] = false;
    flags[ControlPanel.VEHICLES] = true;
  }

  public void draw()
  {
    int checkWidth = 65;
    this.x = width - ControlPanel.WIDTH + 1;        
    this.gui.addToggle("nodes",false,x,0,checkWidth,checkWidth).setId(ControlPanel.NODES);
    this.gui.addToggle("routes",false,x + checkWidth + 2,0,checkWidth,checkWidth).setId(ControlPanel.ROUTES);
    this.gui.addToggle("vehicles",false,x + checkWidth*2+4,0,checkWidth,checkWidth).setId(ControlPanel.VEHICLES);
    Toggle t = (Toggle)controlP5.controller("vehicles");                
    t.setValue(true);
    this.initSliders();
    this.initRadioButtons();
    this.gui.addMultiList("netselect",x,350,80,14).setId(ControlPanel.NET_SELECTOR);
    MultiList l = (MultiList)controlP5.controller("netselect");
    MultiListButton b = l.add("SELECT NETWORK",1);
    List<String> networks = net.getNetworkNames();
    int count= 0;
    for(String network : networks) {
     b.add(network,count).setLabel(network.toUpperCase());                
     count++;
    }
    this.gui.addToggle("PLAY TRIPS",false,x,370,80,14).setId(ControlPanel.TRIPS);
    this.gui.addTextlabel("author","Flowprint. Anil Bawa-Cavia 2010",x,height-20);               
  }

  private void initSliders()
  {
    this.gui.addSlider("headway",0,20,6,x,90,ControlPanel.WIDTH-45,30).setId(ControlPanel.HEADWAY);        
    Slider s1 = (Slider)controlP5.controller("headway");
    this.gui.addSlider("fleet",0,net.maxBusNum,0,x,122,ControlPanel.WIDTH-45,30).setId(ControlPanel.FLEET);
    Slider s2 = (Slider)controlP5.controller("fleet");
    this.gui.addSlider("speed",0,1,BUS_SPEED,x,155,ControlPanel.WIDTH-45,30).setId(ControlPanel.SPEED);        
    Slider s3 = (Slider)controlP5.controller("speed");                
    s3.setValue(BUS_SPEED);
    this.gui.addSlider("sp-limit",0,5,MAX_SPEED,x,187,ControlPanel.WIDTH-45,30).setId(ControlPanel.SPEED_LIMIT);        
    Slider s4 = (Slider)controlP5.controller("sp-limit");         
    s4.setValue(MAX_SPEED); 
  }

  private void initRadioButtons()
  {  
    int y = 230;
    Textlabel l = this.gui.addTextlabel("DYNAMICS","DYNAMICS",x,y);        
    l.setWidth(100);        
  
    RadioButton r = this.gui.addRadioButton("dynamics",x,y+12);
    r.setId(ControlPanel.DYNAMICS);
    r.addItem("swarm",ControlPanel.SWARM);
    r.addItem("bus",ControlPanel.BUS);
    r.addItem("tube",ControlPanel.TUBE);        
    r.activate("swarm");
    r.setItemsPerRow(3);
    r.setSpacingColumn(45); 
  
    Textlabel l2 = this.gui.addTextlabel("GROWTH","GROWTH",x,y+35);        
    l2.setWidth(100);
    RadioButton r2 = this.gui.addRadioButton("growth",x,y+47);
    r2.setId(ControlPanel.GROWTH);
    r2.addItem("even headway",ControlPanel.EVEN_HEADWAY_GROWTH);
    r2.addItem("incremental",ControlPanel.INCREMENTAL_GROWTH);
    r2.activate("incremental");
    r2.setItemsPerRow(2);
    r2.setSpacingColumn(80);  
    
    Textlabel l3 = this.gui.addTextlabel("MODE","MODE",x,y+70);        
    l3.setWidth(100);
    RadioButton r3 = this.gui.addRadioButton("mode",x,y+82);
    r3.setId(ControlPanel.MODE);
    r3.addItem("topology",ControlPanel.TOPOLOGY);
    r3.addItem("flow",ControlPanel.FLOW);
    r3.activate(DEFAULT_MODE); 
    r3.setItemsPerRow(2);
    r3.setSpacingColumn(80);      
  }

  void drawBG()
  {
    fill(#000000,100);
    stroke(#000000);
    rect(width - ControlPanel.WIDTH,0,ControlPanel.WIDTH,height);  
  }

  void update()
  {
    Slider s2 = (Slider)controlP5.controller("fleet");        
    s2.setValue(net.activeVesselNum); 
    //s2.alignValueLabel(ControlP5.TOP);                
  }

  public void toggle(boolean theFlag)
  {
  
    if(theFlag==true) {
      myColorBackground = color(#FFFFFF);
    } else {
      myColorBackground = color(#FFFFFF);
    }
    println("a toggle event.");
  }

  void controlEvent(ControlEvent theEvent) {  
    try {
      if(theEvent.group().name() == "dynamics") {
        this.dynamics = (int)(theEvent.group().value());
        return;
      }
    } catch(Exception o) {
    }
  
   try {
      if(theEvent.group().name() == "growth") {
        this.growth = (int)(theEvent.group().value());
        return;
      }
    } catch(Exception o) {
    }
    
    try {
       if(theEvent.group().name() == "mode") {
         this.mode = (int)(theEvent.group().value());
         if(this.mode == ControlPanel.TOPOLOGY) {
           Toggle t = (Toggle)controlP5.controller("nodes");                
           t.setValue(true);
           Toggle t2 = (Toggle)controlP5.controller("routes");                
           t2.setValue(true);
           Toggle t3 = (Toggle)controlP5.controller("vehicles");
           t3.setValue(false);                      
         } else {
           Toggle t = (Toggle)controlP5.controller("vehicles");
           t.setValue(true);
         }
         return;
       }
     } catch(Exception o) {
     }    
  
    switch(theEvent.controller().id()) {
      case ControlPanel.FLEET:
      return;    
      case ControlPanel.NET_SELECTOR:
      net.refreshNetwork((int)theEvent.value());
      return;              
      case ControlPanel.TRIPS:
      this.tripsFlag = ((int)theEvent.value() > 0) ? true : false;
      if(this.tripsFlag) {
        net.startTripsMode();
      }
      return;
      case ControlPanel.HEADWAY:
      return;
      case ControlPanel.SPEED:
      BUS_SPEED = theEvent.controller().value();
      return;
      case ControlPanel.SPEED_LIMIT:
      MAX_SPEED = theEvent.controller().value();
      return;          
      case ControlPanel.DYNAMICS:
      debug(theEvent.group().name() + "");
      return;
      default:
          debug("got a control event from controller with id "+theEvent.controller().id() + " and value " + theEvent.controller().value());     
    }        
  
    this.flags[theEvent.controller().id()] = theEvent.controller().value() == 1.0 ? true : false;
    println(Arrays.toString(this.flags));
  }

  }


