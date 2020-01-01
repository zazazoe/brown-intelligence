class EquiCurve {
  
  private final int SEGMENT_COUNT = 100;
  private PVector v0, v1, v2, v3;
  private float arcLengths[] = new float[SEGMENT_COUNT + 1]; // there are n segments between n+1 points
  private float curveLength;
  
  EquiCurve(PVector a, PVector b, PVector c, PVector d) {
    v0 = a; // first control point
    v1 = b; // first point
    v2 = c; // second point
    v3 = d; // second control point
    
    float arcLength = 0;
    
    PVector prev = new PVector();
    prev.set(v0);
    
    for (int i = 0; i <= SEGMENT_COUNT; i++) {
      // map index from range (0, SEGMENT_COUNT) to parameter in range (0.0, 1.0)
      float t = (float) i / SEGMENT_COUNT;
      
      // get point on the curve at this parameter value
      PVector point = pointAtParameter(t);
      
      // get distance from previous point
      float distanceFromPrev = PVector.dist(prev, point);
      
      // add arc length of last segment to total length
      arcLength += distanceFromPrev;
      
      // save current arc length to the look up table
      arcLengths[i] = arcLength;
      
      // keep this point to compute length of next segment
      prev.set(point);
    }
    
    curveLength = arcLength;
  }
  
  
  // Returns the length of this curve
  float length() {
    return curveLength;
  }
  
  
  // Returns a point along the curve at a specified parameter value.
  PVector pointAtParameter(float t) {
    PVector result = new PVector();
    result.x = curvePoint(v0.x, v1.x, v2.x, v3.x, t);
    result.y = curvePoint(v0.y, v1.y, v2.y, v3.y, t);
    result.z = curvePoint(v0.z, v1.z, v2.z, v3.z, t);
    return result;
  }


  // Returns a point at a fraction of curve's length.
  PVector pointAtFraction(float r) {
    float wantedLength = curveLength * r;
    return pointAtLength(wantedLength);
  }
  
  
  // Returns a point at a specified arc length along the curve.
  PVector pointAtLength(float wantedLength) {
    wantedLength = constrain(wantedLength, 0.0, curveLength);
    
    // look up the length in our look up table >> java.util.Arrays.binarySearch(Array, lookup value)
    int index = java.util.Arrays.binarySearch(arcLengths, wantedLength);
    
    float mappedIndex;
    
    if (index < 0) {
      int nextIndex = -(index + 1);
      int prevIndex = nextIndex - 1;
      float prevLength = arcLengths[prevIndex];
      float nextLength = arcLengths[nextIndex];
      mappedIndex = map(wantedLength, prevLength, nextLength, prevIndex, nextIndex);
    } else {
      mappedIndex = index;
    }
    
    float parameter = mappedIndex / SEGMENT_COUNT;
    
    return pointAtParameter(parameter);
  }
  

  // Returns an array of equidistant point on the curve
  PVector[] equidistantPoints(int howMany) {
    
    PVector[] resultPoints = new PVector[howMany];
    
    resultPoints[0] = v0;
    resultPoints[howMany - 1] = v3; 
    
    int arcLengthIndex = 1;
    for (int i = 1; i < howMany - 1; i++) {
      
      // compute wanted arc length
      float fraction = (float) i / (howMany - 1);
      float wantedLength = fraction * curveLength;
      
      // move through the look up table until we find greater length
      while (wantedLength > arcLengths[arcLengthIndex] && arcLengthIndex < arcLengths.length) {
        arcLengthIndex++;
      }
      
      // interpolate two surrounding indexes
      int nextIndex = arcLengthIndex;
      int prevIndex = arcLengthIndex - 1;
      float prevLength = arcLengths[prevIndex];
      float nextLength = arcLengths[nextIndex];
      float mappedIndex = map(wantedLength, prevLength, nextLength, prevIndex, nextIndex);
      
      // map index from range (0, SEGMENT_COUNT) to parameter in range (0.0, 1.0)
      float parameter = mappedIndex / SEGMENT_COUNT;
      
      resultPoints[i] = pointAtParameter(parameter);
    }
    
    return resultPoints;
  }
  
  
  // Returns an array of points on the curve.
  PVector[] points(int howMany) {
    
    PVector[] resultPoints = new PVector[howMany];

    resultPoints[0] = v0;
    resultPoints[howMany - 1] = v3;
    
    for (int i = 1; i < howMany - 1; i++) {
      
      float parameter = (float) i / (howMany - 1);
      
      resultPoints[i] = pointAtParameter(parameter);
    }
    
    return resultPoints;
  } 
  
  void display() {

    noFill();
    stroke(200, 100);
    strokeWeight(1);
    curve(v0.x,v0.y,v1.x,v1.y,v2.x,v2.y,v3.x,v3.y);

  }
}
