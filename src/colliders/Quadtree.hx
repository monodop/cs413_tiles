package colliders;
import starling.display.Sprite;
import starling.display.DisplayObject;
import flash.geom.Rectangle;
import haxe.ds.Vector;
import starling.core.Starling;
import starling.display.Image;

// A spatial datastructure that can be used to locate colliders that can collide with another collider.
class Quadtree
{
	
	// The maximum number of objects in a quadTree level before subdividing it.
	private var max_objects:Int = 5;
	// The maximum number of levels the quadTree can have.
	private var max_levels:Int = 20;
	
	private var space:DisplayObject;
	private var level:Int;
	private var objects:Array<Collider>;
	private var bounds:Rectangle;
	private var nodes:Vector<Quadtree>;
	
	private var parent:Quadtree;
	
	private var numObjects:Int = 0;
	
	// Create a new quadtree.
	// pSpace is the target coordinate space for the quadtree. You might want to use the board or the game menu or something
	public function new(pSpace:DisplayObject, pBounds:Rectangle, ?pLevel:Int = 0, ?pParent:Quadtree) 
	{
		space = pSpace;
		level = pLevel;
		objects = new Array<Collider>();
		bounds = pBounds;
		nodes = new Vector<Quadtree>(4);
		parent = pParent;
	}
	
	// Clears out the quadtree. Do this if you want to remove everything and readd all of the objects.
	// It might be better to update the objects' positions though.
	public function clear() {
		objects = new Array<Collider>();
		for (i in 0...nodes.length) {
			if(nodes[i] != null)
				nodes[i].clear();
			nodes[i] = null;
		}
		numObjects = 0;
	}
	
	private function split() {
		var subWidth:Float = (bounds.width / 2.0);
		var subHeight:Float = (bounds.height / 2.0);
		var x:Float = (bounds.x);
		var y:Float = (bounds.y);
		
		nodes[0] = new Quadtree(space, new Rectangle(x + subWidth, y, subWidth, subHeight), level + 1, this);
		nodes[1] = new Quadtree(space, new Rectangle(x, y, subWidth, subHeight), level + 1, this);
		nodes[2] = new Quadtree(space, new Rectangle(x, y + subHeight, subWidth, subHeight), level + 1, this);
		nodes[3] = new Quadtree(space, new Rectangle(x + subWidth, y + subHeight, subWidth, subHeight), level + 1, this);
	}
	
	private function getIndex(pRect:Rectangle):Int {
		var index:Int = -1;
		var vertMidpoint:Float = bounds.x + (bounds.width / 2.0);
		var horMidpoint:Float = bounds.y + (bounds.height / 2.0);
		
		var topQuad:Bool = pRect.y < horMidpoint && pRect.y + pRect.height < horMidpoint;
		var bottomQuad:Bool = pRect.y > horMidpoint;
		
		if (pRect.x < vertMidpoint && pRect.x + pRect.width < vertMidpoint) {
			if (topQuad)
				index = 1;
			else if (bottomQuad)
				index = 2;
		}
		else if (pRect.x > vertMidpoint) {
			if (topQuad)
				index = 0;
			else if (bottomQuad)
				index = 3;
		}
		return index;
	}
	
	// Insert a new collider into the quadtree.
	// You don't need to provide a pRect, it's automatically calculated.
	public function insert(pObj:Collider, ?pRect:Rectangle) {
		
		if (pRect == null) {
			pRect = pObj.getBounds(space);
		}
		
		if (nodes[0] != null) {
			var index:Int = getIndex(pRect);
			if (index != -1) {
				nodes[index].insert(pObj, pRect);
				return;
			}
		}
		
		objects.push(pObj);
		pObj.quadTree = this;
		numObjects++;
		
		if (objects.length > max_objects && level < max_levels) {
			if (nodes[0] == null) {
				split();
			}
			var i:Int = 0;
			while (i < objects.length) {
				var rect = objects[i].getBounds(space);
				var index = getIndex(rect);
				if (index != -1) {
					var obj = objects[i];
					remove(obj, false);
					nodes[index].insert(obj);
				} else {
					i++;
				}
			}
		}
	}
	
	private function inBounds(pRect:Rectangle) {
		return pRect.x > bounds.x && pRect.x + pRect.width < bounds.x + bounds.width &&
			   pRect.y > bounds.y && pRect.y + pRect.height < bounds.y + bounds.height;
	}
	
	// Update the position of a collider in the quadtree.
	// You don't need to provide pRect, it's automatically calculated.
	public function update(pObj:Collider, ?pRect:Rectangle) {
		if (pRect == null) {
			pRect = pObj.getBounds(space);
		}
		
		if (parent == null || inBounds(pRect)) {
			var index:Int = getIndex(pRect);
			if (index != -1 && nodes[0] != null) {
				remove(pObj, false);
				nodes[index].insert(pObj, pRect);
			} else if (objects.indexOf(pObj) == -1) {
				objects.push(pObj);
				numObjects++;
				pObj.quadTree = this;
			}
		} else if (parent != null) {
			remove(pObj);
			parent.update(pObj, pRect);
		}
	}
	
	// Remove a collider from the quadtree. This doesn't search for the item in the current form.
	// If you need that, feel free to implement it.
	public function remove(pObj:Collider, ?trycombine:Bool = true) {
		if(this.objects.indexOf(pObj) >= 0) {
			numObjects--;
			this.objects.remove(pObj);
			if(trycombine)
				tryCombine();
		}
	}
	
