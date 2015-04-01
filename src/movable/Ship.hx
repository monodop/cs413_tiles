package movable;

import game.World;
import starling.textures.Texture;
import cmath.Vector;

class Ship extends SimpleMovable {

	private var acceleration:Float = 1.0;		// The speed at which the boat will accelerate
	private var breakPower:Float = 0;			// The modifier applied to velocity in order to stop the boat
	private var maxAngle:Float = Math.PI*2;		// Maximum turning angle
	private var maxSpeed:Float;					// Maximum speed
	
	private var gotoX:Float;					// X coordinate to go to
	private var gotoY:Float;					// Y coordinate to go to 
	private var arrived:Bool = false;			// Whether or not we got to the point
	private var normalMove:Bool = false;		// If set to true, the boat will continue like a normal SimpleMovable object
	private var prevDistFromPoint:Float = 0;	// The previous distance from the point (to prevent infinite circling)
	private var movingTowardsPoint:Bool = true; // Whether or not we are moving towards the point;
	private var a_Cannon:Array<Cannon> = new Array<Cannon>();
	
	public var turnFix:Bool = true;
	
	public function new(texture:Texture, world:World, maxSpeed, maxAngle){
		super(texture, world);
		
		this.maxSpeed = maxSpeed;
		this.maxAngle = maxAngle;
	}
	
	/** See variable description */
	public function setBoatAcceleration(acceleration:Float){
		this.acceleration = acceleration > maxSpeed || acceleration <= 0 ? maxSpeed : acceleration;
	}
	
	/** See variable description */
	public function setBreakPower(breakPower:Float){
		this.breakPower = breakPower;
	}
	
	/** See variable description */
	public function setMaxAngle(maxAngle:Float){
		this.maxAngle = maxAngle;
	}
	
	/** See variable description */
	public function setMaxSpeed(maxSpeed:Float){
		this.maxSpeed = maxSpeed;
	}
	
	/** Stops the boat from moving, starts slowing down */
	public function stopMovement(){ 
		this.arrived = true;
		this.normalMove = false;
	}
	
	/** Makes the boat continue in the direction it is currently going */
	public function holdSpeed(){
		this.normalMove = true;
	}
	
	/** See variable description */
	public function getGoToX():Float{ return gotoX; }
	
	/** See variable description */
	public function getGoToY():Float{ return gotoY; }
	
	/** Navigates this boat towards a point */
	public function goTo(x:Float,y:Float){
		gotoX = x;
		gotoY = y;
		prevDistFromPoint = distanceFromDest();
		movingTowardsPoint = arrived = normalMove = false;
		
		var thisVector:Vector;
		
		if(getMag() <= 0.1){
			thisVector = Vector.getVectorFromAngle( this.rotation ).multiply(acceleration);
		} else {
			thisVector = new Vector(vx,vy);//.normalize().multiply(maxSpeed);
		}
		
		this.vx = thisVector.vx;
		this.vy = thisVector.vy;
	}
	
	public function tryFireCannons(time:Float, targetX:Float, targetY:Float, bulletList:List<Bullet>){
		for(cannon in a_Cannon){
			if( cannon.fireAtPoint(time, targetX, targetY) ){
				var fireVector = Vector.getVector(cannon.globalX, cannon.globalY, targetX, targetY).normalize().multiply(cannon.bulletSpeed);
				
				var newBullet = new Bullet(cannon.bulletTexture, world, time, 10000);
					newBullet.vx = fireVector.vx;
					newBullet.vy = fireVector.vy;
					newBullet.x = cannon.globalX;
					newBullet.y = cannon.globalY;
					
				bulletList.push(newBullet);
				this.parent.addChild(newBullet);
			}
		}
	}
	
	/** Adds a cannon to this ship at the LOCAL x / y coordinates */
	public function addCannon(cannon:Cannon, x:Float, y:Float){
		a_Cannon.push(cannon);
		this.addChild(cannon);
		cannon.x = x;
		cannon.y = y;
	}
	
	public function distanceFromDest():Float{
		return Math.sqrt((x-gotoX)*(x-gotoX) + (y-gotoY)*(y-gotoY));
	}
	
	/** Overriden version of the normal apply velocity, navigates towards a point */
	public override function applyVelocity(modifier:Float = 1.0):Bool{
		if(normalMove) {
			return super.applyVelocity(modifier);
		}
		
		var distFromPoint = distanceFromDest();
		
		/* If we have arrived, decelerate the boat
		 * We have arrived if:
		 * Arrived is set to true
		 * We are within our velocity's magnitude to the point
		 * We were previously moving towards the point, but are now moving away */
		if(arrived || distFromPoint < getMag() || ( turnFix && movingTowardsPoint && distFromPoint > prevDistFromPoint ) ){
			arrived = true;
			
			var thisVector = new Vector(vx,vy).multiply(breakPower);
			this.vx = thisVector.vx;
			this.vy = thisVector.vy;
			
			return super.applyVelocity(modifier);
		}
		
		// Checks to see if we are moving towards, or away
		if(distFromPoint < prevDistFromPoint){
			movingTowardsPoint = true;
		}
		
		// Update the previous distance variable
		prevDistFromPoint = distFromPoint;
			
		// Apply the velocity so we can start working with it
		var returnVal = super.applyVelocity(modifier);
	
		var thisVector = new Vector(vx,vy);
		var directVector = Vector.getVector(x,y,gotoX,gotoY);
		var angle = directVector.getVectorAngle( thisVector );
		
		// Angle correction
		if(Math.abs(angle) > Math.PI){
			angle -= angle/Math.abs(angle)*2*Math.PI;
		}
		
		// Apply a maximum angle if the angle is greater than that
		if(Math.abs(angle) > maxAngle){
			angle = angle/Math.abs(angle) * maxAngle;
		}
		
		// Fix the rotation of the vector to our new angle
		thisVector = thisVector.rotate(angle);
		
		// Apply our acceleration to the vector, minding maxSpeed
		var adjustedSpeed = thisVector.getMag() + acceleration;
		if(adjustedSpeed > maxSpeed)
			adjustedSpeed = maxSpeed;
			
		thisVector.normalize().multiply(adjustedSpeed);
		
		this.rotation = thisVector.getAngle();
		vx = thisVector.vx;
		vy = thisVector.vy;
		
		return returnVal;
	}
}