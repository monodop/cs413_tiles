
package starling.filters
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
	import starling.textures.Texture;
	
	public class SelectorFilter extends FragmentFilter {
		
		private static const FRAGMENT_SHADER:String =
		<![CDATA[
		// Move the coordinates into a temporary register
		mov ft0, v0
		
		// Calculate Wave Effect
		// Coordinate into ft0
		add ft1.y, fc0.z, ft0.x		// Clk + Coord.X
		mul ft1.y, ft1.y, fc0.y		// Result * Frequency
		add ft1.y, ft1.y, ft0.y		// Result + Coord.Y
		sin ft1.y, ft1.y			// Sin(Result)
		mul ft1.y, ft1.y, fc0.x		// Result * Amplitude
		sub ft1.y, ft1.y, fc0.x		// Result - Amplitude
		add ft1.y, ft0.y, ft1.y		// Result + Coord.Y
		mov ft0.y, ft1.y			// Move Result to Coord.Y
		
		// Calculate Shadow Effect Coordinate
		mov ft1, ft0
		sub ft1.xy, ft1.xy, fc1.xy
		
		// Get textures at the texture coordinate and shadow coordinate
		tex ft2, ft0, fs0<2d, clamp, linear, nomip>
		
		// Apply selection effect to the text
		mov ft4.x, fc2.w
		mul ft4.x, ft4.x, fc2.x		// Line Height * Selected Line
		add ft4.x, ft4.x, fc2.y		// Result + Offset
		add ft4.y, ft4.x, fc2.x		// Result + Line Height
		sge ft4.z, v0.y, ft4.x		// ft4.z = result of coord.y >= lower bound
		slt ft4.w, v0.y, ft4.y		// ft4.w = result of coord.y < higher bound
		mul ft4.z, ft4.z, ft4.w		// ft4.z = result of z & w
		mul ft4.z, ft4.z, fc2.z		// ft4.z = result of prev & selected
		
		// Move the color to a temporary register
		mov ft5, fc3
		sub ft5, fc0.wwww, ft5		// Invert the color
		mul ft5, ft5, ft4.zzzz		// Multiply the color by ft4.z (whether or not the color should be applied
		sub ft2, ft2, ft5			// Subtract the color, or lack of color, from the actual color
		
		tex ft3, ft1, fs0<2d, clamp, linear, nomip>
		
		// Multiply rgb of shadow by shadow.w
		mul ft3.rgba, ft3.rgba, fc1.wwwz
		
		// Add shadow
		add ft2, ft2, ft3
		
		// Move the updated texture to the output channel
		mov oc, ft2
		]]>
		
		private var wave:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
		private var shadow:Vector.<Number> = new <Number>[1.0, 1.0, 0.75, 0.0];
		private var selection:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
		private var selectionColor:Vector.<Number> = new <Number>[0.5, 1.0, 0.0, 1.0];
		private var shaderProgram:Program3D;
		
		private var mAmplitude:Number;
		private var mFrequency:Number;
		private var mClk:Number;
		
		private var mLineHeight:Number;
		private var mLineOffset:Number;
		private var mSelected:Boolean;
		private var mSelectedLine:int;
		
		public function SelectorFilter(amplitude:Number, frequency:Number, lineHeight:Number = 10.0, lineOffset:Number = 1.0) {
			mAmplitude = amplitude;
			mFrequency = frequency;
			mLineHeight = lineHeight;
			mLineOffset = lineOffset;
			mClk = 0.0;
			mSelected = false;
			mSelectedLine = 0;
			super();
		}
		
		public override function dispose():void {
			if (shaderProgram) shaderProgram.dispose();
			super.dispose();
		}
		
		protected override function createPrograms():void {
				
			shaderProgram = assembleAgal(FRAGMENT_SHADER);
		}
 
		protected override function activate(pass:int, context:Context3D, texture:Texture):void
		{
			// already set by super class:
			// 
			// vertex constants 0-3: mvpMatrix (3D)
			// vertex attribute 0:   vertex position (FLOAT_2)
			// vertex attribute 1:   texture coordinates (FLOAT_2)
			// texture 0:            input texture
			
			wave[0] = mAmplitude / texture.height;
			wave[1] = mFrequency;
			wave[2] = mClk;
			
			shadow[0] = 1.0 / texture.width;
			shadow[1] = 1.0 / texture.height;
			
			selection[0] = lineHeight / texture.height;
			selection[1] = lineOffset / texture.height + wave[0];
			selection[2] = selected ? 1.0 : 0.0;
			selection[3] = selectedLine;
			
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, wave, 1);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, shadow, 1);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, selection, 1);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, selectionColor, 1);
			context.setProgram(shaderProgram);
		}
 
		public function get amplitude():Number { return mAmplitude; }
		public function set amplitude(value:Number):void { mAmplitude = value; }
	 
		public function get frequency():Number { return mFrequency; }
		public function set frequency(value:Number):void { mFrequency = value; }
	 
		public function get clk():Number { return mClk; }
		public function set clk(value:Number):void { mClk = value; }
	 
		public function get lineHeight():Number { return mLineHeight; }
		public function set lineHeight(value:Number):void { mLineHeight = value; }
	 
		public function get selected():Boolean { return mSelected; }
		public function set selected(value:Boolean):void { mSelected = value; }
	 
		public function get selectedLine():int { return mSelectedLine; }
		public function set selectedLine(value:int):void { mSelectedLine = value; }
	 
		public function get lineOffset():Number { return mLineOffset; }
		public function set lineOffset(value:Number):void { mLineOffset = value; }
	}
}