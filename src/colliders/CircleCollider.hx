package colliders;
import starling.display.Image;
import utility.Point;

// A collider that has a center point and a radius.
class CircleCollider extends Collider
{

	private var debugCircle:Image;
	private var showDebug:Bool = false;
	
	public function new(owner:HasCollider, layers:Array<String>, center:Point, radius:Float) 
	{
		super(owner, layers);
		this.center = center;
		this.inner_radius = radius;
		this.radius = radius; // * 1.5;
		
		debugCircle = new Image(Root.assets.getTexture("debugCircle"));
		debugCircle.pivotX = 8.0;
		debugCircle.pivotY = 8.0;
		debugCircle.x = center.x;
		debugCircle.y = center.y;
		debugCircle.scaleX = this.inner_radius / 8.0;
		debugCircle.scaleY = this.inner_radius / 8.0;
		debugCircle.color = 0xff0000;
		debugCircle.smoothing = 'none';
		debugCircle.alpha = 0.2;
		debugCircle.visible = false;
		this.addChild(debugCircle);
		
	}
	
	public override function toggleDebug() {
		
		showDebug = !showDebug;
		debugCircle.visible = showDebug;
		
	}
	
	public override function getInnerRadius():Float {
		return this.inner_radius;
	}
	
}