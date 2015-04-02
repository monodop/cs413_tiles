package movable;
import colliders.*;
import game.World;
import starling.textures.Texture;
import starling.display.Image;
import starling.display.Sprite;
import cmath.Vector;
import utility.Point;

class SimpleMovable extends Sprite implements HasCollider {
	var vx:Float = 0;	// X Velocity
	var vy:Float = 0;	// Y Velocity
	var ax:Float = 0;  	// X Acceleration
	var ay:Float = 0;	// Y Acceleration
	
	private var world:World;
	
	private var collider:Collider;
	
	/** Return the vx of this */
	public function getVX() : Float{
		return vx;
	}
	
	/** Return the vy of this */
	public function getVY() : Float{
		return vy;
	}
	
	/** Return the vxy in velocity format */
	public function getVelVector() : Vector{
		return new Vector(vx,vy);
	}
	
	/** Set the location of the circle, (note: this is in relation to the CENTER of the circle)
	public function setLoc(x:Float, y:Float){
		this.x = x - radius;
		this.y = y - radius;
	} */
	
	/** Gets the magnitude of the object's velocities */
	public function getMag():Float{
		return Math.sqrt(vx*vx+vy*vy);
	}
	
	/** Set the velocities of the object */
	public function setVelocity(vx:Float, vy:Float){
		this.vx = vx;
		this.vy = vy;
	}
	
	/** Set the acceleration of the object */
	public function setAcceleration(ax:Float, ay:Float){
		this.ax = ax;
		this.ay = ay;
	}
	
	/** Applies the acceleration of the object to it's velocities */
	public function applyAcceleration():Bool{
		this.vx += ax;
		this.vy += ay;
		return true;
	}
	
	/** Applies the velocities of the object to the x & y coordinates */
	public function applyVelocity(modifier:Float = 1.0):Bool{
		var movVector = new Vector(vx,vy).normalize().multiply(getMag()*modifier);
		
		if(Math.isNaN(movVector.getMag())){
			movVector.vx = movVector.vy = 0;
		}
		
		// Apply the velocities
		this.x += movVector.vx;
		this.y += movVector.vy;
		setPos(this.x, this.y);
		
		// Apply acceleration
		this.vx += ax;
		this.vy += ay;
		
		return true;
	}
	
	public function new(texture:Texture, world:World){
		super();
		
		this.world = world;
		
		if (texture != null) {
			var img = new Image(texture);
			img.smoothing = 'none';
			this.addChild( img );
		}
		
		this.pivotX = this.width/2.0;
		this.pivotY = this.height/2.0;
		
		this.collider = new BoxCollider(this, ["ship"], this.width, this.height, new Point( this.pivotX, this.pivotY));
		addChild(this.collider);
		
		this.scaleX = 1.0 / world.tileSize;
		this.scaleY = 1.0 / world.tileSize;
	}
	
	
	public function getColliders():Array<Collider> {
		return [this.collider];
	}
	
	public function collision(self:Collider, object:Collider, collisionInfo:CollisionInformation):Bool {
		//var owner:HasCollider = object.getOwner();
		//
		//if (Std.is(owner, Projectile)) {
			//var projectile:Projectile = cast owner;
			//if(self.name == "PlayerShield") {
				//Root.assets.playSound("ShieldHit", 0, 0, Root.sfxTransform(0.25));
			//} else if (self.name == "PlayerTorso") {
				//projectile.hitDamagable(this);
				//projectile.detonate();
				//return false;
			//}
		//}
		return true;
	}
	public function updateColliders() {
		for (collider in getColliders()) { collider.updateQuadtree(); }
	}
	public function setPos(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;
		updateColliders();
	}
}