package utility;

class Utils
{
	
    public static function deg2rad(deg:Float):Float {
        return deg / 180.0 * Math.PI;
    }
	public static function rad2deg(rad:Float):Float {
		return (rad * 180.0) / Math.PI;
	}
	
	public static function arithMod(n:Int, d:Int):Int
	{
		var r = n % d;
		if (r < 0)
			r += d;
		return r;
		
	}
	
}