package movable;
import cmath.Vector;
import game.World;
import starling.display.Image;
import starling.display.Sprite;
import utility.Point;
import starling.textures.Texture;
import starling.display.Quad;

class PathingShip extends Ship {

	private var a_Point:Array<Point> = null;
	private var pointIndex:Int = 0;
	
	public function new(texture:Texture, flagTexture:Texture, world:World, maxSpeed, maxAngle){
		super(texture, flagTexture, world, maxSpeed, maxAngle);
		onArrive(arrivedAtPoint);
	}
	
	public function setPath(a_Point:Array<Point>){
		this.a_Point = a_Point;
		pointIndex = 0;
		arrivedAtPoint();
	}
	
	public function arrivedAtPoint(){
		goTo( a_Point[pointIndex].x, a_Point[pointIndex].y );
		pointIndex = (pointIndex+1) % a_Point.length;
	}
}