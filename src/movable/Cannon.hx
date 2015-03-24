package movable;

import cmath.Vector;
import starling.display.Sprite;
import flash.geom.Point;

class Cannon extends Sprite{
	private static var TWO_PI:Float = 6.283185;
	
	var firingAngle:Float;
	var firingDistance:Float;
	var firingThreshold:Float;
	
	
	public function new(firingAngle, firingThreshold, firingDistance){
		super();
		this.firingAngle = firingAngle;
		this.firingDistance = firingDistance;
		this.firingThreshold = firingThreshold;
	}
	
	/** Maximum difference when comparing to the base angle */
	public function setFiringThreshold(firingThreshold:Float){
		if(firingThreshold >= 0){
			this.firingThreshold = firingThreshold;
		}
	}
	
	/** Maximum firing distance */
	public function setFiringDistance(firingDistance:Float){
		if(firingDistance > 0){
			this.firingDistance = firingDistance;
		}
	}
	
	/** Base angle at which the cannon is aiming at */
	public function setFiringAngle(firingAngle:Float){
		this.firingAngle = firingAngle;
	}
	
	/** Attempts to fire at a point if it is within the dist & angle */
	public function fireAtPoint(x:Float, y:Float){
		// Get the global coordinate of the cannon
		var globalPoint = this.localToGlobal(new Point(this.parent.stage.x, this.parent.stage.y));
			
		// Get the direct vector of the cannon to the target point
		var directVector = Vector.getVector(x, y, globalPoint.x, globalPoint.y);
		
		// If we're in range...
		if(directVector.getMag() <= firingDistance){
			// Get the direct vector's normalized angle
			var directAngle = directVector.getAngle();
				directAngle = (directAngle > 0) ? directAngle : directAngle + TWO_PI;
			
			// Angle of the parent -> current angle the cannon is facing
			var parentAngle = (this.parent.rotation > 0) ? this.parent.rotation : this.parent.rotation + Math.PI*2; 
			var currentAngle = (parentAngle + firingAngle) % TWO_PI;
				
			// Angle difference between the current & direct angles
			var angleDiff = Math.abs((Math.abs(directAngle - currentAngle) + Math.PI) % TWO_PI - Math.PI);
			
			// We can fire, yay.
			if(angleDiff <= firingThreshold){
				trace("Firing");
				return;
			}
		}
		
		trace("Not firing");
	}
}