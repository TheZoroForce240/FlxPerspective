package perspective;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.geom.Vector3D;
import perspective.shaders.*;

/**
 * An object capable of rendering an `FlxSprite` with 3D perspective projection.
 * The depth of the object can be controled with the `z` value, 
 * and each corner of the sprite can also be offset and skewed using 
 * `offsetTL`, `offsetTR`, `offsetBL` and `offsetBR`.
 * The `camera3D` of this object can also be used to control the position and rotation of the scene, 
 * however there is no depth testing and objects will still need to be manually ordered (unless using an `FlxScene3D`).
 */
class FlxPerspectiveSprite extends FlxSprite
{
	/**
	 * Z Position of this object in world space.
	 * Uses a Left-Handed coordinate system (Positive Z = far away, Negative Z = close or behind)
	 */
	public var z:Float = 0;

	/**
	 * The shader that is automatically applied to allow for perspective projection, 
	 * for objects using their own custom shaders, they will need to inherit `PerspectiveShader`.
	 */
	private var _perspectiveShader:PerspectiveShader = new PerspectiveShader();

	/**
	 * Global camera that is set by default on every `FlxPerspectiveSprite`.
	 */
	@:isVar public static var globalCamera(get, set):Camera3D;

	private static function get_globalCamera()
	{
		if (globalCamera == null) // setup global camera
		{
			globalCamera = new Camera3D();
			FlxG.signals.preStateCreate.add(function(state)
			{
				globalCamera.reset();
			});
		}
		return globalCamera;
	}

	private static function set_globalCamera(cam:Camera3D)
	{
		return globalCamera = cam;
	}

	/**
	 * The current 3D camera of this object.
	 */
	public var camera3D:Camera3D;

	// public var angleX:Float = 0;
	// public var angleY:Float = 0;
	// public var angleZ:Float = 0;

	/**
	 * XYZ Offset for the Top Left corner of this sprite.
	 */
	public var offsetTL:Array<Float> = [0, 0, 0, 0];

	/**
	 * XYZ Offset for the Top Right corner of this sprite.
	 */
	public var offsetTR:Array<Float> = [0, 0, 0, 0];

	/**
	 * XYZ Offset for the Bottom Left corner of this sprite.
	 */
	public var offsetBL:Array<Float> = [0, 0, 0, 0];

	/**
	 * XYZ Offset for the Bottom Right corner of this sprite.
	 */
	public var offsetBR:Array<Float> = [0, 0, 0, 0];

	override public function new(?X:Float, ?Y:Float, ?Z:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);
		this.z = Z;
		shader = _perspectiveShader;
	}

	override function isOnScreen(?camera:FlxCamera)
	{
		if (camera3D == null)
			camera3D = globalCamera;

		if (!camera3D.perspectiveEnabled)
			return super.isOnScreen(camera);

		return true; // forcing on for now, maybe implement frustrum culling?
	}

	public function updateShader()
	{
		if (camera3D == null)
			camera3D = globalCamera;

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
			_perspectiveShader.vertexXOffset.value = [offsetTL[0], offsetTR[0], offsetBL[0], offsetBR[0]];
			_perspectiveShader.vertexYOffset.value = [offsetTL[1], offsetTR[1], offsetBL[1], offsetBR[1]];
			_perspectiveShader.vertexZOffset.value = [offsetTL[2], offsetTR[2], offsetBL[2], offsetBR[2]];
		}
		else
		{
			if (_perspectiveShader != null)
			{
				// set to identity matrix when not used
				_perspectiveShader.perspectiveMatrix.value = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
				_perspectiveShader.viewMatrix.value = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
				_perspectiveShader.zOffset.value = [z];
				_perspectiveShader.vertexXOffset.value = [offsetTL[0], offsetTR[0], offsetBL[0], offsetBR[0]];
				_perspectiveShader.vertexYOffset.value = [offsetTL[1], offsetTR[1], offsetBL[1], offsetBR[1]];
				_perspectiveShader.vertexZOffset.value = [offsetTL[2], offsetTR[2], offsetBL[2], offsetBR[2]];
			}
		}
	}

	override public function draw()
	{
		updateShader();
		super.draw();
	}

	/*
		public function rotateX(angle:Float)
		{
			var sin = Math.sin(angle*FlxAngle.TO_RAD)*0.5;
			var cos = Math.cos(angle*FlxAngle.TO_RAD)*0.5;

			offsetTL = [sin*width, 0, cos*width, 0];
			offsetTR = [-sin*width, 0, -cos*width, 0];
			offsetBL = [sin*width, 0, cos*width, 0];
			offsetBR = [-sin*width, 0, -cos*width, 0];
		}
	 */
	public var viewSpaceCenterPos:Vector3D = new Vector3D();

	private var _lastWorldCenterPos:Vector3D = new Vector3D();

	/**
	 * Temporary variable to make the floor render first, will be removed later whenever depth testing is added.
	 */
	public var isFloor:Bool = false;

	public function getViewSpaceVector()
	{
		if (camera3D == null)
			camera3D = globalCamera;

		@:privateAccess
		{
			if (camera3D._viewMatrix != null)
			{
				// var zMid:Float = 0;

				// zMid = offsetTL[2] + offsetTR[2] + offsetTL[2]

				// if (offsetTL[2] > maxZ) maxZ = offsetTL[2]; if (offsetTL[2] < minZ) minZ = offsetTL[2];
				// if (offsetTR[2] > maxZ) maxZ = offsetTR[2]; if (offsetTR[2] < minZ) minZ = offsetTR[2];
				// if (offsetBL[2] > maxZ) maxZ = offsetBL[2]; if (offsetBL[2] < minZ) minZ = offsetBL[2];
				// if (offsetBR[2] > maxZ) maxZ = offsetBR[2]; if (offsetBR[2] < minZ) minZ = offsetBR[2];

				// var zHalfway = (0.0)*0.5;
				viewSpaceCenterPos = camera3D._viewMatrix.transformVector(getCenter3D());
			}
		}
	}

	public function getCenter3D()
	{
		_lastWorldCenterPos.setTo(x + (width * 0.5), y + (height * 0.5), z);
		return _lastWorldCenterPos;
	}
}
