package menus;

import starling.core.Starling;
import starling.display.Image;

import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.EnterFrameEvent;

import flash.media.Sound;

import game.World;
import utility.ControlManager.ControlAction;
import movable.*;

class Game extends MenuState {
	
	private var world:World;
	
	override function init() {
		rootSprite.addChild(this);
		
		var centerX = Starling.current.stage.stageWidth / 2.0;
		var centerY = Starling.current.stage.stageHeight / 2.0;
		
		world = new World(this);
		addChild(world);
		
		world.x = centerX;
		world.y = centerY;
	}	
	
	
	override function awake() {
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrame);
		world.awake();
	}
	
	override function sleep() {
		this.removeEventListener(EnterFrameEvent.ENTER_FRAME, enterFrame);
		world.sleep();
	}
	
	override function deinit() {
		this.removeFromParent();
		this.dispose();
	}
	
	function enterFrame(event:EnterFrameEvent) {
		world.update(event);
	}
	
	override function transitionIn(?callback:Void->Void) { callback(); }
	override function transitionOut(?callback:Void->Void) { callback(); }
}