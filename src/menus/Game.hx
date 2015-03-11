package menus;

import game.ai.Cannon;
import game.Board;
import game.Player;
import starling.core.Starling;
import starling.display.Image;
import starling.events.EnterFrameEvent;
import utility.ControlManager.ControlAction;

class Game extends MenuState {
	
	private var board:Board;
	
	private var debugMouse:Image;
	
	override function init() {
		
		rootSprite.addChild(this);
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
	
	function enterFrame(event:EnterFrameEvent) {
		//var mouse = Root.controls.getMousePos();
		//debugMouse.x = mouse.x;
		//debugMouse.y = mouse.y;
	}
	
	override function transitionIn(?callback:Void->Void) { callback(); }
	override function transitionOut(?callback:Void->Void) { callback(); }
}