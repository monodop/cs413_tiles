package movable;

import starling.textures.Texture;
import cmath.Vector;

class Ship extends SimpleMovable {
	private var maxAngle : Float = Math.PI*2;
	
	private var gotoX:Float;
	private var gotoY:Float;
	private var paused:Bool = false;
	
	public function new(texture:Texture){
		super(texture);
	}
	
	public function setMaxAngle(maxAngle:Float){
		this.maxAngle = maxAngle;
	}
	
	public function goTo(x:Float,y:Float){
		gotoX = x;
		gotoY = y;
	}
	
	public function distanceFromDest():Float{
		return Math.sqrt((x-gotoX)*(x-gotoX) + (y-gotoY)*(y-gotoY));
	}
	
	/** Overriden version of the normal apply velocity, navigates towards a point */
	public override function applyVelocity(modifier:Float = 1.0):Bool{	
		if(distanceFromDest() < getMag())
			return false;
			
		var returnVal = super.applyVelocity(modifier);
		
		var thisVector = new Vector(vx,vy);
		var directVector = Vector.getVector(x,y,gotoX,gotoY);
		var angle = directVector.getVectorAngle( thisVector );
		
		// Angle correction
		if(Math.abs(angle) > Math.PI){
			angle -= angle/Math.abs(angle)*2*Math.PI;
		}
			
		// Apply a maximum angle if the angle is greater than that
		if(Math.abs(angle) > maxAngle){
			angle = angle/Math.abs(angle) * maxAngle;
		}
		
		thisVector = thisVector.rotate(angle);
		
		this.rotation = thisVector.getAngle();
		vx = thisVector.vx;
		vy = thisVector.vy;
		
		return returnVal;
	}
}