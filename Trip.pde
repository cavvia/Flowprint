class Trip
{
  public int origin;
  public int destination;
  public String startTime;
  public String endTime;  
  public int date;
  private Route route;
  
  public Trip(int date,int from,int to,String start,String end)
  {
    this.date = date;
    this.origin = from;
    this.destination = to;
    this.startTime = start;
    this.endTime = end;    
  }
  
  public String toString()
  {
    return this.date + " " + this.origin + " " + this.destination + " " + this.getStartDate().toString();
  }
  
  public Stop getOrigin()
  {
    return (Stop)net.aStop.get(this.origin +"");
  }
  
  public Stop getDestination()
  {
    return (Stop)net.aStop.get(this.destination+"");    
  }
  
  public void setRoute(Route r)
  {
    this.route = r;
  }
  
  public Route getRoute()
  {
    return this.route;
  }
  
  public Date getStartDate()
  {
    String[] times = split(this.startTime,":");
    return new Date(2011,1,1,int(times[0]),int(times[1]));
  }
  
  public Date getEndDate()
  {
    String[] times = split(this.endTime,":");
    return new Date(2011,1,1,int(times[0]),int(times[1]));
  }
  
  /**
  * @return Int duration (in secs)
  */
  public float getDuration()
  {
    return (this.getEndDate().getTime() - this.getStartDate().getTime())/1000;
  }
  
}
