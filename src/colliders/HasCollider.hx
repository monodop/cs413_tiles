package colliders;

// An interface that can be applied to objects that have colliders.
// This is mainly used as a generic way to return a collider's parent.
// If your sprite or whatever has a collider, extend it with this
// interface.
interface HasCollider 
{
	public function getColliders():Array<Collider>;
	public function collision(self:Collider, object:Collider, collisionInfo:CollisionInformation):Bool;
	public function updateColliders():Void;
	public function setPos(x:Float, y:Float):Void;
}