package game;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Sprite;
import utility.Point;

class Camera extends Sprite
{

	private var velocity:Point;
	private var boundaries:Rectangle;
	
	public function new(boundaries:Rectangle) 
	{
		velocity = new Point();
		this.boundaries = boundaries;
		super();
	}
	
	public function moveTowards(x:Float, y:Float) {
		
		var pos = new Point(this.x, this.y);
		var target = new Point(x, y);
		
		var vector = target.sub(pos);
		if(vector.lengthSqr() > 0.001)
			vector = vector.mul(0.05);
		
		this.x += vector.x;
		this.y += vector.y;
		
	}
	
	public function applyCamera(object:DisplayObject) {
		
		object.pivotX = this.x;
		object.pivotY = this.y;
		
		var b = getCameraBounds(object, 0);
		var x = b.left + b.width / 2;
		var y = b.top + b.height / 2;
		
		object.pivotX = x;
		object.pivotY = y;
		
	}
	
	public function getCameraBounds(object:DisplayObject, ?offset:Float = 0):Rectangle {
		
		var tl = Point.fromPoint(object.globalToLocal(new flash.geom.Point()));
		var br = Point.fromPoint(object.globalToLocal(new flash.geom.Point(Starling.current.stage.stageWidth, Starling.current.stage.stageHeight)));
		
		if (tl.x < boundaries.x) {
			var diff = boundaries.x - tl.x;
			tl.x += diff;
			br.x += diff; 
		}
		if (tl.y < boundaries.y) {
			var diff = boundaries.y - tl.y;
			tl.y += diff;
			br.y += diff;
		}
		if (br.x > boundaries.right) {
			var diff = boundaries.right - br.x;
			tl.x += diff;
			br.x += diff;
		}
		if (br.y > boundaries.bottom) {
			var diff = boundaries.bottom - br.y;
			tl.y += diff;
			br.y += diff;
		}
		
		if (tl.x - offset/2 < boundaries.x) {
			var diff = boundaries.x - tl.x + offset / 2;
			tl.x += diff;
		}
		if (tl.y - offset/2 < boundaries.y) {
			var diff = boundaries.y - tl.y + offset/2;
			tl.y += diff;
		}
		if (br.x + offset/2 > boundaries.right) {
			var diff = boundaries.right - br.x - offset/2;
			br.x += diff;
		}
		if (br.y + offset/2 > boundaries.bottom) {
			var diff = boundaries.bottom - br.y - offset/2;
			br.y += diff;
		}
		
		return new Rectangle(tl.x - offset/2, tl.y - offset/2, br.x - tl.x + offset, br.y - tl.y + offset);
		
	}
	
}