package perspective;

import flixel.FlxG;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * An `FlxStrip` which allows for 3D perspective projection, which can be used for rendering 3D models with triangles.
 */
class FlxPerspectiveStrip extends FlxPerspectiveSprite
{
	/**
	 * Stores all the current vertices loaded in.
	 */
	public var stripVertices:Array<StripVertex> = [];

	/**
	 * Adds a 3D vertex with texture coordinates into the group.
	 */
	public function addVertex(vert:StripVertex, flipX:Bool = false, flipY:Bool = false)
	{
		stripVertices.push(vert);

		vertices.push(flipX ? -vert.x : vert.x);
		vertices.push(flipY ? -vert.y : vert.y);
		zVertices.push(vert.z);
		uvtData.push(vert.uvX);
		uvtData.push(vert.uvY);
	}

	public function applyModelData(modelData:ModelData, flipX:Bool = false, flipY:Bool = false)
	{
		for (v in modelData.vertices)
			addVertex(v, flipX, flipY);
		for (i in modelData.indices)
			indices.push(i);
	}

	/**
	 * A `Vector` of floats where each pair of numbers is treated as a coordinate location (an x, y pair).
	 * Use `addVertex` to add to this vector!
	 */
	private var vertices:DrawData<Float> = new DrawData<Float>();

	/**
	 * An array of floats which store the z value of each vertex.
	 * Use `addVertex` to add to this array!
	 */
	private var zVertices:Array<Float> = [];

	/**
	 * A `Vector` of normalized coordinates used to apply texture mapping.
	 * Use `addVertex` to add to this vector!
	 */
	private var uvtData:DrawData<Float> = new DrawData<Float>();

	/**
	 * A `Vector` of integers or indexes, where every three indexes define a triangle.
	 */
	public var indices:DrawData<Int> = new DrawData<Int>();

	private var colors:DrawData<Int> = new DrawData<Int>();

	public var repeat:Bool = false;

	override public function destroy():Void
	{
		vertices = null;
		indices = null;
		uvtData = null;
		colors = null;
		zVertices = [];
		stripVertices = [];

		super.destroy();
	}

	// TODO: check this for cases when zoom is less than initial zoom...
	override public function draw():Void
	{
		if (alpha == 0 || graphic == null || vertices == null)
			return;

		updateShader();

		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists)
				continue;

			getScreenPosition(_point, camera).subtractPoint(offset);
			#if !flash
			camera.drawTriangles(graphic, vertices, indices, uvtData, colors, _point, blend, repeat, antialiasing, colorTransform, shader);
			#else
			camera.drawTriangles(graphic, vertices, indices, uvtData, colors, _point, blend, repeat, antialiasing);
			#end
		}
	}

	override public function updateShader()
	{
		if (camera3D == null)
			camera3D = FlxPerspectiveSprite.globalCamera;

		if (camera3D.perspectiveEnabled)
		{
			if (_perspectiveShader == null)
				return;

			if (shader != _perspectiveShader) // shader does not match
			{
				if (shader is PerspectiveShader)
					_perspectiveShader = cast shader; // if using custom shader, make sure _perspectiveShader is the same
				else
				{
					FlxG.log.warn('Custom FlxShader on FlxPerspectiveSprite does not inherit PerspectiveShader!');
					_perspectiveShader = null;
					return;
				}
			}

			camera3D.applyTransformToPerspectiveShader(_perspectiveShader);
			_perspectiveShader.zOffset.value = [z];
			_perspectiveShader.vertexZOffset.value = zVertices;
		}
		else
		{
			if (_perspectiveShader != null)
			{
				// set to identity matrix when not used
				_perspectiveShader.perspectiveMatrix.value = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
				_perspectiveShader.viewMatrix.value = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
				_perspectiveShader.zOffset.value = [z];
				_perspectiveShader.vertexZOffset.value = zVertices;
			}
		}
	}
}
