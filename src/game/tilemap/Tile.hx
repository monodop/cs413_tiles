package game.tilemap;

import colliders.Collider;
import colliders.CollisionInformation;
import colliders.HasCollider;
import starling.display.Image;
import starling.display.Sprite;

class Tile extends Sprite implements HasCollider
{

	private var sprite:Image;
	private var asset:String;
	private var solid:Bool;
	private var tilemap:Tilemap;
	
	private var worldX:Int;
	private var worldY:Int;
	
	public function new(asset:String, solid:Bool, tilemap:Tilemap, x:Int, y:Int) 
	{
		super();
		
		this.asset = asset;
		this.solid = solid;
		this.tilemap = tilemap;
		
		this.worldX = x;
		this.worldY = y;
		
		init();
		
	}
	
	public function init() {
		
		this.sprite = new Image(Root.assets.getTexture(asset));
		this.sprite.pivotX = this.sprite.width / 2.0;
		this.sprite.pivotY = this.sprite.height / 2.0;
		this.sprite.scaleX = 1.0 / tilemap.world.tileSize;
		this.sprite.scaleY = 1.0 / tilemap.world.tileSize;
		this.sprite.smoothing = 'none';
		addChild(sprite);
		
	}
	
	
	// HasCollider Required Methods
	public function isSolid():Bool {
		return solid;
	}
	
	public function getColliders(): Array<Collider> {
		//return [this.collider];
		return [];
	}
	public function updateColliders() {
		for (collider in getColliders()) { collider.updateQuadtree(); }
	}
	public function setPos(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;
	}
	public function collision(self:Collider, object:Collider, collisionInfo:CollisionInformation):Bool {
		//var owner:HasCollider = object.getOwner();
		//
		//if (Std.is(owner, Projectile)) {
			//var projectile:Projectile = cast owner;
			//if (projectile.getType() == ProjectileType.SHELL) {
				//projectile.detonate();
				//return false;
			//}
		//}
		
		return true;
	}
}