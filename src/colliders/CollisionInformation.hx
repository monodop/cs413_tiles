package colliders;
import utility.Point;

// An object that gets filled with information when used with a collider's isClipping or rayCast method.
class CollisionInformation {
	
	public var mtv_src:Point;
	public var mtv_target:Point;
	
	public var pos_src:Point;
	public var pos_target:Point;
	
	public var normal_src:Point;
	public var normal_target:Point;
	
	public var collider_src:Collider;
	public var collider_target:Collider;
	
	public var depth:Float;
	
	public function new() { }
	
	public function reverse():CollisionInformation {
		
		var mtvs = mtv_src;
		var ps = pos_src;
		var ns = normal_src;
		var cs = collider_src;
		
		mtv_src = mtv_target;
		mtv_target = mtvs;
		
		pos_src = pos_target;
		pos_target = ps;
		
		normal_src = normal_target;
		normal_target = ns;
		
		collider_src = collider_target;
		collider_target = cs;
		
		return this;
	}
}