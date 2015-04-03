package game.tilemap;

import flash.geom.Rectangle;
import game.Camera;
import game.World;
import haxe.ds.Vector;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;

class Tilemap extends Sprite
{

	public var sizeX:Int = 0;
	public var sizeY:Int = 0;
	
	public var tileSize:Float;
	
	//public var world:World;
	private var tiles:Vector<Vector<Tile>>;
	private var bigTiles:Vector<Vector<Sprite>>;
	private static var bigTileSize:Int = 5;
	
	public function new(sizeX:Int, sizeY:Int, tileSize:Float) 
	{
		super();
		
		this.tileSize = tileSize;
		this.sizeX = sizeX;
		this.sizeY = sizeY;
		//this.world = world;
		
		// Generate bigTiles arrays
		bigTiles = new Vector<Vector<Sprite>>(Math.ceil(sizeX / bigTileSize));
		for (x in 0...bigTiles.length) {
			bigTiles[x] = new Vector<Sprite>(Math.ceil(sizeY / bigTileSize));
			for (y in 0...bigTiles[x].length) {
				bigTiles[x][y] = new Sprite();
				bigTiles[x][y].x = x * bigTileSize;
				bigTiles[x][y].y = y * bigTileSize;
				//addChild(bigTiles[x][y]);
			}
		}
		
		// Generate tiles; fill tiles and bigTiles arrays
		tiles = new Vector<Vector<Tile>>(sizeX);
		for (x in 0...sizeX) {
			tiles[x] = new Vector<Tile>(sizeY);
			for (y in 0...sizeY) {
				
				var bigX = Math.floor(x / bigTileSize);
				var bigY = Math.floor(y / bigTileSize);
				
				var tileX = x - (bigX * bigTileSize);
				var tileY = y - (bigY * bigTileSize);
				
				tiles[x][y] = new AnimatedTile("world/water_", false, this, x, y);
				tiles[x][y].x = tileX;
				tiles[x][y].y = tileY;
				
				bigTiles[bigX][bigY].addChild(tiles[x][y]);
				if (tiles[x][y].isSolid()) {
					// Insert into quad tree
				}
				
			}
		}
		
		// Flatten each big tile to optimize rendering.
		for (x in 0...bigTiles.length) {
			for (y in 0...bigTiles[x].length) {
				//bigTiles[x][y].flatten();
			}
		}
	}
	
	public function getTile(x:Int, y:Int):Tile {
		
		if (x < 0 || x >= sizeX || y < 0 || y >= sizeY)
			return null;
		return this.tiles[x][y];
		
	}
	
	public function getTiles():Array<Tile> {
		
		var res = new Array<Tile>();
		for (x in 0...sizeX) {
			for (y in 0...sizeY) {
				res.push(tiles[x][y]);
			}
		}
		return res;
		
	}
	
	public function update(event:EnterFrameEvent, camera:Camera) {
		
		var camBounds:Rectangle = camera.getCameraBounds(this, 10);
		for (x in 0...bigTiles.length) {
			for (y in 0...bigTiles[x].length) {
				var rect:Rectangle = new Rectangle(bigTiles[x][y].x, bigTiles[x][y].y, bigTileSize, bigTileSize);
				if (rect.intersects(camBounds)) {
					if (getChildIndex(bigTiles[x][y]) == -1) {
						addChild(bigTiles[x][y]);
					}
				} else {
					bigTiles[x][y].removeFromParent();
				}
			}
			
		}
		
	}
	
}