package movable;

class ShipBuilder{
	private static var SHIP_SMALL;
	private static var SHIP_LARGE;
	private static var FLAG_PIRATE;
	private static var FLAG_ENGLISH;
	private static var FLAG_SMALL;
	private static var CANNON_BALL;
	
	public static function populateResources(){
		SHIP_SMALL = Root.assets.getTexture("ships/pirate");
		SHIP_LARGE = Root.assets.getTexture("ships/big_ship");
		FLAG_PIRATE  = Root.assets.getTexture("ships/pirate_flag");
		FLAG_ENGLISH  = Root.assets.getTexture("ships/big_ship_sail_english");
		FLAG_SMALL = Root.assets.getTexture("ships/small_ship_sail_english");
		CANNON_BALL = Root.assets.getTexture("cannonball");
	};
	
	/* Returns a pirate ship with up to two cannons */
	public static function getPirateShip(world, cannonMask:Int = 0x3, maxSpeed:Float = 0.0833, maxTurn:Float = 0.0122, turnFix:Bool = true, breakPower:Float = 0.980, acceleration:Float = 0.005):PathingShip{
		var ship = getSmallShip(world,cannonMask,maxSpeed,maxTurn,turnFix,breakPower,acceleration);
		ship.addFlag(FLAG_PIRATE, 18, 12, 18, 12);
		return ship;
	}
	
	/* Returns a small ship with up to two cannons */
	public static function getCourrierShip(world, cannonMask:Int = 0x3, maxSpeed:Float = 0.0833, maxTurn:Float = 0.0122, turnFix:Bool = true, breakPower:Float = 0.980, acceleration:Float = 0.005):PathingShip{
		var ship = getSmallShip(world,cannonMask,maxSpeed,maxTurn,turnFix,breakPower,acceleration);
		ship.addFlag(FLAG_SMALL, 18, 12, 18, 12);
		return ship;
	}
	
	private static function getSmallShip(world, cannonMask:Int = 0x3, maxSpeed:Float = 0.0833, maxTurn:Float = 0.0122, turnFix:Bool = true, breakPower:Float = 0.980, acceleration:Float = 0.005):PathingShip{
		var ship = new PathingShip(SHIP_SMALL, world, maxSpeed, maxTurn);
		ship.setBreakPower( breakPower );
		ship.setBoatAcceleration( acceleration );
		ship.turnFix = turnFix;
		
		// Left cannon
		if(cannonMask & 0x1 != 0){
			var cannon = new Cannon(CANNON_BALL, Math.PI / 2, Math.PI / 4, 10, 1000);
			ship.addCannon(cannon, 16, 6);
		}
		
		// Right cannon
		if(cannonMask & 0x2 != 0){
			var cannon = new Cannon(CANNON_BALL, -Math.PI / 2, Math.PI / 4, 10, 1000);
			ship.addCannon(cannon, 16, 18);
		}
		
		ship.deathAnimationStr = "ships/pirate_sink_";
		return ship;
	}
	
	/* Returns a large english ship with up to 5 cannons */
	public static function getLargeEnglishShip(world, cannonMask:Int = 0x31, maxSpeed:Float = 0.075, maxTurn:Float = 0.0061, turnFix:Bool = true, breakPower:Float = 0.980, acceleration:Float = 0.005):PathingShip{
		var ship = new PathingShip(SHIP_LARGE, world, maxSpeed, maxTurn);
		ship.setBreakPower( breakPower );
		ship.setBoatAcceleration( acceleration );
		ship.turnFix = turnFix;
		
		// Front Left cannon
		if(cannonMask & 0x1 != 0){
			var cannon = new Cannon(CANNON_BALL, Math.PI / 2, Math.PI / 8, 20, 1000);
			ship.addCannon(cannon, 80, 10);
		}
		
		// Front Right cannon
		if(cannonMask & 0x2 != 0){
			var cannon = new Cannon(CANNON_BALL, -Math.PI / 2, Math.PI / 8, 20, 1000);
			ship.addCannon(cannon, 80, 39);
		}
		
		// Back Left cannon
		if(cannonMask & 0x4 != 0){
			var cannon = new Cannon(CANNON_BALL, Math.PI / 2, Math.PI / 8, 20, 1000);
			ship.addCannon(cannon, 40, 10);
		}
		
		// Back Right cannon
		if(cannonMask & 0x8 != 0){
			var cannon = new Cannon(CANNON_BALL, -Math.PI / 2, Math.PI / 8, 20, 1000);
			ship.addCannon(cannon, 40, 39);
		}
		
		// Rear cannon
		if(cannonMask & 0x16 != 0){
			var cannon = new Cannon(CANNON_BALL, 0, Math.PI / 8, 50, 1000);
			ship.addCannon(cannon, 6, 24);
		}
		
		ship.addFlag(FLAG_ENGLISH, 1, 13, 22, 24);
		ship.addFlag(FLAG_ENGLISH, 1, 13, 66, 24);
		ship.addFlag(FLAG_ENGLISH, 1, 13, 89, 24);
		
		ship.worthPoints = 2;
		ship.deathAnimationStr = "ships/big_ship_sink_";
		return ship;
	}
}