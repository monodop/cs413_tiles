package menus;

import game.World;
import starling.display.Image;
import starling.display.Sprite;
import utility.ControlManager.ControlAction;

/**
 * ...
 * @author CS413
 */
class UpgradeMenu extends MenuState
{

	private var world:World;
	
	private var bg:Image;
	
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
	}
	
	override function awake() {
		Root.controls.hook("menu", "upgradeCloseMenu", closeMenu);
	}
	
	override function sleep() {
		Root.controls.unhook("menu", "upgradeCloseMenu");
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