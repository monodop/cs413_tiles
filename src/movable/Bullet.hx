package movable;
import cmath.Vector;
import colliders.CircleCollider;
import utility.Point;
import game.World;
import starling.textures.Texture;

class Bullet extends SimpleMovable {
	var spawnTime:Float;
	var aliveTime:Float;
	
	public function new(texture:Texture, world:World, spawnTime:Float, aliveTime:Float){
		super(texture, world);
		this.spawnTime = spawnTime;
		this.aliveTime = aliveTime;
	}
	
	public function shouldDespawn(time:Float):Bool{
		return ((time - spawnTime) > aliveTime);
	}
	
	public override function initColliders() {
		
		this.collider = new CircleCollider(this, ["projectile"], new Point(this.pivotX, this.pivotY), this.width / 2);
		addChild(this.collider);
	}
}