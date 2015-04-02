package colliders;
import starling.display.Image;
import utility.Point;

// A collider that has a center point and a radius.
class CircleCollider extends Collider
{
	
	public function new(owner:HasCollider, layers:Array<String>, center:Point, radius:Float) 
	{
		super(owner, layers);
		this.center = center;
		this.inner_radius = radius;
		this.radius = radius; // * 1.5;
		
	}
	
	public override function getInnerRadius():Float {
		return this.inner_radius;
	}
	
}