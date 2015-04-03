package utility;

import starling.core.Starling;
import starling.core.RenderSupport;
import starling.textures.Texture;
import flash.geom.Point;
import haxe.Timer;

class HealthBar extends starling.display.Image {
	
	public var maxWidth:Int;
	var fillPercent:Float = 1.0;
	var animationTimer:Timer = null;
	public var defaultColor:UInt;
	
	function new(width:Int, height:Int, texture:Texture){
		super(texture);
		defaultColor = color;
		this.height = height;
		this.width = maxWidth = width;
		setBarSpan(1.0);
	}
	
	public function flashColor(color:UInt, ms:Int){
		this.color = color;
		
		haxe.Timer.delay(function(){
			this.color = defaultColor;
		}, Math.round(ms));
	}
	
	public function animateBarSpan(targetPercent:Float, changeAmount:Float){
		if(targetPercent < 0)
			targetPercent = 0;
		if(targetPercent > 1)
			targetPercent = 1;
		if(targetPercent == fillPercent)
			return;
			
		if(animationTimer != null)
			animationTimer.stop();
		
		animationTimer = new Timer(17);
		animationTimer.run = function(){
			if(targetPercent == fillPercent){
				animationTimer.stop();
				animationTimer = null;
			} else if(targetPercent < fillPercent){
				fillPercent -= changeAmount;
				if(targetPercent > fillPercent)
					targetPercent = fillPercent;
			} else {
				fillPercent += changeAmount;
				if(targetPercent < fillPercent)
					targetPercent = fillPercent;
			}
			
			setBarSpan(fillPercent);
		};
	}
	
	public function getBarSpan():Float{
		return fillPercent;
	}
	
	public function setBarSpan(fillPercent:Float){
		if(fillPercent >= 0 && fillPercent <= 1){
			this.fillPercent = fillPercent;
			setTexCoordsTo(0, 0, 0);				// 0---1
			setTexCoordsTo(1, fillPercent, 0);		// | / |
			setTexCoordsTo(2, 0, 1);				// 2---3
			setTexCoordsTo(3, fillPercent, 1);
			this.width = maxWidth*fillPercent;
		}
	}
}