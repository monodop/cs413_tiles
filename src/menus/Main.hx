package menus;

import flash.ui.Keyboard;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.KeyboardEvent;

class Main extends MenuState {
	
	private var transitionSpeed = 0.5;
	private var tween:Tween;
	private var selection:Int;
	
	override function init() {		
		rootSprite.addChild(this);
	}
	
	override function deinit() {
		removeFromParent();
	}
	
	override function awake() { }
	
	override function sleep() { }

	private override function transitionOut(?callBack:Void->Void) {

		var t = new Tween(this, transitionSpeed, Transitions.EASE_IN_OUT);
		t.animate("x", 1000);
		t.onComplete = callBack;
		Starling.juggler.add(t);

	}
	
	private override function transitionIn(?callBack:Void->Void) {
		
		var t = new Tween(this, transitionSpeed, Transitions.EASE_IN_OUT);
		t.animate("scaleX", 1);
		t.animate("scaleY", 1);
		/*
		t.animate("bgcolor", 0);
		t.onUpdate = function() {
			Starling.current.stage.color = this.bgcolor | this.bgcolor << 8 | this.bgcolor << 16;
		};*/
		t.onComplete = callBack;
		Starling.juggler.add(t);
	}
	
}
