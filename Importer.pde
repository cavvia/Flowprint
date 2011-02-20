class Importer
{
  protected java.util.List headers;  
  
  protected void parseHeaders(String[] head)
  {
    this.headers = Arrays.asList(head);    
    for (int i=0;i < this.headers.size(); i++) {
       headers.set(i,clean((String)headers.get(i)));
    }
  }
  
  protected String clean(String s)
  {
   if(s.length() < 2) return s;
   if(s.substring(0,1).equals("\""))
      return ltrim(s.substring(1,s.length()-1)); 
   else 
     return ltrim(s);
  }
  
  protected boolean hasHeaders()
  {
     return this.headers.contains("id") || this.headers.contains("line") || this.headers.contains("name"); 
  }
}
