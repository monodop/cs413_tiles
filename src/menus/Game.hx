package menus;

import starling.core.Starling;
import starling.display.Image;

import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.EnterFrameEvent;

import utility.ControlManager.ControlAction;
import movable.*;

class Game extends MenuState {
	/* The 'perfect' update time, used to modify velocities in case
	   the game is not quite running at $frameRate */
	static var perfectDeltaTime : Float = 1/60;
	
	private var debugMouse:Image;
	private var playerShip:Ship;
	private var pointImage:Image;
	private var cannon:Cannon;
	override function init() {
		rootSprite.addChild(this);
		
		// {texture, maxSpeed, maxAngle}
		playerShip = new Ship(Root.assets.getTexture("test_ship"), 2, Math.PI/256);
		playerShip.setBreakPower(0.980);
		playerShip.setBoatAcceleration(0.005);
		playerShip.turnFix = false;
		
		playerShip.goTo(this.stage.stageWidth/2,this.stage.stageHeight/2);
		
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
	
	override function awake() {
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrame);
	}
	
	override function sleep() {
		this.removeEventListener(EnterFrameEvent.ENTER_FRAME, enterFrame);
	}
	
	override function deinit() {
		this.removeFromParent();
		this.dispose();
	}
	
	var lastTouch:Touch;
	public function onTouch( event:TouchEvent ){
		var touch:Touch = event.touches[0];
		lastTouch = touch;
		if(touch.phase == "ended"){
			playerShip.goTo(touch.globalX,touch.globalY);
			pointImage.x = touch.globalX;
			pointImage.y = touch.globalY;
		}
	}
	
	function enterFrame(event:EnterFrameEvent) {
		var mouse = Root.controls.getMousePos();

		if(Root.controls.isDown("break")){
			playerShip.stopMovement();
		}
		
		if(Root.controls.isDown("hold")){
			cannon.fireAtPoint(pointImage.x, pointImage.y);
			//playerShip.holdSpeed();
		}
		
		var modifier = (event == null) ? 1.0 : event.passedTime / perfectDeltaTime;
		playerShip.applyVelocity(modifier);
	}
	
	override function transitionIn(?callback:Void->Void) { callback(); }
	override function transitionOut(?callback:Void->Void) { callback(); }
}