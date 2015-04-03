package menus;

import starling.animation.Tween;
import starling.core.Starling;
import starling.display.Sprite;
import starling.text.BitmapFont;
import starling.text.TextField;

/**
 * ...
 * @author CS413
 */
class CreditsMenu extends MenuState
{

	private var credits:TextField;
	private var mainMenu:MainMenu;
	
	public function new(rootSprite:Sprite, mainMenu:MainMenu) 
	{
		super(rootSprite);
		
		this.mainMenu = mainMenu;
		
	}
	
	public override function init() {
		rootSprite.addChild(this);
		
		credits = new TextField(512, 384,
			"Michael Albanese\n\n\n" +
			"John Loudon\n\n\n" +
			"Harrison Lambeth", BitmapFont.MINI, 20, 0x000000);
		credits.y = -300;
		addChild(credits);
		
		
		var t = new Tween(credits, 5.0, "easeOutIn");
		t.animate("y", 284);
		t.onComplete = function() {
			mainMenu.creditTransitionIn(function() { mainMenu.start(); } );
			stop();
		};
		Starling.juggler.add(t);
		
	}
	
}