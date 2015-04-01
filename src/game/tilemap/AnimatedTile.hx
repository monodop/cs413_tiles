package game.tilemap;
import starling.animation.Juggler;
import starling.core.Starling;
import starling.display.MovieClip;

class AnimatedTile extends Tile
{

	private var animSprite:MovieClip;
	
	public function new(asset:String, solid:Bool, tilemap:Tilemap, x:Int, y:Int) 
	{
		super(asset, solid, tilemap, x, y);
		
	}
	
	public override function init() {
		
		this.animSprite = new MovieClip(Root.assets.getTextures(asset));
		this.animSprite.pivotX = this.animSprite.width / 2.0;
		this.animSprite.pivotY = this.animSprite.height / 2.0;
		this.animSprite.scaleX = 1.0 / tilemap.world.tileSize;
		this.animSprite.scaleY = 1.0 / tilemap.world.tileSize;
		this.animSprite.smoothing = 'none';
		this.animSprite.loop = true;
		this.animSprite.play();
		this.animSprite.fps = 2;
		Starling.juggler.add(this.animSprite);
		addChild(animSprite);
		
	}
	
}