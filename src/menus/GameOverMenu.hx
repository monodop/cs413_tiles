package menus;

import starling.animation.Tween;
import starling.core.Starling;
import starling.text.BitmapFont;
import starling.text.TextField;
import game.World;
import starling.display.Image;
import starling.display.Sprite;
import utility.ControlManager.ControlAction;

/**
 * ...
 * @author CS413
 */
class GameOverMenu extends MenuState
{

	private var world:World;
	private var gameState:MenuState;
	
	private var bg:Image;
	private var GAMEOVER:TextField;
	private var scoreField:TextField;
	
	public function new(rootSprite:Sprite, world:World, gameState:MenuState) 
	{
		super(rootSprite);
		
		this.world = world;
		this.gameState = gameState;
		
	}
	
	override function init() {
		rootSprite.addChild(this);
		
		bg = new Image(Root.assets.getTexture("gui/upgrademenu"));
		bg.x = 0;
		bg.y = 0;
		bg.scaleX = 2.0;
		bg.scaleY = 2.0;
		bg.smoothing = 'none';
		addChild(bg);
		
		GAMEOVER = new TextField(200, 400, "GAME OVER", BitmapFont.MINI, 20, 0x000000);
		GAMEOVER.x = 195;
		GAMEOVER.y = 80;
		GAMEOVER.vAlign = "top";
		GAMEOVER.hAlign = "left";
		addChild(GAMEOVER);
		
		scoreField = new TextField(200, 400, "Score: " + world.pointCounter, BitmapFont.MINI, 15, 0x000000);
		scoreField.x = 190;
		scoreField.y = 120;
		scoreField.vAlign = "top";
		scoreField.hAlign = "left";
		addChild(scoreField);
	}
	
	override function awake() {
		Root.controls.hook("menu", "gameoverCloseMenu", closeMenu);
	}
	
	override function sleep() {
		Root.controls.unhook("menu", "gameoverCloseMenu");
	}
	
	function closeMenu(action:ControlAction) {
		
		stop();
		
	}
	
	override function deinit() {
		gameState.stop();
		gameState.removeFromParent();
		gameState.dispose();
		
		removeFromParent();
		dispose();
		
		gameState = new Game(rootSprite);
		gameState.start();
	}
	
	private override function transitionIn(?callback:Void->Void) {
		this.y = Starling.current.stage.stageHeight;
		
		var tween = new Tween(this, 1.0, "easeInOut");
		tween.animate("y", 0);
		tween.onComplete = function() {
			callback();
		}
		Starling.juggler.add(tween);
	}
	private override function transitionOut(?callback:Void->Void) {
		this.y = 0;
		
		var tween = new Tween(this, 1.0, "easeInOut");
		tween.animate("y", Starling.current.stage.stageHeight);
		tween.onComplete = function() {
			callback();
		}
		Starling.juggler.add(tween);
	}
	
}