	// Tries to combine this node's children into this node if there is enough space.
	// If tryparent is true, it will also try to combine this tile and it's siblings
	// into it's parent.
	public function tryCombine(?tryparent:Bool = true) {
		if (nodes[0] != null && getNumAllObjects() <= max_objects) {
			for (i in 0...nodes.length) {
				nodes[i].tryCombine(false);
				for (obj in nodes[i].objects) {
					this.objects.push(obj);
					numObjects++;
					obj.quadTree = this;
				}
				nodes[i] = null;
			}
			if(parent != null && tryparent)
				parent.tryCombine();
		} else if (getNumObjects() <= max_objects && tryparent && parent != null) {
			parent.tryCombine();
		}
	}
	
	// This retrieves all of the colliders that can collide with a collider.
	public function retrieve(pObj:Collider, ?returnObjects:Array<Collider>, ?pRect:Rectangle) {
		
		if (pRect == null) {
			pRect = pObj.getBounds(space);
		}
		if (returnObjects == null) {
			returnObjects = new Array<Collider>();
		}
		
		var index = getIndex(pRect);
		if (index != -1 && nodes[0] != null) {
			nodes[index].retrieve(pObj, returnObjects, pRect);
		} else if(nodes[0] != null) {
			for (i in 0...nodes.length) {
				if (nodes[i].bounds.left > pRect.right ||
					nodes[i].bounds.right < pRect.left ||
					nodes[i].bounds.top > pRect.bottom ||
					nodes[i].bounds.bottom < pRect.top)
					continue;
				nodes[i].retrieve(pObj, returnObjects, pRect);
			}
		}
		for (obj in objects) {
			if(obj.root != null) {
				var r = obj.getBounds(space);
				if (r.left > pRect.right ||
					r.right < pRect.left ||
					r.top > pRect.bottom ||
					r.bottom < pRect.top)
					continue;
				returnObjects.push(obj);
			}
		}
		
		return returnObjects;
		
	}
	// This retrieves all colliders within a specified rectangle.
	public function retrieveAt(pRect:Rectangle) { return retrieve(null, null, pRect); }
	
	// Returns the number of objects in a specific level of the quadtree.
	public function getNumObjects():Int {
		return numObjects;
	}
	
	// Returns the number of objects in this level of the quadtree and all of it's children.
	public function getNumAllObjects():Int {
		var cnt = getNumObjects();
		if (nodes[0] != null) {
			for (i in 0...nodes.length) {
				cnt += nodes[i].getNumAllObjects();
			}
		}
		return cnt;
	}
	
	// These functions are used to create a visualization of the quadtree.
	private function getVisImg(imgPool:Array<Image>, imgCount:Int):Image {
		var img:Image;
		if (imgCount >= imgPool.length) {
			img = new Image(Root.assets.getTexture('pixel'));
			img.smoothing = 'none';
			imgPool.push(img);
		} else {
			img = imgPool[imgCount];
		}
		img.color = 0xffffff;
		img.alpha = 1;
		return img;
	}
	
	// Provided a container sprite and an array of images of any size, this function will
	// generate a handy dandy visualization of the quadTree for debugging purposes.
	// The image pool can be of any size (and might as well be empty the first time).
	// This method will fill the pool with as many image objects as it needs, and then can recycle
	// these objects on the next frame to save initialization calls.
	public function getVisualization(container:Sprite, imgPool:Array<Image>, ?imgCount:Int = 0):Int {
		
		if (level == 0) {
			var img:Image = getVisImg(imgPool, imgCount++);
			
			img.color = 0xffffff;
			img.x = bounds.x;
			img.y = bounds.y;
			img.scaleX = bounds.width;
			img.scaleY = bounds.height;
			container.addChild(img);
		}
		
		if (nodes[0] != null) {
			for(i in 0...nodes.length) {
				var top:Image = getVisImg(imgPool, imgCount++);
				var left:Image = getVisImg(imgPool, imgCount++);
				
				var rect:Rectangle = nodes[i].bounds;
				
				top.color = 0x000000;
				top.x = rect.x;
				top.y = rect.y;
				top.scaleX = rect.width;
				top.scaleY = 1 / 48;
				container.addChild(top);
				
				left.color = 0x000000;
				left.x = rect.x;
				left.y = rect.y;
				left.scaleX = 1 / 48;
				left.scaleY = rect.height;
				container.addChild(left);
			}
			
			for (i in 0...nodes.length) {
				imgCount = nodes[i].getVisualization(container, imgPool, imgCount);
			}
			
		}
		
		for (c in objects) {
			var img:Image = getVisImg(imgPool, imgCount++);
			var ghost:Image = getVisImg(imgPool, imgCount++);
			
			switch(level % 6) {
				case 0: img.color = 0xff0000;
				case 1: img.color = 0x00ff00;
				case 2: img.color = 0x0000ff;
				case 3: img.color = 0xff00ff;
				case 4: img.color = 0x00ffff;
				case 5: img.color = 0xffff00;
			}
			var rect:Rectangle = c.getBounds(space);
			img.x = rect.x + rect.width / 4;
			img.y = rect.y + rect.height / 4;
			img.scaleX = rect.width / 2;
			img.scaleY = rect.height / 2;
			container.addChild(img);
			
			ghost.color = img.color;
			ghost.x = rect.x;
			ghost.y = rect.y;
			ghost.scaleX = rect.width;
			ghost.scaleY = rect.height;
			ghost.alpha = 0.1;
			container.addChild(ghost);
		}
		
		
		return imgCount;
	}
	
}