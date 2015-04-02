package game;

import colliders.*;
import flash.geom.Rectangle;
import game.tilemap.Tilemap;
import menus.MenuState;
import menus.QuadTreeVis;
import movable.*;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import utility.ControlManager.ControlAction;
import utility.Point;

class World extends Sprite {
	/* The 'perfect' update time, used to modify velocities in case
	   the game is not quite running at $frameRate */
	static var perfectDeltaTime : Float = 1 / 60;
	
	private var menustate:MenuState;
	
	public var tileSize:Float = 24;
	private var tilemap:Tilemap;
	private var camera:Camera;
	
	private var debugMouse:Image;
	public var playerShip:Ship;
	public var pointImage:Image;
	private var bulletList:List<Bullet> = new List<Bullet>();
	
	private var quadvis:QuadTreeVis;
	
	public var quadTree:Quadtree;
	private var collisionMatrix:CollisionMatrix;
	
	public function new (menustate:MenuState) {
		
		super();
		
		this.menustate = menustate;
		
		this.scaleX = tileSize;
		this.scaleY = tileSize;
		
		camera = new Camera(new Rectangle( -0.5, -0.5, 100, 100));
		this.addChild(camera);
		
		quadTree = new Quadtree(this, new Rectangle( -0.5, -0.5, 100, 100));
		
		tilemap = new Tilemap(this, 100, 100);
		addChild(tilemap);
		
		// {texture, maxSpeed, maxAngle}
		playerShip = new Ship(Root.assets.getTexture("ships/pirate"), Root.assets.getTexture("ships/pirate_flag"), this, 2.0 / tileSize, Math.PI / 256);
		playerShip.setBreakPower(0.980);
		playerShip.setBoatAcceleration(0.005);
		playerShip.turnFix = false;
		playerShip.goTo(5,5);
		
		// Debug point texture, will be replaced eventually
		var cannonTexture = Root.assets.getTexture("ships/pirate_cannon_1");
		var bulletTexture = Root.assets.getTexture("cannonball");
		var pointTexture = Root.assets.getTexture("point");
		
		// Debug cannon(s)
		// Texture, Angle, Threshold, Distance, Cooldown
		var cannon = new Cannon(cannonTexture, bulletTexture, -Math.PI / 2, Math.PI / 4, 10, 1000);
		cannon.rotation = Math.PI;
		playerShip.addCannon(cannon, 47, 4);
		//var cannon = new Cannon(cannonTexture, bulletTexture, Math.PI / 2, Math.PI / 4, 10, 1000);
		//cannon.rotation = Math.PI;
		//playerShip.addCannon(cannon, 12, 4);
		
		cannon = new Cannon(cannonTexture, bulletTexture, Math.PI / 2, Math.PI / 4, 10, 1000);
		playerShip.addCannon(cannon, -17, 20);
		//cannon = new Cannon(cannonTexture, bulletTexture, -Math.PI / 2, Math.PI / 4, 10, 1000);
		//playerShip.addCannon(cannon, 14, 20);
		
		//cannon = new Cannon(cannonTexture, Math.PI, Math.PI/16, 40, 1000);
		//cannon.bulletSpeed = 15 / 24.0;
		//cannon.addChild(new Image(pointTexture));
		//playerShip.addCannon(cannon, (playerShip.width / playerShip.scaleX) - pointTexture.width/2, (playerShip.height / playerShip.scaleY) / 2 - pointTexture.height/2);
		
		// Set up the point image which will display on mouse click
		pointImage = new Image(pointTexture);
		pointImage.width = pointImage.height = 5;
		pointImage.pivotX = pointImage.width/2.0;
		pointImage.pivotY = pointImage.height/2.0;
		pointImage.x = playerShip.getGoToX();
		pointImage.y = playerShip.getGoToY();
		pointImage.scaleX = 1 / tileSize;
		pointImage.scaleY = 1 / tileSize;
		
		addChild(playerShip);
		addChild(pointImage);
		
		for (collider in playerShip.getColliders())
			this.quadTree.insert(collider);
	}
	
	public function update(event:EnterFrameEvent) {
		var mouse = Root.controls.getMousePos();

		if(Root.controls.isDown("break")){
			playerShip.stopMovement();
		}
		
		if(Root.controls.isDown("hold")){
			playerShip.holdSpeed();
		}
		
		var globalTime = flash.Lib.getTimer();
		var modifier = (event == null) ? 1.0 : event.passedTime / perfectDeltaTime;
		
		// Apply velocity to the player ship
		playerShip.applyVelocity(modifier);
		
		// Try to fire the playership's cannons at point x,y
		playerShip.tryFireCannons(globalTime, pointImage.x, pointImage.y, bulletList);
		
		// Loop through the bullet list and either despawn, or apply velocity to them
		for(bullet in bulletList){
			if(!bullet.shouldDespawn(globalTime)){
				bullet.applyVelocity(modifier);
			} else {
				bulletList.remove(bullet);
				bullet.removeFromParent(true);
			}
		}
		
		camera.moveTowards(playerShip.x, playerShip.y);
		camera.applyCamera(this);
		
		tilemap.update(event, camera);
	}
	
