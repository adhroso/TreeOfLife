////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Global variables
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
List<Component> components;
int height_ = 100;
int cluster_offset = 100;
int x_offset = 8;
boolean process;
// Setup and drawing functions
void setup() {
    //setup
    size (1000, 800);
    background(190);
    
    noSmooth();
    noLoop();
    
    //build data structure
    if(new File("path/to/file.txt").isFile()) {
        String[] data = loadStrings("dataset.dat");
        List<Data> dataList = generate_data_from_string(data);
      
        //generate initial clusters
        List< List<Data>> clusters = new ArrayList<List<Data>>();
        for (Data dl : dataList) {
            List<Data> cluster = new ArrayList<Data>();
            cluster.add(dl);
            clusters.add(cluster);
        }
    
        // cluster by sequence similarity
        SeqCluster seqCluster = new SeqCluster();
        String attr = "sequence";
        components = seqCluster.StringSimilarityCluster(clusters,attr);
        initialize_position();
        
        process = true;
    } else {
        process = false;
    }
}


//Visualize tree
void draw() {
    if(process) {
        List<Data> ld = get_leaf_nodes();
        for (Data d : ld) {
            Point p = d.getPoint();
            textSize(32);
            text(String.valueOf(d.getId()),(float) p.getX(), (float) p.getY());
            //textSize(10);
            //text("("+p.getX()+","+p.getY()+")",(float) p.getX(), (float) p.getY()+50);
        }
        for (Data d : ld) {
            Point p = d.getPoint();
            p.setLocation(p.getX(), p.getY()-30);
        }
        
        
        for(Component c : components) {
            draw_component(c);
        }
        Point p = ld.get(0).getPoint();
        float x = (float)p.getX(), y = (float)p.getY();
        line(x,y,x,y-height_);
        fill(255,0,0);
        textSize(24);
        text("big bang", x-45,y-height_-10);
    } else {
        textSize(32);
        fill(255,0,0);
        text("error: check file and try again...", width/4, height/2);
    }
}

/**
  Show coordintates
*/
void print_coodinates(List<Data> data) {
   for(Data d : data) {
      println("id: " + d.getId(), d.getPoint());
   } 
}

/**
  Bridge clusters within a single component 
  note: there should be exactly two clusters in each component
*/
void draw_component(Component c) {
     List<Data> cluster = c.getCluster();
     Data[] data = get_position(cluster);
     println("processing...");
     println(data[0].getId(),data[1].getId());
     
     Point lhs = data[0].getPoint();
     Point rhs = data[1].getPoint();
  
     draw_vertical_bar(data[0],data[1]);
     draw_horizontal_bar(data[0], data[1]);
     update(c,data[0]);
     
}

/**
  Estimate height distance when bridging two clusters
*/
void draw_vertical_bar(Data lhs, Data rhs) {
  Point lp = lhs.getPoint();
  float xleft = (float)lp.getX();
  float yleft = (float) lp.getY();
  
  Point rp = rhs.getPoint();
  float xright = (float) rp.getX();
  float yright = (float) rp.getY();
  
  // adjust point according to the initial height
  if(yleft != yright) {
      if(yleft > yright) {
          line(xleft+x_offset,yleft, xleft+x_offset,yright-(rhs.getLevel()*height_));
          line(xright+x_offset,yright, xright+x_offset,yright-(rhs.getLevel()*height_));
      } else {
          line(xleft+x_offset,yleft, xleft+x_offset,yleft-(lhs.getLevel()*height_));
          line(xright+x_offset,yright, xright+x_offset,yleft-(lhs.getLevel()*height_));
      }  
  } else {
    line(xleft+x_offset,yleft, xleft+x_offset,yleft-(lhs.getLevel()*height_));
    line(xright+x_offset,yright, xright+x_offset,yright-(rhs.getLevel()*height_));
  }
}

/**
  Bridge the two clusters
*/
void draw_horizontal_bar(Data lhs, Data rhs) {
  Point lp = lhs.getPoint();
  float xleft = (float)lp.getX();
  float yleft = (float) lp.getY();
  
  Point rp = rhs.getPoint();
  float xright = (float)rp.getX();
  float yright = (float) rp.getY();

  //adjust when merging cluster at different levels
  if(yleft != yright) {
      if(yleft > yright) yleft = yright;
      else yright = yleft;  
  }
  line(xleft+x_offset,yleft-height_, xright+x_offset,yright-height_);

  double mid = ((xright+x_offset)-(xleft+x_offset)) / 2;
  lp.setLocation(xleft+mid,yleft-height_);
  rp.setLocation(xleft+mid,yright-height_);

}

