    import processing.pdf.*;

    import processing.video.*;
    import org.gicentre.utils.spatial.*;
    import controlP5.*;
    import processing.opengl.*;

    int MaxY=0;
    int MaxX=0;
    String MaxYIndex;
    String MinYIndex;  
    int MinY=0;
    int MinX=0;
    String MaxXIndex;
    String MinXIndex;  
    int globalOffset = 1000;
    int refreshRate = 100;
    float BUS_SPEED = 0.2;
    float MAX_SPEED = 1.40;    
    int PANE_WIDTH = 1000;
    int PANE_HEIGHT = 800;  
    int DEFAULT_NET = NetworkImporter.LDNSUB;
    boolean trails = false;
    static int DEBUG_WARN = 2;
    boolean debug = true;
    boolean video = false;
    boolean attribs = false; //whether to visualise node attributes
    boolean trueAspectRatio = false;
    String[] debugLevels;
        
    Network net;
    ControlPanel cp;
    ControlP5 controlP5;
    MovieMaker mm;
  
    void setup() 
    {
        size(screen.width, screen.height);
        fill(#FFFFFF);
        frameRate(30);
        smooth();
        //noLoop();
        PFont myFont = createFont("Helvetica", 10);
        debugLevels = new String[3];
        debugLevels[0] = "info";
        debugLevels[1] = "warn";
        debugLevels[DEBUG_WARN] = "error";

        textFont(myFont);
        net = new Network();  
        net.init();
        if(video) mm = new MovieMaker(this, width, height, "flowprint8.mov",
        30, MovieMaker.SORENSON, MovieMaker.HIGH);

        background(#000000);
        fill(#FFFFFF);      
        controlP5 = new ControlP5(this);
        //debug(combine(PGraphicsPDF.listFonts(),","));
        cp = new ControlPanel(controlP5);        
        cp.draw();
    }
    
    void mouseReleased() 
    {
      
    }
    
    void mousePressed()
    {
      net.findNode(mouseX,mouseY);
    }

    void controlEvent(ControlEvent theEvent) 
    {
        //debug("got a control event from controller with id "+theEvent.controller().id() + " and value " + theEvent.controller().value());     
        cp.controlEvent(theEvent);
    }

    void zoom() 
    {
        print("zooming\n");
        net.setZoomScale(net.getZoomScale()/2);
        background(#000000);
        net.run(); 
    }

    void draw() 
    {
        if(!trails) {
            background(#000000);
            fill(#FFFFFF);          
        }    
        cp.drawBG();
        net.run();  
        if(video) mm.addFrame();  // Add window's pixels to movie
    }


    void keyPressed() {
        if(key==ENTER) { 
            debug("enter pressed"); 
            beginRecord(PDF, "reach-vis.pdf");      
            draw();
        }
    }

    void keyReleased() {
        if(key==ENTER) {
            debug("enter released");
            endRecord();
        } 
    }

    void saveSVG(){
        saveFrame("test.svg");
    }

    void debug(String msg) 
    {
        debug(msg,0); 
    }

    void debug(int msg) 
    {
        debug(""+msg,0); 
    }  

    void debug(String msg, int level) 
    {
        if(debug) {
            print("[" + debugLevels[level] +"] " + msg+"\n"); 
        }
    }


    public String ltrim(String source) 
    {
        return source.replaceAll("^\\s+", "");
    }    

    String combine(String[] s, String glue)
    {
        int k=s.length;
        if (k==0)
        return null;
        StringBuilder out=new StringBuilder();
        out.append(s[0]);
        for (int x=1;x<k;++x)
        out.append(glue).append(s[x]);
        return out.toString();
    }


