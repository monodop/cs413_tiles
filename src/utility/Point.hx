package utility;
import starling.display.DisplayObject;

class Point
{

	public var x:Float;
	public var y:Float;
	
	public function new(?x:Float, ?y:Float) 
	{
		this.x = 0;
		this.y = 0;
		
		if (x != null)
			this.x = x;
		
		if (y != null)
			this.y = y;
		else if (x != null)
			this.y = x;
	}
	
	public static function fromPoint(point:flash.geom.Point): Point {
		return new Point(point.x, point.y);
	}
	public static function fromPolar(l:Float, a:Float): Point {
		return new Point(l * Math.cos(a), l * Math.sin(a));
	}
	public static function fromDispObj(o:DisplayObject): Point {
		return new Point(o.x, o.y);
	}
	
	public function toString() {
		return "(" + (Math.round(x * 100) / 100) + ", " + (Math.round(y * 100) / 100) + ")";
	}
	public function toGeom(): flash.geom.Point {
		return new flash.geom.Point(this.x, this.y);
	}
	
	public function clone():Point {
		return new Point(this.x, this.y);
	}
	
	public function lengthSqr():Float {
		return this.x * this.x + this.y * this.y;
	}
	
	public function length(): Float {
		return Math.sqrt(this.lengthSqr());
	}
	
	public function angle(): Float {
		return Math.atan2(this.y, this.x);
	}
	
	public function angleBetween(p2:Point): Float {
		var dx = p2.x - this.x;
		var dy = p2.y - this.y;
		return Math.atan2(dy, dx);
	}
	
	public function distanceSqr(p2:Point): Float {
		var x = this.x - p2.x;
		var y = this.y - p2.y;
		return x * x + y * y;
	}
	
	public function distance(p2:Point): Float {
		return Math.sqrt(this.distanceSqr(p2));
	}
	
	public function dot(p2:Point): Float {
		return this.x * p2.x + this.y * p2.y;
	}
	
	public function cross(p2:Point): Float {
		return this.x * p2.y - this.y * p2.x;
	}
	
	public function equals(p2:Point): Bool {
		return this.x == p2.x && this.y == p2.y;
	}
	
	public function nearEquals(p2:Point, ?t:Float = 0.0): Bool {
		var x = Math.abs(this.x - p2.x);
		var y = Math.abs(this.y - p2.y);
		return x <= t && y <= t;
	}
	
	public function gt(p2:Point): Bool {
		return this.x > p2.x && this.y > p2.y;
	}
	public function gte(p2:Point): Bool {
		return this.x >= p2.x && this.y >= p2.y;
	}
	public function lt(p2:Point): Bool {
		return this.x < p2.x && this.y < p2.y;
	}
	public function lte(p2:Point): Bool {
		return this.x <= p2.x && this.y <= p2.y;
	}
	
	public function add(rhs:Point): Point {
		return new Point(this.x + rhs.x, this.y + rhs.y);
	}
	public function sub(rhs:Point): Point {
		return new Point(this.x - rhs.x, this.y - rhs.y);
	}
	public function mul(rhs:Float): Point {
		return new Point(this.x * rhs, this.y * rhs);
	}
	public function div(rhs:Float): Point {
		return new Point(this.x / rhs, this.y / rhs);
	}
	
	public function abs(): Point {
		return new Point(Math.abs(this.x), Math.abs(this.y));
	}
	
	public function opposite(): Point {
		return new Point(-this.x, -this.y);
	}
	
	public function perpendicular(): Point {
		return new Point(-this.y, this.x);
	}
	
	public function perpInverse(): Point {
		return new Point(this.y, -this.x);
	}
	
	public function normalize(?t:Float = 1.0): Point {
		var m = t / this.length();
		return new Point(this.x * m, this.y * m);
	}
	
	public function interpolate(p2:Point, f:Float): Point {
		return new Point( (p2.x - this.x) * f + this.x, (p2.y - this.y) * f + this.y);
	}
	
	public function pivot(p2:Point, a:Float): Point {
		var x = this.x - p2.x;
		var y = this.y - p2.y;
		
		var s = Math.sin(a);
		var c = Math.cos(a);
		
		var xnew = x * c - y * s;
		var ynew = x * s + y * c;
		
		xnew += p2.x;
		ynew += p2.y;
		
		return new Point(xnew, ynew);
	}
	
	public function project(p2:Point): Point {
		
		var adb = this.dot(p2);
		var bdb = p2.dot(p2);
		var x = adb * bdb;
		var res = p2.mul(x);
		
		return p2.mul(this.dot(p2) / p2.dot(p2));
	}
	
	public function scalarProject(p2:Point): Float {
		return this.dot(p2) / p2.length();
	}
}