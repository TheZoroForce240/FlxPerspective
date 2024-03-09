package perspective;

import flixel.system.FlxAssets.FlxShader;

/**
 * FlxShader that uses a perspectiveMatrix and viewMatrix to project a sprite into a 3D scene.
 */
class PerspectiveShader extends FlxShader
{
    @:glVertexSource("
        #extension GL_EXT_gpu_shader4 : enable
		#pragma header

        #define ASPECT 1.5;
		
		attribute float alpha;
		attribute vec4 colorMultiplier;
		attribute vec4 colorOffset;
		uniform bool hasColorTransform;

        uniform mat4 perspectiveMatrix;
        uniform mat4 viewMatrix;
        uniform float zOffset;

        uniform vec4 offset0;
        uniform vec4 offset1;
        uniform vec4 offset2;
        uniform vec4 offset3;
		
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

            if (gl_VertexID == 0)
            {
                gl_Position.x += offset0.x*0.001;
                gl_Position.y += offset0.y*0.001;
                gl_Position.z += offset0.z*0.001 * ASPECT;
            }
            else if (gl_VertexID == 1)
            {
                gl_Position.x += offset1.x*0.001;
                gl_Position.y += offset1.y*0.001;
                gl_Position.z += offset1.z*0.001 * ASPECT;
            }
            else if (gl_VertexID == 2)
            {
                gl_Position.x += offset2.x*0.001;
                gl_Position.y += offset2.y*0.001;
                gl_Position.z += offset2.z*0.001 * ASPECT;
            }
            else if (gl_VertexID == 3)
            {
                gl_Position.x += offset3.x*0.001;
                gl_Position.y += offset3.y*0.001;
                gl_Position.z += offset3.z*0.001 * ASPECT;
            }

            gl_Position = perspectiveMatrix * viewMatrix * gl_Position;
		}
    ")
    public function new()
    {
        super();
    }
}