package colliders;
import flash.geom.Rectangle;
import game.Player;
import starling.display.DisplayObject;
import starling.display.Image;
import utility.Point;

// A collider that is defined by a series of points.
// I don't know if it makes much of a difference, but I recommend
// defining the points in clockwise order.
class PolygonCollider extends Collider
{
	
	private var points:Array<Point>;

	public function new(owner:HasCollider, layers:Array<String>, points:Array<Point>) 
	{
		super(owner, layers);
		
		this.points = points;
		
		this.center = new Point();
		for (point in points) {
			this.center = this.center.add(point);
		}
		this.center = this.center.div(points.length);
		
		this.radius = 0.0;
		for (point in points) {
			this.radius = Math.max(this.radius, this.center.distanceSqr(point));
		}
		this.inner_radius = Math.sqrt(this.radius);
		this.radius = this.inner_radius * 1.5;
		
	}
	
	// Get a point in the collider in a specific coordinate space
	public function getPoint(index:Int, ?space:DisplayObject):Point {
		if(space == null)
			return Point.fromPoint(localToGlobal(points[index].toGeom()));
		return Point.fromPoint(getTransformationMatrix(space).transformPoint(points[index].toGeom()));
	}
	
	public override function isClipping(collider:Collider, ?collisionInfo:CollisionInformation) {
		
		if (!super.isClipping(collider, collisionInfo)) {
			return false;
		}
		
		if (Std.is(collider, PolygonCollider)) {
			
			var c1:PolygonCollider = this;
			var c2:PolygonCollider = cast collider;
			
			var vecs_c1:Array<Point> = c1.prepareVectors();
			var vecs_c2:Array<Point> = c2.prepareVectors();
			
			var normals_c1:Array<Point> = c1.getNormals(vecs_c1);
			var normals_c2:Array<Point> = c2.getNormals(vecs_c2);
			
			var overlap:Float = Math.POSITIVE_INFINITY;
			var smallest:Point = null;
			
			for (i in 0...normals_c1.length) {
				
				var res1:MinMaxContainer = getMinMax(vecs_c1, normals_c1[i]);
				var res2:MinMaxContainer = getMinMax(vecs_c2, normals_c1[i]);
				
				if (res1.max_proj < res2.min_proj || res2.max_proj < res1.min_proj) 
					return false;
				
				var o = Math.min(
							Math.abs(res1.max_proj - res2.min_proj),
							Math.abs(res2.max_proj - res1.min_proj)
							);
				if (o < overlap) {
					overlap = o;
					smallest = normals_c1[i];
				}
			}
			
			for (i in 0...normals_c2.length) {
				
				var res1:MinMaxContainer = getMinMax(vecs_c1, normals_c2[i]);
				var res2:MinMaxContainer = getMinMax(vecs_c2, normals_c2[i]);
				
				if (res1.max_proj < res2.min_proj || res2.max_proj < res1.min_proj)
					return false;
					
				var o = Math.min(
							Math.abs(res1.max_proj - res2.min_proj),
							Math.abs(res2.max_proj - res1.min_proj)
							);
				if (o < overlap) {
					overlap = o;
					smallest = normals_c2[i];
				}
			}
			
			if (collisionInfo != null) {
				
				collisionInfo.collider_src = this;
				collisionInfo.collider_target = collider;
				
				collisionInfo.mtv_src = smallest.mul(overlap);
				collisionInfo.mtv_target = smallest.mul(-overlap);
				
				collisionInfo.normal_src = collisionInfo.mtv_src.normalize();
				collisionInfo.normal_target = collisionInfo.mtv_target.normalize();
				
			}
			
			return true;
		} else if (Std.is(collider, CircleCollider)) {
			var c1:PolygonCollider = this;
			var c2:CircleCollider = cast collider;
			
			var c2_center = Point.fromPoint(c2.localToGlobal(c2.center.toGeom()));
			
			var closest_i = 0;
			var closest_dist = c1.getPoint(0).distanceSqr(c2_center);
			
			for (i in 1...c1.points.length) {
				var dist = c1.getPoint(i).distanceSqr(c2_center);
				if (dist < closest_dist) {
					closest_i = i;
					closest_dist = dist;
				}
			}
			
			var pt = c1.getPoint(closest_i);
			var axis = c2.center.sub(pt);
			
			var vecs = c1.prepareVectors();
			var normals = c1.getNormals(vecs);
			
			var overlap:Float = Math.POSITIVE_INFINITY;
			var smallest:Point = null;
			
			for (i in 0...normals.length) {
				
				var res1:MinMaxContainer = getMinMax(vecs, normals[i]);
				var cmin = c2_center.sub(new Point(c2.getInnerRadius())).dot(normals[i]);
				var cmax = c2_center.add(new Point(c2.getInnerRadius())).dot(normals[i]);
				if (cmin > cmax) {
					var t = cmin;
					cmin = cmax;
					cmax = t;
				}
				
				if (res1.max_proj < cmin || cmax < res1.min_proj)
					return false;
						
				var o = Math.min(
							Math.abs(res1.max_proj - cmin),
							Math.abs(cmax - res1.min_proj)
							);
				if (o < overlap) {
					overlap = o;
					smallest = normals[i];
				}
				
			}
			
			var res1:MinMaxContainer = getMinMax(vecs, axis);
			var cmin = c2_center.sub(new Point(c2.getInnerRadius())).dot(axis);
			var cmax = c2_center.add(new Point(c2.getInnerRadius())).dot(axis);
			if (cmin > cmax) {
				var t = cmin;
				cmin = cmax;
				cmax = t;
			}
			
			if (res1.max_proj < cmin || cmax < res1.min_proj)
				return false;
						
			var o = Math.min(
						Math.abs(res1.max_proj - cmin),
						Math.abs(cmax - res1.min_proj)
						);
			if (o < overlap) {
				overlap = o;
				smallest = axis;
			}
			
			
			if (collisionInfo != null) {
				
				collisionInfo.collider_src = this;
				collisionInfo.collider_target = collider;
				
				collisionInfo.mtv_src = smallest.mul(overlap);
				collisionInfo.mtv_target = smallest.mul( -overlap);
				
				collisionInfo.normal_src = collisionInfo.mtv_src.normalize();
				collisionInfo.normal_target = collisionInfo.mtv_target.normalize();
				
			}
			
			return true;
		}
		
		return false;
	}
	
