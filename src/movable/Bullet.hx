package movable;
import cmath.Vector;
import colliders.CircleCollider;
import colliders.Collider;
import colliders.CollisionInformation;
import colliders.HasCollider;
import utility.Point;
import game.World;
import starling.textures.Texture;

class Bullet extends SimpleMovable {
	var spawnTime:Float;
	var aliveTime:Float;
	var shooter:SimpleMovable;
	var forceDespawn:Bool = false;
	
	public function new(texture:Texture, world:World, shooter:SimpleMovable, spawnTime:Float, aliveTime:Float){
		super(texture, world);
		this.spawnTime = spawnTime;
		this.aliveTime = aliveTime;
		this.shooter = shooter;
	}
	
	public function shouldDespawn(time:Float):Bool{
		return forceDespawn || ((time - spawnTime) > aliveTime);
	}
	
	public override function initColliders() {
		
		this.collider = new CircleCollider(this, ["projectile"], new Point(this.pivotX, this.pivotY), this.width / 2);
		addChild(this.collider);
	}
	
	public override function collision(self:Collider, object:Collider, collisionInfo:CollisionInformation):Bool {
		var owner:HasCollider = object.getOwner();
		
		if (Std.is(owner, Ship)) {
			var ship:Ship = cast owner;
			
			if (ship != shooter){
				forceDespawn = true;
				ship.dealDamage(1);
				return true;
			}
		}
		
		return false;
	}
}