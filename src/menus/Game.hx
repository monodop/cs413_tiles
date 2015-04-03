package menus;

import starling.core.Starling;
import starling.display.Image;

import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.EnterFrameEvent;

import flash.media.SoundTransform;
import flash.media.Sound;

import game.World;
import utility.ControlManager.ControlAction;
import movable.*;

class Game extends MenuState {
	
	private var world:World;
	
	override function init() {
		playWater(null);
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
	
	public function playWater(e:flash.events.Event){
		var musicChannel = Root.assets.playSound("ocean");
		musicChannel.addEventListener(flash.events.Event.SOUND_COMPLETE, playWater);
		musicChannel.soundTransform = new SoundTransform(0.01, 0.01);
	}
	
	override function transitionIn(?callback:Void->Void) { callback(); }
	override function transitionOut(?callback:Void->Void) { callback(); }
}