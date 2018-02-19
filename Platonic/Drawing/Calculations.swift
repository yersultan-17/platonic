//
//  Calculations.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 8/4/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import ARKit

class Calculations {
   
    static let shared = Calculations()
    
    func getIntersectionForParallel(aPoint: SCNVector3, aNormal: SCNVector3, bLine: Line) -> SCNVector3? {
        if !Lines.shared.linesAreOnSamePlaneForParallel(a: aNormal, aPoint: aPoint, bLine: bLine) { return nil }
        print("Lines are on the same plane")
        
        let (bNormal, bPoint) = bLine.getParametricEquation()
        
        let (p1, p2, p3) = aNormal.getComponents()
        let (q1, q2, q3) = bNormal.getComponents()
        let (x0, y0, z0) = aPoint.getComponents()
        let (a0, b0, c0) = bPoint.getComponents()
        
        print("LETS CHECK OUR LINES")
        print("----- Line 1 ----")
        print("x = \(p1)t + \(x0)")
        print("y = \(p2)t + \(y0)")
        print("z = \(p3)t + \(z0)")
        
        print("----- Line 2 ----")
        print("x = \(q1)s + \(a0)")
        print("y = \(q2)s + \(b0)")
        print("z = \(q3)s + \(c0)")
        
        
        var cnt = 0
        if (p1 == 0 && q1 == 0 && x0 != a0) { print("Returning NIL due to x0 != a0"); return nil;  }
        if (p2 == 0 && q2 == 0 && y0 != b0)  { print("Returning NIL due to y0 != b0"); return nil;  }
        if (p3 == 0 && q3 == 0 && z0 != c0) { print("Returning NIL due to z0 != c0"); return nil;  }
        
        if (p1 == 0 && q1 == 0) { cnt += 1 }
        if (p2 == 0 && q2 == 0) { cnt += 1 }
        if (p3 == 0 && q3 == 0) { cnt += 1 }
        
        if (cnt >= 2) { print("Returning NIL due to cnt"); return nil; }
        
        if (p1 == 0 && q1 == 0) {
            if (q2 == 0) {
                let t = (b0 - y0) / p2
                let x = p1 * t + x0
                let y = p2 * t + y0
                let z = p3 * t + z0
                print("SUCCESS")
                return SCNVector3(x,y,z)
            } else if (q3 == 0) {
                let t = (c0 - z0) / p3
                let x = p1 * t + x0
                let y = p2 * t + y0
                let z = p3 * t + z0
                print("SUCCESS")
                return SCNVector3(x,y,z)
            } else if (p2 == 0) {
                let s = (y0 - b0) / q2
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                print("SUCCESS")
                return SCNVector3(x,y,z)
            } else if (p3 == 0) {
                let s = (z0 - c0) / q3
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                print("SUCCESS")
                return SCNVector3(x,y,z)
            } else if ((p3 * q2 - p2 * q3) != 0) {
                let s = (p2 * (c0 - z0) + p3 * (y0 - b0)) / (p3 * q2 - p2 * q3)
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                print("SUCCESS")
                return SCNVector3(x,y,z)
            }
        } else if (p2 == 0 && q2 == 0) {
            if (q1 == 0) {
                let t = (a0 - x0) / p1
                let x = p1 * t + x0
                let y = p2 * t + y0
                let z = p3 * t + z0
                print("SUCCESS")
                return SCNVector3(x,y,z)
            } else if (q3 == 0) {
                let t = (c0 - z0) / p3
                let x = p1 * t + x0
                let y = p2 * t + y0
                let z = p3 * t + z0
                print("SUCCESS")
                return SCNVector3(x,y,z)
            } else if (p1 == 0) {
                let s = (x0 - a0) / q1
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                print("SUCCESS")
                return SCNVector3(x,y,z)
            } else if (p3 == 0) {
                let s = (z0 - c0) / q3
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                print("SUCCESS")
                return SCNVector3(x,y,z)
            } else if ((p3 * q1 - p1 * q3) != 0) {
                let s = (p1 * (c0 - z0) + p3 * (x0 - a0)) / (p3 * q1 - p1 * q3)
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                print("SUCCESS")
                return SCNVector3(x,y,z)
            }
        } else if (p3 == 0 && q3 == 0) {
            if (q1 == 0) {
                let t = (a0 - x0) / p1
                let x = p1 * t + x0
                let y = p2 * t + y0
                let z = p3 * t + z0
                print("SUCCESS")
                return SCNVector3(x,y,z)
            } else if (q2 == 0) {
                let t = (b0 - y0) / p2
                let x = p1 * t + x0
                let y = p2 * t + y0
                let z = p3 * t + z0
                print("SUCCESS")
                return SCNVector3(x,y,z)
            } else if (p1 == 0) {
                let s = (x0 - a0) / q1
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                print("SUCCESS")
                return SCNVector3(x,y,z)
            } else if (p2 == 0) {
                let s = (y0 - b0) / q2
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                print("SUCCESS")
                return SCNVector3(x,y,z)
            } else if ((p2 * q1 - p1 * q2) != 0) {
                let s = (p1 * (b0 - y0) + p2 * (x0 - a0)) / (p2 * q1 - p1 * q2)
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                print("SUCCESS")
                return SCNVector3(x,y,z)
            }
        } else if ((p1 + p2) != 0 && (p3 * (q1 + q2) -  q3 * (p1 + p2)) != 0) {
            let s = -(p3 * (a0 - x0 + b0 - y0) + (z0 - c0) * (p1 + p2)) / (p3 * (q1 + q2) -  q3 * (p1 + p2))
            let x = q1 * s + a0
            let y = q2 * s + b0
            let z = q3 * s + c0
            print("SUCCESS")
            return SCNVector3(x,y,z)
        }
        
        print("Returning NIL")
        return nil
    }
    
   
    func getIntersectionUpdated(aLine: Line, bLine: Line) -> SCNVector3? {
        if !Lines.shared.linesAreOnSamePlane(aLine: aLine, bLine: bLine) { return nil }
        print("Lines are on the same plane")
        
        let (aNormal, aPoint) = aLine.getParametricEquation()
        let (bNormal, bPoint) = bLine.getParametricEquation()
        
        let (p1, p2, p3) = aNormal.getComponents()
        let (q1, q2, q3) = bNormal.getComponents()
        let (x0, y0, z0) = aPoint.getComponents()
        let (a0, b0, c0) = bPoint.getComponents()
     //   var (x, y, z): (Float?, Float?, Float?) = (nil, nil, nil)
      //  var (t, s): (Float?, Float?) = (nil, nil)
        var cnt = 0
        if (p1 == 0 && q1 == 0 && x0 != a0) { return nil }
        if (p2 == 0 && q2 == 0 && y0 != b0) { return nil }
        if (p3 == 0 && q3 == 0 && z0 != c0) { return nil }
        
        if (p1 == 0 && q1 == 0) { cnt += 1 }
        if (p2 == 0 && q2 == 0) { cnt += 1 }
        if (p3 == 0 && q3 == 0) { cnt += 1 }
        
        if (cnt >= 2) { return nil }
        
        if (p1 == 0 && q1 == 0) {
            if (q2 == 0) {
                let t = (b0 - y0) / p2
                let x = p1 * t + x0
                let y = p2 * t + y0
                let z = p3 * t + z0
                return SCNVector3(x,y,z)
            } else if (q3 == 0) {
                let t = (c0 - z0) / p3
                let x = p1 * t + x0
                let y = p2 * t + y0
                let z = p3 * t + z0
                return SCNVector3(x,y,z)
            } else if (p2 == 0) {
                let s = (y0 - b0) / q2
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                return SCNVector3(x,y,z)
            } else if (p3 == 0) {
                let s = (z0 - c0) / q3
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                return SCNVector3(x,y,z)
            } else if ((p3 * q2 - p2 * q3) != 0) {
                let s = (p2 * (c0 - z0) + p3 * (y0 - b0)) / (p3 * q2 - p2 * q3)
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                return SCNVector3(x,y,z)
            }
        } else if (p2 == 0 && q2 == 0) {
            if (q1 == 0) {
                let t = (a0 - x0) / p1
                let x = p1 * t + x0
                let y = p2 * t + y0
                let z = p3 * t + z0
                return SCNVector3(x,y,z)
            } else if (q3 == 0) {
                let t = (c0 - z0) / p3
                let x = p1 * t + x0
                let y = p2 * t + y0
                let z = p3 * t + z0
                return SCNVector3(x,y,z)
            } else if (p1 == 0) {
                let s = (x0 - a0) / q1
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                return SCNVector3(x,y,z)
            } else if (p3 == 0) {
                let s = (z0 - c0) / q3
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                return SCNVector3(x,y,z)
            } else if ((p3 * q1 - p1 * q3) != 0) {
                let s = (p1 * (c0 - z0) + p3 * (x0 - a0)) / (p3 * q1 - p1 * q3)
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                return SCNVector3(x,y,z)
            }
        } else if (p3 == 0 && q3 == 0) {
            if (q1 == 0) {
                let t = (a0 - x0) / p1
                let x = p1 * t + x0
                let y = p2 * t + y0
                let z = p3 * t + z0
                return SCNVector3(x,y,z)
            } else if (q2 == 0) {
                let t = (b0 - y0) / p2
                let x = p1 * t + x0
                let y = p2 * t + y0
                let z = p3 * t + z0
                return SCNVector3(x,y,z)
            } else if (p1 == 0) {
                let s = (x0 - a0) / q1
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                return SCNVector3(x,y,z)
            } else if (p2 == 0) {
                let s = (y0 - b0) / q2
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                return SCNVector3(x,y,z)
            } else if ((p2 * q1 - p1 * q2) != 0) {
                let s = (p1 * (b0 - y0) + p2 * (x0 - a0)) / (p2 * q1 - p1 * q2)
                let x = q1 * s + a0
                let y = q2 * s + b0
                let z = q3 * s + c0
                return SCNVector3(x,y,z)
            }
        } else if ((p1 + p2) != 0 && (p3 * (q1 + q2) -  q3 * (p1 + p2)) != 0) {
            let s = -(p3 * (a0 - x0 + b0 - y0) + (z0 - c0) * (p1 + p2)) / (p3 * (q1 + q2) -  q3 * (p1 + p2))
            let x = q1 * s + a0
            let y = q2 * s + b0
            let z = q3 * s + c0
            return SCNVector3(x,y,z)
        }
        
        return nil
    }

    
    func getIntersectionOfLines(aLine: Line, bLine: Line) -> SCNVector3? {
        if !Lines.shared.linesAreOnSamePlane(aLine: aLine, bLine: bLine) { return nil }
        print("Lines are on the same plane")
    
        let (aNormal, aPoint) = aLine.getParametricEquation()
        let (bNormal, bPoint) = bLine.getParametricEquation()
        
        let (p1, p2, p3) = aNormal.getComponents()
        let (q1, q2, q3) = bNormal.getComponents()
        let (x0, y0, z0) = aPoint.getComponents()
        let (a0, b0, c0) = bPoint.getComponents()
        
        print("----- Line 1 ----")
        print("x = \(p1)t + \(x0)")
        print("y = \(p2)t + \(y0)")
        print("z = \(p3)t + \(z0)")
        
        print("----- Line 2 ----")
        print("x = \(q1)s + \(a0)")
        print("y = \(q2)s + \(b0)")
        print("z = \(q3)s + \(c0)")
        
        var (x, y, z): (Float?, Float?, Float?) = (nil, nil, nil)
        var s: Float = 0
        
        if ((p3 * q1 - p1 * q3) != 0) {
            s = (p1 * (c0 - z0) + p3 * (x0 - a0)) / (p3 * q1 - p1 * q3)
            x = q1 * s + a0
            y = q2 * s + b0
            z = q3 * s + c0
        }
        
        if ((p2 * q1 - p1 * q2) != 0) {
            s = (p1 * (b0 - y0) + p2 * (x0 - a0)) / (p2 * q1 - p1 * q2)
            x = q1 * s + a0
            y = q2 * s + b0
            z = q3 * s + c0
        }
        
        if ((p2 * q3 - p3 * q2) != 0) {
            s = (p3 * (b0 - y0) + p2 * (z0 - c0)) / (p2 * q3 - p3 * q2)
            x = q1 * s + a0
            y = q2 * s + b0
            z = q3 * s + c0
        }
        
        if x == nil || y == nil || z == nil {
            return nil
        } else {
            return SCNVector3Make(x!, y!, z!)
        }
    }
    
