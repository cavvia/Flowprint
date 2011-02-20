class Trip
{
  public int origin;
  public int destination;
  public String time;
  public int date;
  private Route route;
  
  public Trip(int date,int from,int to,String time)
  {
    this.date = date;
    this.origin = from;
    this.destination = to;
    this.time = time;
  }
  
  public String toString()
  {
    return this.date + " " + this.origin + " " + this.destination + " " + this.time;
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
}
