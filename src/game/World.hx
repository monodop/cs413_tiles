package game;

import flash.geom.Rectangle;
import movable.*;
import menus.MenuState;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;

class World extends Sprite {
	/* The 'perfect' update time, used to modify velocities in case
	   the game is not quite running at $frameRate */
	static var perfectDeltaTime : Float = 1 / 60;
	
	private var menustate:MenuState;
	
	private var camera:Camera;
	
	private var debugMouse:Image;
	public var playerShip:Ship;
	public var pointImage:Image;
	private var cannon:Cannon;
	
	public function new (menustate:MenuState) {
		
		super();
		
		this.menustate = menustate;
		
		//camera = new Camera(new Rectangle( -1000, -1000, 1000, 1000));
		//this.addChild(camera);
		
		// {texture, maxSpeed, maxAngle}
		playerShip = new Ship(Root.assets.getTexture("test_ship"), 2, Math.PI/256);
		playerShip.setBreakPower(0.980);
		playerShip.setBoatAcceleration(0.005);
		playerShip.turnFix = false;
		
		playerShip.goTo(Starling.current.stage.stageWidth/2,Starling.current.stage.stageHeight/2);
		
		// Debug cannon
		cannon = new Cannon(Math.PI/2, Math.PI/4, 500);
		cannon.addChild(new Image(Root.assets.getTexture("point")));
		playerShip.addChild(cannon);
		cannon.x = playerShip.width/2;
		//cannon.y = playerShip.height/2;
		
		pointImage = new Image(Root.assets.getTexture("point"));
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
		
		var modifier = (event == null) ? 1.0 : event.passedTime / perfectDeltaTime;
		playerShip.applyVelocity(modifier);
		
		//camera.moveTowards(playerShip.x, playerShip.y);
		//camera.applyCamera(this);
	}
	
}