package game;
 
import flash.media.SoundTransform;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.Event;
 
class Explosion extends Sprite
{
    private var clip:MovieClip;
       
    public function new(name:String, ?fps:Float = 10)
	{	
		super();
               
		this.clip = new MovieClip(Root.assets.getTextures(name), fps);
	
		var tween = new Tween(this, this.clip.numFrames / fps);
		tween.animate("alpha", 0);
		Starling.juggler.add(tween);
               
		this.clip.pivotX = this.clip.width / 2.0;
		this.clip.pivotY = this.clip.height / 2.0;
		this.clip.scaleX = 1 / 16.0;
		this.clip.scaleY = 1 / 16.0;
		this.clip.smoothing = 'none';
		this.clip.loop = false;
		this.clip.addEventListener(Event.COMPLETE, function() {
			this.removeFromParent();
			Starling.juggler.remove(tween);
			this.dispose();
		});
		this.addChild(this.clip);
               
		Starling.juggler.add(this.clip);
               
		//Root.assets.playSound("Explosion1", 0, 0, Root.sfxTransform(0.65));
    }     
}