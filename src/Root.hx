import flash.media.SoundTransform;
import flash.ui.Keyboard;
import menus.*;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.KeyboardEvent;
import starling.events.TouchEvent;
import starling.utils.AssetManager;
import utility.ControlManager;

class Root extends Sprite {

	public static var assets:AssetManager;
	public static var controls:ControlManager;
	public static var sfxLevel:Float;
	public var rootSprite:Sprite;
	
	public function new() {
		rootSprite = this;
		super();
	}
	
	public static function sfxTransform(vol:Float):SoundTransform {
		return new SoundTransform(vol * sfxLevel);
	}
	
    public function start(startup:Startup)
	{
		controls = new ControlManager();
		controls.registerAction("left", Keyboard.A);
		controls.bindKey("left", Keyboard.LEFT);
		
		controls.registerAction("right", Keyboard.D);
		controls.bindKey("right", Keyboard.RIGHT);
		
		controls.registerAction("up", Keyboard.W);
		controls.bindKey("up", Keyboard.UP);
		
		controls.registerAction("down", Keyboard.S);
		controls.bindKey("down", Keyboard.DOWN);
		
		controls.registerAction("hold", Keyboard.SPACE);
		controls.registerAction("break", Keyboard.Z);
		
		controls.registerAction("menu", Keyboard.ESCAPE);
		controls.bindKey("menu", Keyboard.ENTER);
		
		controls.registerAction("retire", Keyboard.R);
		
		controls.registerAction("quadtreevis", Keyboard.F1);
		
		Starling.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, controls.keyDown);
		Starling.current.stage.addEventListener(KeyboardEvent.KEY_UP, controls.keyUp);
		Starling.current.stage.addEventListener(TouchEvent.TOUCH, controls.touch);
		
		sfxLevel = 0.5;
		
		assets = new AssetManager();
		assets.enqueue("assets/spritesheet.png");
		assets.enqueue("assets/spritesheet.xml");
		
		assets.enqueue("assets/sound/boop.mp3");
		assets.enqueue("assets/sound/ocean.mp3");
		assets.enqueue("assets/sound/cry0.mp3");
		assets.enqueue("assets/sound/cry1.mp3");
		assets.enqueue("assets/sound/cry2.mp3");
		assets.enqueue("assets/sound/explosion.mp3");
		assets.enqueue("assets/sound/PirateGameAnthem.mp3");
			
		assets.loadQueue(function onProgress(ratio:Float) {
			if (ratio == 1) {
				startup.removeChild(startup.loadingBitmap);
				//var menu = new Game(rootSprite);
				//Starling.current.showStats = true;
				//menu.start();
				
				playMusic(null);
				var menu = new MainMenu(rootSprite);
				menu.start();
			}
		});
		
	}
	
	public function playMusic(e:flash.events.Event){
		var musicChannel = Root.assets.playSound("PirateGameAnthem");
		musicChannel.addEventListener(flash.events.Event.SOUND_COMPLETE, playMusic);
		musicChannel.soundTransform = new SoundTransform(0.1, 0.1);
	}
}
