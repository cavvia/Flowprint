/*
 * @class Stop
 */

class Stop {
	public int ID;
	public String idString;
	public int northing;
	public int easting;
	public String name;
	int nucleusX=500;
	int nucleusY=500;
	float destX;		
	float destY;				
	float originX;
	float originY;
	float speed = 0.1;
	public float _x;
	public float _y;		

	public Stop(String id) {
		this.destX= this.nucleusX;
		this.destY= this.nucleusY;					
		this.setId(id);
	}

	public void setEasting(int easting)
	{
		this.easting = easting; 
		if(MinX == 0) MinX = easting; 
		if(MaxX == 0) MaxX = easting; 
		if(easting > MaxX) { 
			MaxX = easting; 
			MaxXIndex = this.idString;
		}
		if(easting < MinX) { 
			MinX = easting; 
			MinXIndex = this.idString;
		}
	}

	public void setNorthing(int northing)
	{
		this.northing = northing;
		if(MinY == 0) MinY = northing;
		if(MaxY == 0) MaxY = northing;					
		if(northing > MaxY) { 
			MaxY = northing; 
			MaxYIndex = this.idString;
		}
		if(northing < MinY) { 
			MinY = northing; 
			MinYIndex = this.idString;
		}
	}

	public void setName(String name)
	{
		this.name = name;
	}

	public void setId(String id)
	{
		ID = int(id);
		idString = id;
	}

	public String getId()
	{
		return this.idString;
	}

	public void locate()
	{
		float dim = net.getDimension();					
		float dimY = net.getYDimension();					
		float offset = video ? ControlPanel.WIDTH/2 : 0;
		if(!trueAspectRatio) dimY = dim;		
		this._x = int(map(this.easting,MinX,MaxX,offset,dim));
		this._y = int(map(this.northing,MinY,MaxY,offset,dimY));
	}

	public void printme() 
	{
		Point ppp = this.getCoords();
		print(this.idString + " : " + this.name + "," + ppp.x + "," + ppp.y + "," + this.northing + " N," + this.easting + " E, " + MinY + "," + MaxY + "\n");
	}

	public Point getCoords() {
		float offset = video ? ControlPanel.WIDTH/3 : 0;
		return new Point(this._x,height-this._y);
	}

	public void draw(float zoomScale,boolean attribs) {
		float dim = net.getDimension();
		float dimY = net.getYDimension();
		float offset = video ? ControlPanel.WIDTH/2 : 0;		
		if(!trueAspectRatio) dimY = dim;		
		this._x = int(map(this.easting,MinX,MaxX,0,dim));
		this._y = int(map(this.northing,MinY,MaxY,0,dimY));
		this.originX = this._x;
		this.originY = this._y;
		fill(#007FFF,255);
		stroke(#007FFF,0);
		if(net.firstRun) {
			fill(#FF0000,0);						
			stroke(#FF0000,0);
		}

    if(this.isSelected()) {
      fill(#FF0000,255);
    } 

		double ellipseSize = 2;
		if(attribs) {
			double attrib = net.getAttribById(this.ID);
			ellipseSize = Math.sqrt(attrib)/14;
		}
		else if(net.aStop.size() > 2000) ellipseSize = 1; //larger networks

		//ellipseMode(CENTER);		
		float yOffset = (trueAspectRatio) ? (height-dimY)/2 : net.getYOffset();
		ellipse(this._x + net.getXOffset(),height - this._y - yOffset,(float)ellipseSize,(float)ellipseSize); 
		//debug("drawing vertex "+this._x+","+this._y+"\n");
		//if(net.hasAttribs()) this.drawLabel((float)ellipseSize,xOffset,yOffset);
	}

	private void drawLabel(float _size,float xOffset,float yOffset)
	{
		PFont font;
		if(_size > 9) {
			PFont myFont = createFont("Helvetica-Bold",int(_size/2)+1);
			textFont(myFont); 
			text(this.name.substring(1).substring(0,this.name.length()-2), this._x+6 + xOffset, height-this._y-yOffset - 6);
		}
	}

  public boolean isSelected()
  {
    return net.selectedNode == this.ID;
  }

	public float getDistanceTo(Stop stop)
	{ 
		return sqrt(pow(abs(this.northing - stop.northing),2) + pow(abs(this.easting - stop.easting),2));
	}

	public void converge() {
		this._x += (this.destX-this._x)/(1/this.speed);
		this._y += (this.destY-this._y)/(1/this.speed);
		if(this.atDest()) {
			if(abs(this.destX - this.nucleusX) > 1) {
				this.destX= this.nucleusX;
				this.destY= this.nucleusY;
			} 
			else {
				this.destX= this.originX;
				this.destY= this.originY;
			}
		}
		int dim = 2;
		if(net.aStop.size() > 2000) dim = 1; //larger networks
		ellipse(this._x,height - this._y,dim,dim);
	}

	public void drawEdge(Stop dest,int weight)
	{		 
		//debug("DRAWING EDGE " + this.idString + ","+dest.idString + " WEIGHT " + weight);
		strokeWeight(1);
		if(weight < 30) return;
		stroke(100,weight/15);
		float dim = net.getDimension();
		float dimY = net.getYDimension();		 
		if(net.firstRun) stroke(0,0);
		float yOffset = (trueAspectRatio) ? (height-dimY)/2 : 0;
		float xOffset = (net.hasAttribs()) ? (width-dim)/2 : 0;				
		line(this._x + xOffset,height-this._y - yOffset,dest._x + xOffset,height-dest._y - yOffset);
	}

	private boolean atDest() {
		return (abs(this.destX-this._x) < 1 && abs(this.destY - this._y) < 1);
	}
}

