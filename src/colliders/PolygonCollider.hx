package colliders;
import flash.geom.Rectangle;
import game.World;
import haxe.ds.Vector;
import starling.display.DisplayObject;
import starling.display.Image;
import utility.Point;
import utility.Utils;

// A collider that is defined by a series of points.
// I don't know if it makes much of a difference, but I recommend
// defining the points in clockwise order.
class PolygonCollider extends Collider
{
	
	private var points:Array<Point>;
	
	private var debugCircle:Image;
	private var debugPoints:Array<Image>;
	
	private var showDebug:Bool = false;
	
	private var pointCache:Vector<Point>;
	private var pointSpace:Vector<DisplayObject>;

	public function new(owner:HasCollider, layers:Array<String>, points:Array<Point>) 
	{
		super(owner, layers);
		
		this.points = points;
		pointCache = new Vector<Point>(points.length);
		pointSpace = new Vector<DisplayObject>(points.length);
		
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
		this.radius = this.inner_radius;// * 1.5;
		
		//debugCircle = new Image(Root.assets.getTexture("debugCircle"));
		//debugCircle.pivotX = 8.0;
		//debugCircle.pivotY = 8.0;
		//debugCircle.x = center.x;
		//debugCircle.y = center.y;
		//debugCircle.scaleX = this.radius / 8.0;
		//debugCircle.scaleY = this.radius / 8.0;
		//debugCircle.color = 0xff0000;
		//debugCircle.smoothing = 'none';
		//debugCircle.alpha = 0.2;
		//debugCircle.visible = false;
		//this.addChild(debugCircle);
		
		debugPoints = new Array<Image>();
		for (point in points) {
			var pt = new Image(Root.assets.getTexture("pixel"));
			pt.pivotX = 0.5;
			pt.pivotY = 0.5;
			pt.x = point.x;
			pt.y = point.y;
			pt.color = 0x0000ff;
			pt.visible = false;
			debugPoints.push(pt);
			this.addChild(pt);
		}
		
	}
	
	public override function toggleDebug() {
		
		showDebug = !showDebug;
		
		debugCircle.visible = showDebug;
		for (point in debugPoints) {
			point.visible = showDebug;
		}
		
	}
	
	// Get a point in the collider in a specific coordinate space
	public function getPoint(index:Int, ?space:DisplayObject):Point {
		
		if (pointCache[index] != null && pointSpace[index] == space) {
			return pointCache[index];
		}
		
		if (space == null) {
			pointCache[index] = Point.fromPoint(localToGlobal(points[index].toGeom()));
			pointSpace[index] = space;
		} else {
			pointCache[index] = Point.fromPoint(getTransformationMatrix(space).transformPoint(points[index].toGeom()));
			pointSpace[index] = space;
		}
		return pointCache[index];
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
	
	public override function rayCast(src:Point, dir:Point, ?space:DisplayObject, ?threshold:Float = 0.0, ?collisionInfo:CollisionInformation):Point {
		
		var points = prepareVectors(space);
		
		var closest_intersect = null;
		var closest_diff = Math.POSITIVE_INFINITY;
		
		var p = points[points.length-1];
		var r = points[0].sub(points[points.length - 1]);
		var intersect:Point = new Point();
		var diff = lineIntersection(p, r, src, dir, intersect, threshold);
		if(Math.isFinite(diff)) {
			closest_diff = diff;
			closest_intersect = intersect;
		}
		
		for (i in 1...points.length) {
			p = points[i - 1];
			r = points[i].sub(points[i - 1]);
			intersect = new Point();
			diff = lineIntersection(p, r, src, dir, intersect, threshold);
			if(Math.isFinite(diff)) {
				
				if (closest_intersect == null || diff < closest_diff) {
					closest_intersect = intersect;
					closest_diff = diff;
				}
				
			}
		}
		
		if (collisionInfo != null) {
			
			collisionInfo.collider_src = this;
			collisionInfo.collider_target = null;
			
		}
		
		return closest_intersect;
	}
	private static function lineIntersection(p:Point, r:Point, q:Point, s:Point, outPoint:Point, ?threshold:Float = 0.0):Float {
		
		var rxs:Float = r.cross(s);
		var qminp:Point = q.sub(p);
		
		var t = qminp.cross(s) / rxs;
		var u = qminp.cross(r) / rxs;
		
		if (rxs != 0 && Utils.between(0-threshold, t, 1+threshold) && Utils.between(0-threshold, u, 1+threshold)) {
			var res = p.add(r.mul(t));
			outPoint.x = res.x;
			outPoint.y = res.y;
			return u;
		}
		
		return Math.POSITIVE_INFINITY;
		
	}
	
	public static function rectangleIntersection(rect:Rectangle, src:Point, dir:Point, ?threshold:Float = 0.0):Point {
		
		var closest_intersect = null;
		var closest_diff = Math.POSITIVE_INFINITY;
		
		var dest = src.add(dir);
		var segChk = new Array<{p:Point, r:Point}>();
		
		if (Utils.between(src.x, rect.right, dest.x)) {
			segChk.push( { p:new Point(rect.right, rect.top), r:new Point(rect.right, rect.bottom) } );
		}
		if (Utils.between(src.x, rect.left, dest.x)) {
			segChk.push( { p:new Point(rect.left, rect.top), r:new Point(rect.left, rect.bottom) } );
		}
		
		if (Utils.between(src.y, rect.top, dest.y)) {
			segChk.push( { p:new Point(rect.left, rect.top), r:new Point(rect.right, rect.top) } );
		}		if (Utils.between(src.y, rect.bottom, dest.y)) {
			segChk.push( { p:new Point(rect.left, rect.bottom), r:new Point(rect.right, rect.bottom) } );
		}
		
		var intersect:Point = new Point();
		var diff:Float;
		for (seg in segChk) {
			
			intersect = new Point();
			diff = lineIntersection(seg.p, seg.r.sub(seg.p), src, dir, intersect, threshold);
			if(Math.isFinite(diff)) {
				
				if (closest_intersect == null || diff < closest_diff) {
					closest_intersect = intersect;
					closest_diff = diff;
				}
				
			}
		}
		
		return closest_intersect;
		
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
	
	public override function getNumEdges():Int {
		return this.points.length;
	}
	
	public override function updateQuadtree() {
		if (this.quadTree != null) {
			boundsCache = null;
			boundsSpace = null;
			for (i in 0...points.length) {
				pointCache[i] = null;
				pointSpace[i] = null;
			}
			this.quadTree.update(this);
		}
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