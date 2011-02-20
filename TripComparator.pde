class TripComparator implements Comparator
{
  public int compare (Object trip1, Object trip2)
  {
    Trip t1 = (Trip)trip1;
    Trip t2 = (Trip)trip2;
    String[] h1 = split(t1.time,":");
    String[] h2 = split(t2.time,":");    
    if (int(h1[0]) == int(h2[0])) {
      return (int(h1[1]) > int(h2[1])) ? 1 : -1;
    } else {
      return (int(h1[0]) > int(h2[0])) ? 1 : -1;      
    }
  }
  
  public boolean equals(Object t1)
  {
    return true;
  }
  
  
}