package menus;

import game.World;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.BitmapFont;
import starling.text.TextField;
import utility.ControlManager.ControlAction;
import utility.Utils;

/**
 * ...
 * @author CS413
 */
class UpgradeMenu extends MenuState
{

	private var world:World;
	
	private var bg:Image;
	
	private var textField:TextField;
	
	private var scoreField:TextField;
	private var sailField:TextField;
	private var anchorField:TextField;
	private var rudderField:TextField;
	private var profileField:TextField;
	
	public function new(rootSprite:Sprite, world:World) 
	{
		super(rootSprite);
		this.world = world;
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
		
		textField = new TextField(200, 400, "Score: \n\nSails: \n\nAnchors: \n\nRudders: \n\nProfile: ", BitmapFont.MINI, 15, 0x000000);
		textField.x = 190;
		textField.y = 80;
		textField.vAlign = "top";
		textField.hAlign = "left";
		addChild(textField);
		
		scoreField = new TextField(200, 400, "Hello World!", BitmapFont.MINI, 15, 0x000000);
		scoreField.x = 280;
		scoreField.y = 80;
		scoreField.vAlign = "top";
		scoreField.hAlign = "left";
		addChild(scoreField);
		
		sailField = new TextField(200, 400, "Hello World!", BitmapFont.MINI, 15, 0x000000);
		sailField.x = 280;
		sailField.y = 110;
		sailField.vAlign = "top";
		sailField.hAlign = "left";
		sailField.addEventListener(TouchEvent.TOUCH, function(event:TouchEvent) {
			if(event.touches[0].phase == TouchPhase.BEGAN && world.pointCounter > 0) {
				world.playerShip.setBoatAcceleration(world.playerShip.getBoatAcceleration() + 1/1000);
				world.pointCounter--;
				updateText();
			}
		});
		addChild(sailField);
		
		anchorField = new TextField(200, 400, "Hello World!", BitmapFont.MINI, 15, 0x000000);
		anchorField.x = 280;
		anchorField.y = 140;
		anchorField.vAlign = "top";
		anchorField.hAlign = "left";
		anchorField.addEventListener(TouchEvent.TOUCH, function(event:TouchEvent) {
			if(event.touches[0].phase == TouchPhase.BEGAN && world.pointCounter > 0) {
				world.playerShip.setBreakPower(world.playerShip.getBreakPower() - (1 / 100));
				world.pointCounter--;
				updateText();
			}
		});
		addChild(anchorField);
		
		rudderField = new TextField(200, 400, "Hello World!", BitmapFont.MINI, 15, 0x000000);
		rudderField.x = 280;
		rudderField.y = 170;
		rudderField.vAlign = "top";
		rudderField.hAlign = "left";
		rudderField.addEventListener(TouchEvent.TOUCH, function(event:TouchEvent) {
			if(event.touches[0].phase == TouchPhase.BEGAN && world.pointCounter > 0) {
				world.playerShip.setMaxAngle(world.playerShip.getMaxAngle() + (1 / 400));
				world.pointCounter--;
				updateText();
			}
		});
		addChild(rudderField);
		
		profileField = new TextField(200, 400, "Hello World!", BitmapFont.MINI, 15, 0x000000);
		profileField.x = 280;
		profileField.y = 200;
		profileField.vAlign = "top";
		profileField.hAlign = "left";
		profileField.addEventListener(TouchEvent.TOUCH, function(event:TouchEvent) {
			if(event.touches[0].phase == TouchPhase.BEGAN && world.pointCounter > 0) {
				world.playerShip.setMaxSpeed(world.playerShip.getMaxSpeed() + (1 / 180));
				world.pointCounter--;
				updateText();
			}
		});
		addChild(profileField);
		
		updateText();
	}
	
	override function awake() {
		Root.controls.hook("menu", "upgradeCloseMenu", closeMenu);
	}
	
	override function sleep() {
		Root.controls.unhook("menu", "upgradeCloseMenu");
	}
	
	function updateText() {
		
		var plus = world.pointCounter > 0 ? " [+]" : "";
		
		scoreField.text = world.pointCounter + " pts";
		sailField.text = Math.round(world.playerShip.getBoatAcceleration() * 1000) + plus;
		anchorField.text = Math.round(103 - world.playerShip.getBreakPower() * 100) + plus;
		rudderField.text = Math.round(world.playerShip.getMaxAngle() * 400) + plus;
		profileField.text = Math.round(world.playerShip.getMaxSpeed() * 180 - 10) + plus;
	}
	
	function closeMenu(action:ControlAction) {
		if (action.isActive()) {
			world.closeMenu();
			this.stop();
			this.removeFromParent();
			this.dispose();
		}
	}
	
}