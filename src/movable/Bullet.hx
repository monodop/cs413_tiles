package movable;
import cmath.Vector;
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
}