package game;

import colliders.*;
import flash.geom.Rectangle;
import game.tilemap.Tilemap;
import menus.GameOverMenu;
import menus.MenuState;
import menus.QuadTreeVis;
import menus.UpgradeMenu;
import movable.*;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.text.BitmapFont;
import utility.ControlManager.ControlAction;
import utility.Point;
import utility.HealthBar;
import starling.events.Event;
import starling.text.TextField;

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
	private var a_Ship:List<Ship> = new List<Ship>();
	
	public var pointImage:Image;
	private var bulletList:List<Bullet> = new List<Bullet>();
	
	private var quadvis:QuadTreeVis;
	
	public var quadTree:Quadtree;
	private var collisionMatrix:CollisionMatrix;
	
	private var pointText:TextField;
	private var healthBar:HealthBar;
	private var energyBar:HealthBar;
	
	public var pointCounter:Int = 0;
	
	private var directionTriangles:Array<Image>;
	
	public function new (menustate:MenuState) {
		super();
		
		// Rescale the world and initiate the menu state
		this.menustate = menustate;
		this.scaleX = tileSize;
		this.scaleY = tileSize;
		
		// Setup the camera tracking class
		camera = new Camera(new Rectangle( -0.5, -0.5, 100, 100));
		this.addChild(camera);
		
		// Prepare the quadtree
		quadTree = new Quadtree(this, new Rectangle( -0.5, -0.5, 100, 100));
		
		// Prepare the collision matrix
		collisionMatrix = new CollisionMatrix();
		collisionMatrix.registerLayer("map");
		collisionMatrix.registerLayer("ship");
		collisionMatrix.registerLayer("projectile");
		collisionMatrix.enableCollisions("map", ["ship", "projectile"]);
		collisionMatrix.enableCollisions("ship", ["projectile"]);
		
		// Prepare the tilemap
		tilemap = new Tilemap(this, 100, 100);
		addChild(tilemap);
		
		// Populate the shipbuilder's static resources
		ShipBuilder.populateResources();
		
		directionTriangles = new Array<Image>();
				
		// Create an enemy ship
		var ship = ShipBuilder.getLargeEnglishShip(this, 31);
		ship.setPath([new Point(15,15), new Point(40,15), new Point(40,40), new Point(15,40)]);
		a_Ship.push(ship);
		
		// Create an enemy ship
		ship = ShipBuilder.getCourrierShip(this, 3);
		ship.setPath([new Point(27,31), new Point(10,15), new Point(25,25), new Point(50,50)]);
		a_Ship.push(ship);
		
		// Create the player ship
		playerShip = ShipBuilder.getPirateShip(this, 3);
		playerShip.turnFix = false;
		playerShip.goTo(5,5);
		
		// Set up the point image which will display on mouse click
		pointImage = new Image(Root.assets.getTexture("gui/crosshair"));
		pointImage.smoothing = 'none';
		pointImage.alpha = 0.50;
		pointImage.width = pointImage.height = 5;
		pointImage.pivotX = pointImage.width/2.0;
		pointImage.pivotY = pointImage.height/2.0;
		pointImage.x = playerShip.getGoToX();
		pointImage.y = playerShip.getGoToY();
		pointImage.scaleX = 1 / tileSize;
		pointImage.scaleY = 1 / tileSize;
		
		/* Add display objects to the world */
		addMovable(playerShip);
		addChild(pointImage);
		for(ship in a_Ship)
			addMovable(ship);
			
		this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
	}
	
	public function addedToStage(){
		// Create a health bar
		healthBar = new HealthBar(600,10,Root.assets.getTexture("greenpixel"));
		healthBar.y = 20;
		healthBar.x = this.stage.stageWidth/2 - healthBar.width/2;
		menustate.addChild(healthBar);
		
		// Create a point counter
		pointText = new TextField(200,50,"Score: 0", BitmapFont.MINI);
		pointText.y = 10;
		pointText.x = this.stage.stageWidth - pointText.width - 30;
		pointText.color = 0xFFFFFF;
		pointText.fontSize = 18;
		pointText.hAlign = "right";
		menustate.addChild(pointText);
	}
	
	public function addMovable(obj:SimpleMovable) {
		addChild(obj);
		for (collider in obj.getColliders()) {
			this.quadTree.insert(collider);
		}
	}
	public function removeMovable(obj:SimpleMovable) {
		for (collider in obj.getColliders()) {
			collider.quadTree.remove(collider, true);
		}
		removeChild(obj);
	}
	
	public function destroyShip(ship:Ship){
		if(ship == playerShip){
			trace('player dead');
		} else {
			a_Ship.remove(ship);
			removeMovable(ship);
			
			if(ship.deathAnimationStr != null){
				var explosion:Explosion = new Explosion(ship.deathAnimationStr, 8);
					explosion.x = ship.x;
					explosion.y = ship.y;
					explosion.rotation = ship.rotation;
				this.addChild(explosion);
				pointCounter += ship.worthPoints;
				pointText.text = "Score: " + pointCounter;
			}
		}
	}
	
	public function update(event:EnterFrameEvent) {
		var mouse = Root.controls.getMousePos();

		// Control the ship's break
		if(Root.controls.isDown("break")){
			playerShip.stopMovement();
		}
		
		// Hold the ship's current speed
		if(Root.controls.isDown("hold")){
			playerShip.holdSpeed();
		}
		
		// Time variables used for constant movement + timing events
		var globalTime = flash.Lib.getTimer();
		var modifier = (event == null) ? 1.0 : event.passedTime / perfectDeltaTime;
		
		// Attack the closest in range ship
		playerShip.tryPredictiveFireAtShips(globalTime, a_Ship, bulletList, 1.0);
		
		if(healthBar.getBarSpan() > playerShip.getHealthRatio()){
			healthBar.flashColor(0x00FF00, 30);
		}
		
		healthBar.setBarSpan(playerShip.getHealthRatio());
		playerShip.healShip(0.005);
		// Update ship velocities
		playerShip.applyVelocity(modifier);
		for(ship in a_Ship){
			ship.applyVelocity(modifier);
			ship.tryPredictiveFire(globalTime, playerShip, bulletList, 1.5);
		}
		
		// Loop through the bullet list and either despawn, or apply velocity to them
		for (bullet in bulletList) {
			
			var ci = new Array<CollisionInformation>();
			var colliders = bullet.getColliders();
			var collide = checkCollision(colliders[0], ci);
			
			if(!collide && !bullet.shouldDespawn(globalTime)){
				bullet.applyVelocity(modifier);
			} else if(bullet.shouldDespawn(globalTime)) {
				bulletList.remove(bullet);
				removeMovable(bullet);
			}
		}
		
		for (img in directionTriangles) {
			img.removeFromParent();
		}
		while(directionTriangles.length < a_Ship.length) {
			var img = new Image(Root.assets.getTexture("gui/arrow"));
			img.smoothing = 'none';
			img.pivotX = img.width / 2;
			img.pivotY = img.height / 2;
			directionTriangles.push(img);
		}
		
		// Update the camera object
		camera.moveTowards(playerShip.x, playerShip.y);
		camera.applyCamera(this);
		
		var camBounds = camera.getCameraBounds(this, -4);
		var player_pos = new Point(playerShip.x, playerShip.y);
		var dir:Point;
		var hitPt:Point;
		var i = 0;
		for (ship in a_Ship) {
			if (ship.x > camBounds.right || ship.x < camBounds.left ||
				ship.y > camBounds.bottom || ship.y < camBounds.top) {
					dir = new Point(ship.x, ship.y).sub(player_pos);
					hitPt = PolygonCollider.rectangleIntersection(camBounds, player_pos, dir);
					if(hitPt != null) {
						hitPt = Point.fromPoint(getTransformationMatrix(menustate).transformPoint(hitPt.toGeom()));
						directionTriangles[i].x = hitPt.x;
						directionTriangles[i].y = hitPt.y;
						directionTriangles[i].rotation = dir.angle();
						menustate.addChild(directionTriangles[i++]);
					}
				}
		}
		
		// Update the tilemap
		tilemap.update(event, camera);
	}
	
	
	
	public function awake() {
		Root.controls.hook("quadtreevis", "quadTreeVis", quadTreeVis);
		Root.controls.hook("menu", "openMenu", openMenu);
		Root.controls.hook("retire", "retire", retire);
		Starling.current.stage.addEventListener(TouchEvent.TOUCH, onTouch);
	}
	public function sleep() {
		Root.controls.unhook("quadtreevis", "quadTreeVis");
		Root.controls.unhook("menu", "openMenu");
		Root.controls.unhook("retire", "retire");
		Starling.current.stage.removeEventListener(TouchEvent.TOUCH, onTouch);
	}
	
	function openMenu(action:ControlAction) {
		
		if(action.isActive()) {
			var menu = new UpgradeMenu(menustate.rootSprite, this);
			menu.start();
			
			menustate.pause();
		}
		
	}
	
	function retire(action:ControlAction) {
		
		if (action.isActive()) {
			gameOver();
		}
		
	}
	
	public function gameOver() {
		
		var menu = new GameOverMenu(menustate.rootSprite, this, menustate);
		menu.start();
		
		menustate.pause();
		
	}
	
	var lastTouch:Touch;
	public function onTouch( event:TouchEvent ) {
		
		var touch:Touch = event.touches[0];
		lastTouch = touch;
		if (touch.phase == "ended") {
			var dest = touch.getLocation(this);
			playerShip.goTo(dest.x,dest.y);
			pointImage.x = dest.x;
			pointImage.y = dest.y;
		}
			
	}
	
	public function closeMenu() {
		
		menustate.start();
		
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