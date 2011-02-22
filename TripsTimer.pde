class TripsTimer
{
  private List vessels;
  private List activeVessels;
  private List trips;
  private Date modelDate;
  private float speed = 17.0; //secs per frame
  private PFont myFont;
  
  public TripsTimer()
  {
    this.vessels = new ArrayList<Vessel>();
    this.trips = new ArrayList<Trip>();
    this.activeVessels = new ArrayList<Vessel>();    
    myFont = createFont("Helvetica", 20);
    textFont(myFont);      
  }
  
  public void schedule(Vessel v,Trip t)
  {
    this.vessels.add(v);
    this.trips.add(t);
  }
  
  public void start()
  {
    Trip t = (Trip)this.trips.get(0);
    Date firstTripDate = t.getStartDate();
    this.modelDate = firstTripDate;
  }
  
  public void update()
  {
    this.updateTime();
    this.updateActiveVessels();
    this.updateVessels();
  }
  
  private void updateTime()
  {
    this.modelDate.setTime(this.modelDate.getTime() + this.getTimeFrame());
    textFont(myFont);
    fill(#000000,100);
    noStroke();
    rect(width/2 - 85,height/7-5,230,40);    
    fill(102, 102, 102);        
    String mins = "";
    mins = (this.modelDate.getMinutes() < 10) ? "0" : "";
    mins += this.modelDate.getMinutes();
    mins = (this.modelDate.getHours() > 12) ? mins + "PM " : mins + "AM ";
    //text(this.modelDate.getHours() + ":" + mins + " " + this.activeVessels.size() + " Active",width/2 - 70,height/7,200,30);    
    text(this.modelDate.getHours() + ":" + mins,width/2 - 80,height/7,200,30);
    if(this.modelDate.getHours() == 17 && video) {
        mm.finish();             
        debug("finished mov");
    }
  }
  
  private void updateVessels()
  {
    for (int i=0; i < this.activeVessels.size(); i++) {
        Vessel v = (Vessel)this.activeVessels.get(i);
        v.update();
    }    
  }
  
  private void updateActiveVessels()
  {
    this.activeVessels.clear();
    for (int i=0; i < this.vessels.size(); i++) {    
        Vessel v = (Vessel)this.vessels.get(i);
        Trip t = (Trip)this.trips.get(i);
        
        if(t.getStartDate().getTime() >= this.modelDate.getTime()) {
          break;
        }        
        
        if(t.getStartDate().getTime() <= this.modelDate.getTime() && t.getEndDate().getTime() >= this.modelDate.getTime()) {
          this.activeVessels.add(v);
        }
        
        if(t.getEndDate().getTime() <= this.modelDate.getTime()) {
          this.vessels.remove(i);
          this.trips.remove(i);
        }
    }
  }
  
  private int getTimeFrame()
  {
    return int(this.speed*1000);
  }
  
}