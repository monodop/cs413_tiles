package menus;

import starling.core.Starling;
import starling.display.Image;

import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.EnterFrameEvent;

import game.World;
import utility.ControlManager.ControlAction;
import movable.SimpleMovable;
import movable.Ship;

class Game extends MenuState {
	
	private var world:World;
	
	override function init() {
		rootSprite.addChild(this);
		
		world = new World(this);
		addChild(world);
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
			world.playerShip.goTo(touch.globalX,touch.globalY);
			world.pointImage.x = touch.globalX;
			world.pointImage.y = touch.globalY;
		}
	}
	
	function enterFrame(event:EnterFrameEvent) {
		world.update(event);
	}
	
	override function transitionIn(?callback:Void->Void) { callback(); }
	override function transitionOut(?callback:Void->Void) { callback(); }
}