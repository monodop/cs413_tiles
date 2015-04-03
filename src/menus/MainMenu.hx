package menus;

import flash.geom.Rectangle;
import game.Camera;
import game.tilemap.AnimatedTile;
import game.tilemap.Tilemap;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.text.BitmapFont;
import starling.text.TextField;
import utility.ControlManager.ControlAction;
import utility.Utils;

/**
 * ...
 * @author CS413
 */
class MainMenu extends MenuState
{

	private var title:TextField;
	private var options:TextField;
	
	private var ship:Sprite;
	
	private var tilemap:Tilemap;
	
	private var selection:Int;
	private var numOptions:Int = 3;
	
	public function new(rootSprite:Sprite) 
	{
		super(rootSprite);
		
	}
	
	override function init() {
		rootSprite.addChild(this);
		
		tilemap = new Tilemap(22, 18, 24.0);
		tilemap.scaleX = 24.0;
		tilemap.scaleY = 24.0;
		addChild(tilemap);
		
		var cam = new Camera(new Rectangle(0, 0, 22, 18));
		tilemap.update(new EnterFrameEvent("", 0), cam);
		
		title = new TextField(512, 200, "PIRATE GAME", BitmapFont.MINI, 50, 0x000000);
		title.x = 0;
		title.y = 40;
		title.vAlign = "top";
		addChild(title);
		
		options = new TextField(200, 200, "New Game\n\nHow to Play\n\nCredits", BitmapFont.MINI, 20, 0x000000);
		options.x = 120;
		options.y = 120;
		options.vAlign = "top";
		options.hAlign = "left";
		addChild(options);
		
		ship = new Sprite();
		ship.x = 80;
		ship.y = 130;
		var shipBase = new Image(Root.assets.getTexture("ships/pirate"));
		ship.pivotX = shipBase.width / 2;
		ship.pivotY = shipBase.height / 2;
		shipBase.smoothing = 'none';
		ship.addChild(shipBase);
		
		var shipFlag = new Image(Root.assets.getTexture("ships/pirate_flag"));
		shipFlag.smoothing = 'none';
		shipFlag.pivotX = 18;
		shipFlag.pivotY = 12;
		shipFlag.x = 18;
		shipFlag.y = 12;
		shipFlag.rotation = -Utils.deg2rad(90);
		ship.addChild(shipFlag);
		
		addChild(ship);
		
	}
	
	function up(action:ControlAction) {
		
		if(action.isActive()) {
			
			if (--selection < 0)
				selection = numOptions - 1;
				
			var t = new Tween(ship, 0.5, "easeInOut");
			t.animate("y", selection * 40 + 130);
			Starling.juggler.add(t);
		
		}
	}
	
	function down(action:ControlAction) {
		
		if(action.isActive()) {
				
			if (++selection >= numOptions)
				selection = 0;
				
			var t = new Tween(ship, 0.5, "easeInOut");
			t.animate("y", selection * 40 + 130);
			Starling.juggler.add(t);
		
		}
	}
	
	function confirm(action:ControlAction) {
		
		if (action.isActive()) {
			
			if(selection == 0)
				stop();
			else if(selection == 2) {
				pause();
				transitionOut(function() { var credits = new CreditsMenu(rootSprite, this); credits.start(); } );
			} else {
				pause();
				transitionOut(function() { var tut = new TutorialMenu(rootSprite, this); tut.start(); } );
			}
			
		}
		
	}
	
	override function deinit() {
		
		if (selection == 0) {
			var game = new Game(rootSprite);
			game.start();
		}
		
		
	}
	
	override function awake() {
		Root.controls.hook("up", "mainMenuUp", up);
		Root.controls.hook("down", "mainMenuDown", down);
		Root.controls.hook("menu", "mainMenuConfirm", confirm);
	}
	override function sleep() {
		Root.controls.unhook("up", "mainMenuUp");
		Root.controls.unhook("down", "mainMenuDown");
		Root.controls.unhook("menu", "mainMenuConfirm");
	}
	
	private override function transitionIn(?callback:Void->Void) {
		this.scaleX = 0;
		this.scaleY = 0;
		this.x = 256;
		this.y = 256;
		
		var tween = new Tween(this, 1.5, "easeInOut");
		tween.animate("scaleX", 1);
		tween.animate("scaleY", 1);
		tween.animate("x", 0);
		tween.animate("y", 0);
		tween.onComplete = function() {
			callback();
		}
		Starling.juggler.add(tween);
	}
	public function creditTransitionIn(?callback:Void->Void) {
		
		ship.x = -ship.width;
		var tween = new Tween(ship, 1.5, "easeInOut");
		tween.animate("x", 80);
		tween.onComplete = function() { callback(); };
		Starling.juggler.add(tween);
		
		tween = new Tween(title, 1.0, "easeInOut");
		tween.animate("y", 40);
		Starling.juggler.add(tween);
		
		tween = new Tween(options, 1.0, "easeInOut");
		tween.animate("x", 120);
		Starling.juggler.add(tween);
		
	}
	private override function transitionOut(?callback:Void->Void) {
		
		var tween = new Tween(ship, 2.0, "easeInOut");
		if(selection == 0) {
			tween.animate("x", 256);
			tween.animate("y", 192);
		} else {
			tween.animate("x", 512 + ship.width);
		}
		tween.onComplete = function() {
			callback();
		}
		Starling.juggler.add(tween);
		
		tween = new Tween(title, 1.5, "easeInOut");
		tween.animate("y", -100);
		Starling.juggler.add(tween);
		
		tween = new Tween(options, 1.5, "easeInOut");
		tween.animate("x", -options.width);
		Starling.juggler.add(tween);
	}
	
}