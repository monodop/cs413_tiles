package colliders;

import utility.Point;

// A polygon collider in the shape of a box with a width and height
class BoxCollider extends PolygonCollider
{

	public function new(owner:HasCollider, layers:Array<String>, width:Float, height:Float, center:Point) 
	{
		
		var tl = new Point(center.x - width / 2, center.y - height / 2);
		var tr = new Point(center.x + width / 2, center.y - height / 2);
		var bl = new Point(center.x - width / 2, center.y + height / 2);
		var br = new Point(center.x + width / 2, center.y + height / 2);
		
		var points = [tl, tr, br, bl];
		
		super(owner, layers, points);
	}
	
}