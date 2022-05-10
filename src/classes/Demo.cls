public class demo extends Bar {

	//this constructor only has 1 NCSS lines
    public demo() {
        super();




        super.demo();
	}
	
	public void bar(Integer x, Integer y, Integer z) {
        if (x>y) {
            if (y>z) {
                if (z==x) {
                    // !! too deep
                }
            }
        }
    }
	
	public void example() { // This method has a cyclomatic complexity of 12
    int x = 0, y = 1, z = 2, t = 2;
    boolean a = false, b = true, c = false, d = true;
    if (a && b || b && d) {
      if (y == z) {
        x = 2;
      } else if (y == t && !d) {
        x = 2;
      } else {
        x = 2;
      }
    } else if (c && d) {
      while (z < y) {
        x = 2;
      }
    } else {
      for (int n = 0; n < t; n++) {
        x = 2;
      }
    }
  }
}