package game;

import colliders.*;
import flash.geom.Rectangle;
import game.tilemap.Tilemap;
import menus.MenuState;
import movable.*;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;

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
	
	private var quadTree:Quadtree;
	private var collisionMatrix:CollisionMatrix;
	
	public function new (menustate:MenuState) {
		
		super();
		
		this.menustate = menustate;
		
		this.scaleX = tileSize;
		this.scaleY = tileSize;
		
		camera = new Camera(new Rectangle( -0.5, -0.5, 100, 100));
		this.addChild(camera);
		
		quadTree = new Quadtree(this, new Rectangle( -100, -100, 200, 200));
		
		tilemap = new Tilemap(this, 100, 100);
		addChild(tilemap);
		
		// {texture, maxSpeed, maxAngle}
		playerShip = new Ship(Root.assets.getTexture("ships/pirate"), Root.assets.getTexture("ships/pirate_flag"), this, 2.0 / tileSize, Math.PI / 256);
		playerShip.setBreakPower(0.980);
		playerShip.setBoatAcceleration(0.005);
		playerShip.turnFix = false;
		playerShip.goTo(5,5);
		
		// Debug point texture, will be replaced eventually
		var pointTexture = Root.assets.getTexture("point");
		
		// Debug cannon(s)
		// Texture, Angle, Threshold, Distance, Cooldown
		var cannon = new Cannon(pointTexture, this, Math.PI/2, Math.PI/4, 250, 1000);
		cannon.addChild(new Image(pointTexture));
		playerShip.addCannon(cannon, (playerShip.width / playerShip.scaleX) / 4 - pointTexture.width/2,  -pointTexture.height/2);
		
		cannon = new Cannon(pointTexture, this, Math.PI/2, Math.PI/4, 250, 1000);
		cannon.addChild(new Image(pointTexture));
		playerShip.addCannon(cannon, (playerShip.width / playerShip.scaleX ) * 3 / 4 - pointTexture.width/2,  -pointTexture.height/2);
		
		cannon = new Cannon(pointTexture, this, Math.PI, Math.PI/16, 1500, 1000);
		cannon.bulletSpeed = 15 / 24.0;
		cannon.addChild(new Image(pointTexture));
		playerShip.addCannon(cannon, (playerShip.width / playerShip.scaleX) - pointTexture.width/2, (playerShip.height / playerShip.scaleY) / 2 - pointTexture.height/2);
		
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
	
}