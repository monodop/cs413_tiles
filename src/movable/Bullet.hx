package movable;
import cmath.Vector;
import starling.textures.Texture;

class Bullet extends SimpleMovable {
	var spawnTime:Float;
	var aliveTime:Float;
	
	public function new(texture:Texture, spawnTime:Float, aliveTime:Float){
		super(texture);
		this.spawnTime = spawnTime;
		this.aliveTime = aliveTime;
	}
	
	public function shouldDespawn(time:Float):Bool{
		return ((time - spawnTime) > aliveTime);
	}
}