       func getMidPoint(a: SCNVector3, b: SCNVector3) -> SCNVector3 {
        return SCNVector3Make((a.x + b.x) / 2, (a.y + b.y) / 2, (a.z + b.z) / 2)
    }
    
       func getVectorLength(vector: SCNVector3) -> Float {
        return sqrtf(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
    }
    
       func getVectorAB(A: SCNVector3, B: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(B.x - A.x, B.y - A.y, B.z - A.z)
    }
    
       func getDistance(from a: SCNVector3, to b: SCNVector3) -> Float {
        return sqrtf((b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y) + (b.z - a.z) * (b.z - a.z))
    }
    
       func getDistFromPointToLine(normalVector: SCNVector3, pointOnLine: SCNVector3, point: SCNVector3) -> Float {
        let ab = getVectorAB(A: point, B: pointOnLine)
        let distance = getVectorLength(vector: ab * normalVector) / getVectorLength(vector: normalVector)
        return distance
    }
    
       func normalizeVector(_ iv: SCNVector3) -> SCNVector3 {
        let length = sqrt(iv.x * iv.x + iv.y * iv.y + iv.z * iv.z)
        if length == 0 {
            return SCNVector3(0.0, 0.0, 0.0)
        }
        
        return SCNVector3( iv.x / length, iv.y / length, iv.z / length)
    }
    
    func getDeterminantOf3x3Matrix(a11: Float, a12: Float, a13: Float, a21: Float, a22: Float, a23: Float, a31: Float, a32: Float, a33: Float) -> Float {
        return (a11 * a22 * a33 + a12 * a23 * a31 + a13 * a21 * a32 - a11 * a23 * a32 - a12 * a21 * a33 - a13 * a22 * a31)
    }
}
