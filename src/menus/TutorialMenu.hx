package menus;

import starling.animation.Tween;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import utility.ControlManager.ControlAction;

/**
 * ...
 * @author CS413
 */
class TutorialMenu extends MenuState
{
	private var mainMenu:MainMenu;
	
	private var img:Image;

	public function new(rootSprite:Sprite, mainMenu:MainMenu) 
	{
		super(rootSprite);
		
		this.mainMenu = mainMenu;
		
	}
	
	public override function init() {
		rootSprite.addChild(this);
		
		img = new Image(Root.assets.getTexture("gui/Tutorial Screen"));
		img.pivotX = img.width / 2;
		img.pivotY = img.height / 2;
		img.x = 256;
		img.y = 192;
		img.scaleX = 0;
		img.scaleY = 0;
		addChild(img);
		
	}
	
	override function awake() {
		Root.controls.hook("menu", "tutorialCloseMenu", closeMenu);
	}
	
	override function sleep() {
		Root.controls.unhook("menu", "tutorialCloseMenu");
	}
	
	function closeMenu(action:ControlAction) {
		if (action.isActive()) {
			this.stop();
		}
	}
	
	override function deinit() {
		mainMenu.creditTransitionIn(function() { mainMenu.start(); } );
		this.removeFromParent();
		this.dispose();
	}
	
	private override function transitionIn(?callback:Void->Void) {
		var t = new Tween(img, 1.0, "easeIn");
		t.animate("scaleX", 0.5);
		t.animate("scaleY", 0.5);
		t.onComplete = function() {
			callback();
		}
		Starling.juggler.add(t);
	}
	private override function transitionOut(?callback:Void->Void) {
		
		var tween = new Tween(img, 1.0, "easeInOut");
		tween.animate("alpha", 0);
		tween.onComplete = function() {
			callback();
		}
		Starling.juggler.add(tween);
	}
}