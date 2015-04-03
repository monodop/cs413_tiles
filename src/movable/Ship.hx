package movable;

import game.World;
import starling.display.Image;
import starling.textures.Texture;
import cmath.Vector;
import utility.Utils;
import flash.geom.Point;
import game.Explosion;

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
	private var flags:Array<Image>;
	private var arriveCB:Void->Void = null;
	private var health:Float = 15;
	private var maxHealth:Float = 15;
	
	public var worthPoints:Int = 1;
	public var deathAnimationStr:String = null;
	
	public function new(texture:Texture, world:World, maxSpeed, maxAngle){
		super(texture, world);
		
		this.maxSpeed = maxSpeed;
		this.maxAngle = maxAngle;
		
		flags = new Array<Image>();
	}
	
	public function addFlag(flagTexture:Texture, flagCenterX:Float, flagCenterY:Float, shipPositionX:Float, shipPositionY:Float) {
		var flag = new Image(flagTexture);
		flag.smoothing = 'none';
		flag.pivotX = 18;
		flag.pivotY = 12;
		flag.x = 18;
		flag.y = 12;
		flag.pivotX = flagCenterX;
		flag.pivotY = flagCenterY;
		flag.x = shipPositionX;
		flag.y = shipPositionY;
		addChild(flag);
		flags.push(flag);
		
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
	
	/** See variable description */
	public function getBoatAcceleration():Float{
		return this.acceleration;
	}
	
	/** See variable description */
	public function getBreakPower():Float{
		return this.breakPower;
	}
	
	/** See variable description */
	public function getMaxAngle():Float{
		return this.maxAngle;
	}
	
	/** See variable description */
	public function getMaxSpeed():Float{
		return this.maxSpeed;
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
	
	public function getHealthRatio():Float{
		return health / maxHealth;
	}
	
	/** Update the max health */
	public function setMaxHealth(health:Float){
		this.health = this.maxHealth = health;
	}
	
	/** Update the health */
	public function healShip(heal:Float){
		this.health += heal;
		if(health > maxHealth){
			health = maxHealth;
			
		}
	}
	
	/** Deal damage to the ship */
	public function dealDamage(damage:Float){
		health -= damage;
		
		if(health <= 0){
			health = 0;
			world.destroyShip(this);
		}
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
		
		if(getMag() <= 0.0001){
			thisVector = Vector.getVectorFromAngle( this.rotation ).multiply(acceleration);
		} else {
			thisVector = new Vector(vx,vy);
		}
		
		this.vx = thisVector.vx;
		this.vy = thisVector.vy;
	}
	
	public function onArrive(arriveCB:Void->Void){
		this.arriveCB = arriveCB;
	}
	
	/** Taking in a list of ships, try to fire at them */
	public function tryPredictiveFireAtShips(time:Float, a_Ship:List<Ship>, bulletList:List<Bullet>, variance:Float){
		for(ship in a_Ship){
			tryPredictiveFire(time, ship, bulletList, variance);
		}
	}
	
	/** Assuming a linear path, attempts to predict the location of the enemy ship, and then fire at that */
	public function tryPredictiveFire(time:Float, ship:Ship, bulletList:List<Bullet>, variance:Float = 0){
		for(cannon in a_Cannon){
			// Cannon position
			var cannonPos = cannon.getTransformationMatrix(this.parent).transformPoint(new Point());
			
			// Distance of cannon to enemy ship
			var distFromShip = Vector.getVector(cannonPos.x, cannonPos.y, ship.x, ship.y).getMag();
			
			var shipVector = new Vector(ship.vx, ship.vy);
			var shipMag = shipVector.getMag();
			var cannonMag = cannon.bulletSpeed;
			
			// The value forming a right triangle, which must be multiplied by the cannon and enemy magnitudes
			//	 |\
			// d | \ cannonMag*s
			//	 |__\
			//    shipMag*s
			var modValue = Math.sqrt( (distFromShip*distFromShip) / (cannonMag*cannonMag - shipMag*shipMag) );
			
			shipVector.multiply(modValue);
			shipVector.vx += ship.x + Math.random()*variance*2 - variance;
			shipVector.vy += ship.y + Math.random()*variance*2 - variance;
			
			tryFireCannons(time, shipVector.vx, shipVector.vy, bulletList);
		}
	}
	
	public function tryFireCannons(time:Float, targetX:Float, targetY:Float, bulletList:List<Bullet>){
		for(cannon in a_Cannon){
			if( cannon.fireAtPoint(time, targetX, targetY) ){
				var cannonPos = cannon.getTransformationMatrix(this.parent).transformPoint(new Point());
				
				var fireVector = Vector.getVector(cannonPos.x, cannonPos.y, targetX, targetY).normalize().multiply(cannon.bulletSpeed);
				
				var newBullet = new Bullet(cannon.bulletTexture, world, this, time, 10000);
					newBullet.vx = fireVector.vx;
					newBullet.vy = fireVector.vy;
					newBullet.x = cannonPos.x;
					newBullet.y = cannonPos.y;
					
				bulletList.push(newBullet);
				world.addMovable(newBullet);
				
				fireVector.normalize().multiply(0.35);
				var explosionPos = this.parent.getTransformationMatrix(cannon).transformPoint(new Point(cannonPos.x + fireVector.vx, cannonPos.y + fireVector.vy));
				var explosion:Explosion = new Explosion("explosions/pirate_cannon_shot_", 8);
					explosion.scaleX = explosion.scaleY = 36;
					explosion.x = explosionPos.x;
					explosion.y = explosionPos.y;
				cannon.addChild(explosion);
				Root.assets.playSound("explosion");
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
		if(arrived || distFromPoint < getMag()*1.2 || ( turnFix && movingTowardsPoint && distFromPoint > prevDistFromPoint ) ){
			var thisVector = new Vector(vx,vy).multiply(breakPower);
			this.vx = thisVector.vx;
			this.vy = thisVector.vy;
			
			var doCallback = (!arrived && arriveCB != null);
			arrived = true;
			
			if(doCallback)
				arriveCB(); 
			
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
		for(flag in this.flags) {
			flag.rotation = -this.rotation - Utils.deg2rad(90);
		}
		vx = thisVector.vx;
		vy = thisVector.vy;
		
		return returnVal;
	}
}