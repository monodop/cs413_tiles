package menus;

import starling.core.Starling;
import starling.display.Image;

import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.EnterFrameEvent;

import utility.ControlManager.ControlAction;
import movable.SimpleMovable;
import movable.Ship;

class Game extends MenuState {
	/* The 'perfect' update time, used to modify velocities in case
	   the game is not quite running at $frameRate */
	static var perfectDeltaTime : Float = 1/60;
	
	private var debugMouse:Image;
	private var playerShip:Ship;
	private var pointImage:Image;
	
	override function init() {
		rootSprite.addChild(this);
		
		// {texture, maxSpeed, maxAngle}
		playerShip = new Ship(Root.assets.getTexture("test_ship"), 4, Math.PI/124);
		playerShip.setBreakPower(0.980);
		playerShip.setBoatAcceleration(0.025);
		playerShip.turnFix = false;
		
		playerShip.goTo(this.stage.stageWidth/2,this.stage.stageHeight/2);
		
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
	
	public function onTouch( event:TouchEvent ){
		var touch:Touch = event.touches[0];
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
			playerShip.holdSpeed();
		}
		
		var modifier = (event == null) ? 1.0 : event.passedTime / perfectDeltaTime;
		playerShip.applyVelocity(modifier);
	}
	
	override function transitionIn(?callback:Void->Void) { callback(); }
	override function transitionOut(?callback:Void->Void) { callback(); }
}