package colliders;
import haxe.ds.StringMap;

// This class represents contains information about "physics layers".
// Use this class to create new physics layers, and then use the
// enableCollision or disableCollision methods to enable/disable collisions
// between different physics layers. This doesn't force anything, but you
// can use the canCollide method to check if two colliders can collide or not.
// All of these checks are two way. That is, if you add collisions between
// a "map" layer, and a "player" layer, then the map can collide with
// the player, and the player can collide with the map.
class CollisionMatrix
{
	
	private var layers:Array<String>;
	private var collisions:StringMap<Array<String>>;
	
	public function new() 
	{
		layers = new Array<String>();
		collisions = new StringMap<Array<String>>();
		registerLayer("default");
	}
	
	// Check if a layer has been registered
	public function layerExists(layer:String):Bool {
		return layers.indexOf(layer) >= 0;
	}
	
	private function collisionExists(layer1:String, layer2:String):Bool {
		if (!layerExists(layer1) || !layerExists(layer2))
			return false;
		return collisions.get(layer1).indexOf(layer2) >= 0;
	}
	
	// Register a new layer
	public function registerLayer(layer:String) {
		if (!layerExists(layer)) {
			layers.push(layer);
			collisions.set(layer, new Array<String>());
		}
	}
	
	// Enable the collision between two layers
	public function enableCollision(layer1:String, layer2:String) {
		if (layerExists(layer1) && layerExists(layer2)) {
			
			if (!collisionExists(layer1, layer2))
				collisions.get(layer1).push(layer2);
			if (!collisionExists(layer2, layer1))
				collisions.get(layer2).push(layer1);
			
		}
	}
	// Disable the collision between two layers
	public function disableCollision(layer1:String, layer2:String) {
		if (layerExists(layer1) && layerExists(layer2)) {
			
			collisions.get(layer1).remove(layer2);
			collisions.get(layer2).remove(layer1);
			
		}
	}
	
	// Enable the collision between a layer and a number of other layers
	public function enableCollisions(layer:String, ?otherLayers:Array<String>) {
		
		if (otherLayers != null) {
			for (l in otherLayers) {
				enableCollision(layer, l);
			}
		} else {
			for (l in layers) {
				enableCollision(layer, l);
			}
		}
		
	}
	
	// Disable the collision between a layer and a number of other layers
	public function disableCollisions(layer:String, ?otherLayers:Array<String>) {
		
		if (otherLayers != null) {
			for (l in otherLayers) {
				disableCollision(layer, l);
			}
		} else {
			for (l in layers) {
				disableCollision(layer, l);
			}
		}
		
	}
	
	// Check if two colliders can collide based on their assigned physics layers
	public function canCollide(c1:Collider, c2:Collider) {
		var l1 = c1.getLayers();
		var l2 = c2.getLayers();
		for (layer1 in l1) {
			for (layer2 in l2) {
				if (collisionExists(layer1, layer2) || collisionExists(layer2, layer1))
					return true;
			}
		}
		return false;
	}
	
}