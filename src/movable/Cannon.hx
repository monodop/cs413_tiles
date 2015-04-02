package movable;

import cmath.Vector;
import game.World;
import starling.display.Image;
import starling.display.Sprite;
import flash.geom.Point;
import starling.textures.Texture;
import starling.display.Quad;

class Cannon extends Sprite{
	private static var TWO_PI:Float = 6.283185;
	
	var cannonQuad:Quad;
	var firingAngle:Float;
	var firingDistance:Float;
	var firingThreshold:Float;
	var cooldown:Float;
	var lastFireTime:Float = -9999;
	
	private var world:World;
	
	// Global coordinates only updated after a true fireAtPoint
	public var bulletTexture:Texture;
	public var bulletSpeed:Float = 5.0 / 24.0;
	
	public function new(bulletTexture:Texture, firingAngle:Float, firingThreshold:Float, firingDistance:Float, cooldown:Float){
		super();
		this.bulletTexture = bulletTexture;
		this.cooldown = cooldown;
		this.firingAngle = firingAngle;
		this.firingDistance = firingDistance;
		this.firingThreshold = firingThreshold;
		
		
		// Hacky cannon
		cannonQuad = new Quad(8,4,0);
		cannonQuad.pivotX = cannonQuad.width - 2;
		cannonQuad.pivotY = cannonQuad.height / 2;
		cannonQuad.rotation = firingAngle;
		addChild(cannonQuad);
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
	public function fireAtPoint(time:Float, x:Float, y:Float):Bool{
		if(time - lastFireTime >= cooldown){
			lastFireTime = time;
			
			// Translate (0,0) from the cannon's space to the world's space
			var worldPos = getTransformationMatrix(this.parent.parent).transformPoint(new Point());
			// Get the direct vector of the cannon to the target point
			var directVector = Vector.getVector(x, y, worldPos.x, worldPos.y);	
			
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
					cannonQuad.rotation = directAngle - this.parent.rotation;
					return true;
				}
			}
		}
		
		return false;
	}
}