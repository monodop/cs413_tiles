package colliders;
import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.Sprite;
import utility.Point;

// A base collider class. Don't initalize one of these directly, or you'll get weird collision results.
class Collider extends Sprite
{
	
	private var inner_radius:Float;
	private var radius:Float;
	private var center:Point;
	
	private var owner:HasCollider;
	public var quadTree:Quadtree;
	
	private var layers:Array<String> = ["default"];
	
	public function new(owner:HasCollider, layers:Array<String>) {
		super();
		
		this.center = new Point();
		this.inner_radius = 0.0;
		this.radius = 0.0;
		this.layers = layers;
		
		this.owner = owner;
	}
	
	// Determine if this collider is clipping with another collider.
	// if you provide a CollisionInformation object, then it will be filled with
	// useful information, like the minimum translation vector (which might not be
	// 100% correct), and the collision normals.
	public function isClipping(collider:Collider, ?collisionInfo:CollisionInformation):Bool {
		
		if (collider == null)
			return false;
		
		if (!Std.is(this, PolygonCollider) && Std.is(collider, PolygonCollider)) {
			var res = collider.isClipping(this, collisionInfo);
			if (collisionInfo != null)
				collisionInfo.reverse();
			return res;
		}
		
		var c1 = Point.fromPoint(localToGlobal(center.toGeom()));
		var c2 = Point.fromPoint(collider.localToGlobal(collider.center.toGeom()));
		
		var distance = c1.distance(c2);
		var threshold = this.radius + collider.radius;
		
		var clipping = distance <= threshold;
		
		if (collisionInfo != null) {
			
			var src_unit = c2.sub(c1).normalize();
			collisionInfo.normal_src = src_unit;
			collisionInfo.pos_src = src_unit.mul(this.radius).add(c1);
			
			var dest_unit = c1.sub(c2).normalize();
			collisionInfo.normal_target = dest_unit;
			collisionInfo.pos_target = dest_unit.mul(collider.radius).add(c2);
			
			collisionInfo.collider_src = this;
			collisionInfo.collider_target = collider;
			
			var depth = collisionInfo.pos_src.sub(collisionInfo.pos_target).length();
			collisionInfo.depth = depth;
			collisionInfo.mtv_src = src_unit.mul(depth);
			collisionInfo.mtv_target = dest_unit.mul(depth);
		}
		
		return clipping;
	}
	
	// Get the center point of the collider.
	// For polygons, this is calculated using a centroid algorithm.
	// For circles, this is calculated as the actual center of the circle.
	public function getCenter() {
		return this.center;
	}
	
	// This is basically the same as the inner radius, but 1.5x bigger.
	// This radius is used to check if two colliders are close enough to
	// collide at all.
	public function getRadius() {
		return this.radius;
	}
	
	// Get the minimum radius of the collider.
	// For polygons, this is the distance to the farthest point from the center.
	// For circles, this is the radius.
	public function getInnerRadius() {
		return this.radius;
	}
	
	// Gets the owner of the collider.
	public function getOwner() {
		return this.owner;
	}
	
	// Gets the physics layers this collider belongs to.
	public function getLayers():Array<String> {
		return this.layers;
	}
	
	// If you ever move a collider, call this function to update the quadTree.
	public function updateQuadtree() {
		if(this.quadTree != null)
			this.quadTree.update(this);
	}
	
	// Gets the rectangular bounds around this collider in the target space.
	public override function getBounds(targetSpace:DisplayObject, ?resultRect:Rectangle):Rectangle {
		
		var c = center.toGeom();
		var e = center.add(new Point(getInnerRadius(), 0)).toGeom();
		
		var matrix = getTransformationMatrix(targetSpace);
		var center = Point.fromPoint(matrix.transformPoint(c));
		var edge = Point.fromPoint(matrix.transformPoint(e));
		
		var newRadius = center.distance(edge);
		
		var tl = center.sub(new Point(newRadius)).toGeom();
		var br = center.add(new Point(newRadius)).toGeom();
		var width = Math.abs(br.x - tl.x);
		var height = Math.abs(br.y - tl.y);
		tl.x = Math.min(tl.x, br.x);
		tl.y = Math.min(tl.y, br.y);
		
		if (resultRect == null)
			resultRect = new Rectangle();
		resultRect.x = tl.x;
		resultRect.y = tl.y;
		resultRect.width = width;
		resultRect.height = height;
		return resultRect;
	}
	
	// This is called when the object is destroyed to remove it from it's associated quadTree.
	public override function dispose() {
		if (quadTree!= null) 
			quadTree.remove(this);
		super.dispose();
	}
}