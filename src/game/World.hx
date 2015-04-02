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