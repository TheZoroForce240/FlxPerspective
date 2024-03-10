package perspective;

import flixel.system.FlxAssets.FlxShader;

/**
 * FlxShader that uses a perspectiveMatrix and viewMatrix to project a sprite into a 3D scene.
 */
class PerspectiveShader extends FlxShader
{
    @:glVertexSource("
		#pragma header

        #define ASPECT 1.5;
		
		attribute float alpha;
		attribute vec4 colorMultiplier;
		attribute vec4 colorOffset;
		uniform bool hasColorTransform;

        uniform mat4 perspectiveMatrix;
        uniform mat4 viewMatrix;
        uniform float zOffset;

        attribute float vertexXOffset;
        attribute float vertexYOffset;
        attribute float vertexZOffset;
		
		void main(void)
		{
			#pragma body
			
			openfl_Alphav = openfl_Alpha * alpha;
			
			if (hasColorTransform)
			{
				openfl_ColorOffsetv = colorOffset / 255.0;
				openfl_ColorMultiplierv = colorMultiplier;
			}

            gl_Position.z = zOffset*0.001*ASPECT + 1.0; //add z value

            gl_Position.x += vertexXOffset*0.001;
            gl_Position.y += vertexYOffset*0.001;
            gl_Position.z += vertexZOffset*0.001 * ASPECT;

            gl_Position = perspectiveMatrix * viewMatrix * gl_Position;
		}
    ")
    public function new()
    {
        super();
    }
}