	public function awake() {
		Root.controls.hook("quadtreevis", "quadTreeVis", quadTreeVis);
	}
	public function sleep() {
		Root.controls.unhook("quadtreevis", "quadTreeVis");
	}
	
	// Pass a collider of something you want to test the collision of (the player's ship for example).
	// optionally pass in collisionInfo to retrieve an array of collisions that occured with some (admittedly not super reliable) data about them.
	// This function returns True if there was a collision and False if not.
	public function checkCollision(collider:Collider, ?collisionInfo:Array<CollisionInformation>):Bool {
		
		if (collisionInfo == null)
			collisionInfo = new Array<CollisionInformation>();
		
		var colliders = quadTree.retrieve(collider);
		var ci:CollisionInformation;
		for (c in colliders) {
			ci = new CollisionInformation();
			if (collider != c && collider.getOwner() != c.getOwner()
				&& collisionMatrix.canCollide(collider, c)) {
					if(collider.isClipping(c, ci)) {
						var collide = false;
						
						if(collider.getOwner().collision(collider, c, ci)) {
							collide = true;
							if (!c.getOwner().collision(c, collider, ci.reverse()))
								collide = false;
							ci.reverse();
							
						if(collide)
							collisionInfo.push(ci);
						}
					}
				}
		}
		
		return collisionInfo.length > 0;
	}
	
	// Pass a source vector as a Utils.Point, and a direction vector as the ray you want to check.
	// Pass a flash.geom.Rectangle object as the boundaries you want to check within (the camera's boundaries for example).
	// Pass an array of layers you want to collide with.
	// Optionally provide a threshold which can be used to prevent floating point rounding errors.
	// Finally, optionally provide an empty array of CollisionInformation objects and it will be filled with a list of collisions that occured (probably less reliable than checkCollision).
	// This function returns the closest contact point that occured, or null if none.
	public function rayCast(src:Point, dir:Point, bounds:Rectangle, layers:Array<String>, ?threshold:Float = 0.0, ?collisionInfo:Array<CollisionInformation>):Point {
		
		if (collisionInfo == null)
			collisionInfo = new Array<CollisionInformation>();
			
		var smaller_bounds = bounds.clone();
		if (dir.x > 0)
			smaller_bounds.x = src.x;
		if (dir.x < 0)
			smaller_bounds.right = src.x;
		if (dir.y > 0)
			smaller_bounds.y = src.y;
		if (dir.y < 0)
			smaller_bounds.bottom = src.y;
		
		var colliders = quadTree.retrieveAt(smaller_bounds);
		var closest_intersect = null;
		var closest_diff = Math.POSITIVE_INFINITY;
		var ci:CollisionInformation = null;
		for (c in colliders) {
			
			var canCollide = false;
			for (l in c.getLayers()) {
				for (layer in layers) {
					if (l == layer) {
						canCollide = true;
						break;
					}
				}
				if (canCollide)
					break;
			}
			if (!canCollide)
				continue;
			
			ci = new CollisionInformation();
			var intersect = c.rayCast(src, dir, this, threshold, ci);
			if (intersect != null && bounds.containsPoint(intersect.toGeom())) {
				
				if (closest_intersect == null) {
					closest_intersect = intersect;
					closest_diff = src.distanceSqr(intersect);
					collisionInfo.push(ci);
				} else {
					var diff = src.distanceSqr(intersect);
					if(diff < closest_diff) {
						closest_diff = diff;
						closest_intersect = intersect;
						while (collisionInfo.length > 0)
							collisionInfo.pop();
						collisionInfo.push(ci);
					} else if (diff == closest_diff)
						collisionInfo.push(ci);
				}
				
			}
		}
		
		return closest_intersect;
		
	}
	
	function quadTreeVis(action:ControlAction) {
		if (action.isActive()) {
			if(quadvis == null)
				quadvis = new QuadTreeVis(this, quadTree);
			
			var status = quadvis.getMenuStatus();
			if(status == EMenuStatus.SLEEPING || status == EMenuStatus.STOPPED)
				quadvis.start();
			else
				quadvis.pause();
		}
	}
	
}