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
	
	public static function between(a:Float, b:Float, c:Float) {
		return (a <= b && b <= c) || (c <= b && b <= a);
	}
	
}