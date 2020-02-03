

PVector NearestPointOnLine(PVector linePnt, PVector lineDir, PVector pnt)
{
    lineDir.normalize();//this needs to be a unit vector
    PVector v = PVector.sub(pnt, linePnt );
    float d = PVector.dot(v,lineDir);
    return PVector.add(linePnt, PVector.mult(lineDir,d));
}
