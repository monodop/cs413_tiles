package game;

import flash.geom.Rectangle;
import movable.*;
import menus.MenuState;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import flash.system.System;

class World extends Sprite {
	/* The 'perfect' update time, used to modify velocities in case
	   the game is not quite running at $frameRate */
	static var perfectDeltaTime : Float = 1 / 60;
	
	private var menustate:MenuState;
	
	private var camera:Camera;
	
	private var debugMouse:Image;
	public var playerShip:Ship;
	public var pointImage:Image;
	private var bulletList:List<Bullet> = new List<Bullet>();
	private var map:Tilemap;
	
	public function new (menustate:MenuState) {

		super();

		map = new Tilemap(Root.assets, "map");
		this.menustate = menustate;
		
		//camera = new Camera(new Rectangle( -1000, -1000, 1000, 1000));
		//this.addChild(camera);
		
		// {texture, maxSpeed, maxAngle}
		playerShip = new Ship(Root.assets.getTexture("test_ship"), 2, Math.PI/256);
		playerShip.setBreakPower(0.980);
		playerShip.setBoatAcceleration(0.005);
		playerShip.turnFix = false;
		playerShip.goTo(Starling.current.stage.stageWidth/2,Starling.current.stage.stageHeight/2);
		
		// Debug point texture, will be replaced eventually
		var pointTexture = Root.assets.getTexture("point");
		
		// Debug cannon(s)
		// Texture, Angle, Threshold, Distance, Cooldown
		var cannon = new Cannon(pointTexture, Math.PI/2, Math.PI/4, 250, 1000);
		cannon.addChild(new Image(pointTexture));
		playerShip.addCannon(cannon, playerShip.width/4 - pointTexture.width/2,  -pointTexture.height/2);
		
		cannon = new Cannon(pointTexture, Math.PI/2, Math.PI/4, 250, 1000);
		cannon.addChild(new Image(pointTexture));
		playerShip.addCannon(cannon, playerShip.width*3/4 - pointTexture.width/2,  -pointTexture.height/2);
		
		cannon = new Cannon(pointTexture, Math.PI, Math.PI/16, 1500, 1000);
		cannon.bulletSpeed = 15;
		cannon.addChild(new Image(pointTexture));
		playerShip.addCannon(cannon, playerShip.width - pointTexture.width/2, playerShip.height/2 - pointTexture.height/2);
		
		// Set up the point image which will display on mouse click
		pointImage = new Image(pointTexture);
		pointImage.width = pointImage.height = 5;
		pointImage.pivotX = pointImage.width/2.0;
		pointImage.pivotY = pointImage.height/2.0;
		pointImage.x = playerShip.getGoToX();
		pointImage.y = playerShip.getGoToY();
		
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
		
		//camera.moveTowards(playerShip.x, playerShip.y);
		//camera.applyCamera(this);
	}
	
}