/**
  Update new coordinates (after bridging two clusters
*/
void update(Component c, Data data) {
    Point p = data.getPoint();
    List<Data> cluster = c.getCluster();
    for(Data d : cluster) {
        Point p2 = d.getPoint();
        p2.setLocation(p);
    }
}

/**
  Retrive two unique (positions) data points
*/
public Data[] get_position(List<Data> cluster){
    Data[] points = new Data[2];
 
    for (Data d : cluster) {
        Point rhs = d.getPoint();
        
        if(points[0] == null) {
            points[0] = d;
        } else if(points[0].getPoint().getX() != rhs.getX()) {
            points[1] = d;
            break;
        }
    }
    
    // ensure correct order
    Data d = points[0];
    if(d.getPoint().getX() > points[1].getPoint().getX()) {
        points[0] = points[1];
        points[1] = d;  
     }
     
    return points;
}

/**
  Get single node clusters 
*/
public List<Data> get_leaf_nodes() {
    List<Data> lp = new ArrayList<Data>();
    for (Component c : components) {
        List<Data> cluster = c.getCluster();
        for (Data d : cluster) {
            if(!lp.contains(d))
                lp.add(d);
        }
    }
    return lp;
}

/**
  Initialize cluster positions
*/
public void initialize_position() {
    int step = 100;
    for (Component component : components) {
        List<Data> cluster = component.getCluster();
        for (Data d : cluster) {
            if (d.getPoint() == null) {
                Point p = new Point(step, 700);
                d.setPoint(p);
                step += cluster_offset;
            }
        }
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Helper functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public  List<Data> generate_data_from_string(String [] lines) {
        List<Data> dataList = new ArrayList<Data>();
        
        int id = 1;
        for (String l : lines) {
            if(!l.startsWith("#") && l.length() >= 1) {
                String[] line = l.split(",");
                Data d = new Data();
                Map<String, String> attributes = new HashMap<String,String>();
                for (String token : line) {
                    String[] attrs = token.split(":");
                    attributes.put(attrs[0], attrs[1]);
                }
                d.setId(id);
                d.setAttrs(attributes);
                dataList.add(d);

                id++;
            }
        }
        return dataList;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Data structures
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.awt.Point;
/**
 *
 * @author andi
 */
public class SeqCluster {
    
    /**
     *  Clusters data using string similarity where it is defined as the number
     *  of changes to convert one sequence into another using the Levenshtein Distance
     *   (http://en.wikipedia.org/wiki/Levenshtein_distance)
     * @param data
     */
    public List<Component> StringSimilarityCluster(List< List<Data> > data, String attr) {
        List<Component> components = new ArrayList<Component>();
        
        int level = 1;
        while(data.size() > 1) {
            int distance = Integer.MAX_VALUE;
            int [] location = new int[2];
            boolean new_min = false;

            // find min distance between any two cluster
            for (int i = 0; i < data.size(); i++) {
                List<Data> a = data.get(i);
                for (int j = i+1; j < data.size(); j++) {
                   List<Data> b  = data.get(j);
                   final int dist = min_distance(a, b, attr);
                   if(dist < distance) {
                       distance = dist;
                       location[0] =  i;
                       location[1] = j;
                       new_min = true;
                   }
                }
            }

            if(new_min) {
                List<Data> clusterA = data.get(location[0]);
                List<Data> clusterB = data.get(location[1]);
                if (clusterA.size() == 1 && clusterB.size() == 1 ) {
                    // update & remove cluster B from main list
                    clusterA.get(0).setDistance(distance);
                    clusterB.get(0).setDistance(distance);
                    clusterA.get(0).setLevel(level);
                    clusterB.get(0).setLevel(level);
                    
                    clusterA.addAll(clusterB);
                    data.remove(location[1]);
                    
                    Component component = new Component(clusterA, level);
                    components.add(component);
                } else if(clusterA.size() > 1 && clusterB.size() == 1) {
                    level++;
                    
                    // update & remove cluster B from main list
                    clusterB.get(0).setDistance(distance);
                    clusterB.get(0).setLevel(level);
                    
                    clusterA.addAll(clusterB);
                    data.remove(location[1]);
                    
                    Component component = new Component(clusterA, level);
                    components.add(component);
                    
                } else if(clusterA.size() == 1 && clusterB.size() > 1) {
                    level++;
                    // update & remove cluster A from main list
                    clusterA.get(0).setDistance(distance);
                    clusterA.get(0).setLevel(level);
                    
                    clusterB.addAll(clusterA);
                    data.remove(location[0]);
                    
                    Component component = new Component(clusterB, level);
                    components.add(component);
                } else if(clusterA.size() > 1 && clusterB.size() > 1) {
                    level++;
                    
                    clusterA.addAll(clusterB);
                    data.remove(location[1]);
                    
                    Component component = new Component(clusterA, level);
                    components.add(component);
                }                
            }
        }
        return components;
    }
        
    public int min_distance(List<Data> a, List<Data> b, String attr) {
        int distance = Integer.MAX_VALUE;
        for (Data ad : a) {
            for (Data bd : b) {
                final int dist = LevenshteinDistance(ad.getAttrs_WithKey(attr), bd.getAttrs_WithKey(attr));
                if(dist < distance)
                    distance = dist;
            }
        }
        return distance;
    }

    
    public int LevenshteinDistance(String s, String t) {
        // degenerate cases
        if (s.equalsIgnoreCase(t)) return 0;
        if (s.length() == 0) return t.length();
        if (t.length() == 0) return s.length();

        // create two work vectors of integer distances
        int v_length = t.length()+1;
        int[] v0 = new int[v_length];
        int[] v1 = new int[v_length];

        // initialize v0 (the previous row of distances)
        // this row is A[0][i]: edit distance for an empty s
        // the distance is just the number of characters to delete from t
        for (int i = 0; i < v_length; i++)
            v0[i] = i;

        for (int i = 0; i < s.length(); i++) {
            // calculate v1 (current row distances) from the previous row v0

            // first element of v1 is A[i+1][0]
            //   edit distance is delete (i+1) chars from s to match empty t
            v1[0] = i + 1;

            // use formula to fill in the rest of the row
            for (int j = 0; j < t.length(); j++) {
                int cost = (s.charAt(i) == t.charAt(j)) ? 0 : 1;
                v1[j + 1] = minimum(minimum(v1[j] + 1, v0[j + 1] + 1), v0[j] + cost);    
            }

            // copy v1 (current row) to v0 (previous row) for next iteration
            System.arraycopy(v1, 0, v0, 0, v_length);
        }
        return v1[t.length()];
    }
 
    private int minimum(int a, int b) {
        return a < b ? a : b;
    } 
}

/**
 *
 * @author andi
 */
public class Component {

    private List<Data> cluster;
    private final int level;

    public Component(List<Data> c, int level) {
        this.cluster = new ArrayList<Data>();
        this.cluster.addAll(c);
        this.level = level;
    }
       
    /**
     * @return the cluster
     */
    public List<Data> getCluster() {
        return cluster;
    }

    /**
     * @param cluster the cluster to set
     */
    public void setCluster(List<Data> cluster) { 
        this.cluster = cluster;
    }

    /**
     * @return the level
     */
    public int getLevel() {
        return level;
    }
}



/**
 *
 * @author andi
 */
public class Data {
    private Map<String, String> attrs;
    private double distance;
    private int level;
    private int id;
    private Point point;
    
    Data() {
        distance = 0;
        level = 0;
    }

    /**
     * @param key
     * @return the attrs value
     */
    public String getAttrs_WithKey(String key) {
        return attrs.get(key);
    }
    
    /**
     * @return the attrs
     */
    public Map<String, String> getAttrs() {
        return attrs;
    }

    /**
     * @param attrs the attrs to set
     */
    public void setAttrs(Map<String, String> attrs) {
        this.attrs = attrs;
    }

    /**
     * @return the distance
     */
    public double getDistance() {
        return distance;
    }

    /**
     * @param distance the distance to set
     */
    public void setDistance(double distance) {
        this.distance = distance;
    }

    /**
     * @return the level
     */
    public int getLevel() {
        return level;
    }

    /**
     * @param level the level to set
     */
    public void setLevel(int level) {
        this.level = level;
    }

    /**
     * @return the id
     */
    public int getId() {
        return id;
    }

    /**
     * @param id the id to set
     */
    public void setId(int id) {
        this.id = id;
    }

    /**
     * @return the p
     */
    public Point getPoint() {
        return point;
    }

    /**
     * @param p the p to set
     */
    public void setPoint(Point point) {
        this.point = point;
    }
}