	private function getNormals(vecs:Array<Point>):Array<Point> {
		
		var normals:Array<Point> = new Array<Point>();
		for (i in 0...vecs.length - 1) {
			var currentNormal:Point = new Point(
				vecs[i + 1].x - vecs[i].x,
				vecs[i + 1].y - vecs[i].y
			).perpendicular();
			normals.push(currentNormal);
		}
		normals.push(
			new Point(
				vecs[0].x - vecs[vecs.length - 1].x,
				vecs[0].y - vecs[vecs.length - 1].y
			).perpendicular()
		);
		
		return normals;
		
	}
	
	private function prepareVectors(?space:DisplayObject):Array<Point> {
		
		var vecs:Array<Point> = new Array<Point>();
		
		for (i in 0...points.length) {
			vecs.push(getPoint(i, space));
		}
		
		return vecs;
	}
	
	private function getMinMax(vecs:Array<Point>, axis:Point):MinMaxContainer {
		
		var min_proj:Float = vecs[0].dot(axis);
		var max_proj:Float = vecs[0].dot(axis);
		
		var min_index:Int = 0;
		var max_index:Int = 0;
		
		for (i in 1...vecs.length) {
			var curr_proj:Float = vecs[i].dot(axis);
			if (min_proj > curr_proj) {
				min_proj = curr_proj;
				min_index = i;
			}
			if (max_proj < curr_proj) {
				max_proj = curr_proj;
				max_index = i;
			}
		}
		
		return new MinMaxContainer(min_proj, max_proj, min_index, max_index);
	}
	
	public override function getInnerRadius() {
		return this.inner_radius;
	}
	
	
	
	public override function getBounds(targetSpace:DisplayObject, ?resultRect:Rectangle):Rectangle {
		
		var vecs:Array<Point> = prepareVectors(targetSpace);
		var t = vecs[0].y;
		var b = vecs[0].y;
		var l = vecs[0].x;
		var r = vecs[0].x;
		for (vec in vecs) {
			if (vec.y < t)
				t = vec.y;
			if (vec.y > b)
				b = vec.y;
			if (vec.x < l)
				l = vec.x;
			if (vec.x > r)
				r = vec.x;
		}
		var width = r - l;
		var height = b - t;
		
		if (resultRect == null)
			resultRect = new Rectangle();
		resultRect.x = l;
		resultRect.y = t;
		resultRect.width = width;
		resultRect.height = height;
		return resultRect;
	}
}

class MinMaxContainer {
	public var min_proj:Float;
	public var max_proj:Float;
	public var min_index:Int;
	public var max_index:Int;
	
	public function new(min_proj:Float, max_proj:Float, min_index:Int, max_index:Int) {
		this.min_proj = min_proj;
		this.max_proj = max_proj;
		this.min_index = min_index;
		this.max_index = max_index;
	}
}