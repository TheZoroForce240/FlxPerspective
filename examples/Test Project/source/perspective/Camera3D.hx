package perspective;

import flixel.FlxG;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.geom.*;

using flixel.util.FlxColorTransformUtil;

enum CameraStyle
{
	NONE;
	FOLLOW;
	LOOKTO;
}

/**
 * An object that controls a perspective and view matrix for rendering a 3D scene.
 */
class Camera3D implements IFlxDestroyable
{
	/**
	 * Perspective matrix used for projecting 3D world space coordinates into 2D.
	 */
	private var _perspectiveMatrix:PerspectiveProjection = new PerspectiveProjection();

	/**
	 * View matrix that controls the camera position and direction in the world.
	 */
	private var _viewMatrix:Matrix3D = new Matrix3D();

	/**
	 * Where the camera is currently looking at in the world.
	 */
	public var lookAt:Vector3D = new Vector3D(0, 0, 1);

	/**
	 * The camera's current XYZ position in the world.
	 */
	public var eyePos:Vector3D = new Vector3D(0, 0, 0);

	/**
	 * The camera's current up vector.
	 */
	public var upVec:Vector3D = new Vector3D(0, 1, 0);

	/**
	 * Changes the way the camera acts,
	 * setting it to `LOOKTO` will have the camera act like a first person camera,
	 * using `FOLLOW` will act more like a third person camera that rotates around its target position. 
	 */
	public var cameraStyle:CameraStyle = LOOKTO;

	public var x(get, set):Float;
	public var y(get, set):Float;
	public var z(get, set):Float;

	/**
	 * Camera rotation on the X axis (used with `LOOKTO` and `FOLLOW` camera styles).
	 */
	public var yaw:Float = 0;

	/**
	 * Camera rotation on the Y axis (used with `LOOKTO` and `FOLLOW` camera styles).
	 */
	public var pitch:Float = 0;

	/**
	 * Camera rotation on the Z axis (used with `LOOKTO` and `FOLLOW` camera styles).
	 */
	public var roll:Float = 0;

	/**
	 * The distance of the eye from the target position when using the `FOLLOW` camera style.
	 */
	public var followDistance:Float = 1.0;

	/**
	 * Toggles the 3D effect of any `FlxPerspectiveSprite` using this camera.
	 */
	public var perspectiveEnabled:Bool = true;

	public function new()
	{
		_perspectiveMatrix.fieldOfView = 90;
		_perspectiveMatrix.focalLength = (1.0 / Math.tan(_perspectiveMatrix.fieldOfView * 0.5));

		// _viewMatrix.pointAt(eyePos, lookAt, upVec);
		updateViewMatrix();
	}

	/**
	 * Updates the view matrix based on the `eyePos`, `lookAt`, and `yaw`/`pitch`/`roll` if using a camera style.
	 */
	public function updateViewMatrix()
	{
		if (!perspectiveEnabled)
			return;
		_viewMatrix.identity();

		if (cameraStyle == LOOKTO)
		{
			lookAt.x = Math.sin(yaw);
			lookAt.y = Math.sin(pitch);
			lookAt.z = Math.cos(yaw) * Math.cos(pitch);

			lookAt = lookAt.add(eyePos);

			upVec.y = Math.cos(roll);
			upVec.x = Math.sin(roll);
			upVec.z = Math.sin(roll);
		}
		else if (cameraStyle == FOLLOW)
		{
			eyePos.x = Math.sin(yaw) * followDistance;
			eyePos.y = Math.sin(pitch) * followDistance;
			eyePos.z = Math.cos(yaw) * Math.cos(pitch) * followDistance;
			eyePos = eyePos.add(lookAt);
		}

		var forward:Vector3D = lookAt.subtract(eyePos);
		forward.normalize();
		var right:Vector3D = upVec.crossProduct(forward);
		right.normalize();
		var newup:Vector3D = forward.crossProduct(right);

		var negEye = new Vector3D(-eyePos.x, -eyePos.y, -eyePos.z, 0);

		/*
			_viewMatrix.rawData[0] = right.x;
			_viewMatrix.rawData[4] = right.y;
			_viewMatrix.rawData[8] = right.z;
			_viewMatrix.rawData[12] = 0.0;
			_viewMatrix.rawData[1] = newup.x;
			_viewMatrix.rawData[5] = newup.y;
			_viewMatrix.rawData[9] = newup.z;
			_viewMatrix.rawData[13] = 0.0;
			_viewMatrix.rawData[2] = forward.x;
			_viewMatrix.rawData[6] = forward.y;
			_viewMatrix.rawData[10] = forward.z;
			_viewMatrix.rawData[14] = 0.0;
			_viewMatrix.rawData[3] = right.dotProduct(negEye);
			_viewMatrix.rawData[7] = newup.dotProduct(negEye);
			_viewMatrix.rawData[11] = forward.dotProduct(negEye);
			_viewMatrix.rawData[15] = 1.0;
		 */

		_viewMatrix.rawData[0] = right.x;
		_viewMatrix.rawData[1] = newup.x;
		_viewMatrix.rawData[2] = forward.x;
		_viewMatrix.rawData[3] = 0.0;
		_viewMatrix.rawData[4] = right.y;
		_viewMatrix.rawData[5] = newup.y;
		_viewMatrix.rawData[6] = forward.y;
		_viewMatrix.rawData[7] = 0.0;
		_viewMatrix.rawData[8] = right.z;
		_viewMatrix.rawData[9] = newup.z;
		_viewMatrix.rawData[10] = forward.z;
		_viewMatrix.rawData[11] = 0.0;
		_viewMatrix.rawData[12] = right.dotProduct(negEye);
		_viewMatrix.rawData[13] = newup.dotProduct(negEye);
		_viewMatrix.rawData[14] = forward.dotProduct(negEye);
		_viewMatrix.rawData[15] = 1.0;
	}

	/**
	 * Applies the perspective and view matrices onto a `PerspectiveShader`.
	 * @param shader The shader the matrices will be applied to.
	 */
	public function applyTransformToPerspectiveShader(shader:PerspectiveShader)
	{
		if (shader == null)
			return;
		var mat = _perspectiveMatrix.toMatrix3D();
		shader.perspectiveMatrix.value = getMatrixFloatArray(mat); // update matrix value
		shader.viewMatrix.value = getMatrixFloatArray(_viewMatrix);
	}

	/**
	 * Helper function that converts a `Matrix3D` into `Array<Float>`
	 */
	private function getMatrixFloatArray(mat:Matrix3D):Array<Float>
	{
		var matData:Array<Float> = [];
		for (i in mat.rawData)
			matData.push(i);
		return matData;
	}

	/**
	 * Simple camera controls that can be used for debugging and testing.
	 * (`LOOKAT`: use WASD and SPACE/SHIFT to move the camera, and arrow keys to look around.
	 * `FOLLOW`: use W/S to change distance from target, and arrow keys to look.)
	 */
	public function debugControls(elapsed:Float)
	{
		var speed = elapsed;

		if (FlxG.keys.pressed.CONTROL)
			speed *= 5;

		if (FlxG.keys.pressed.RIGHT)
			yaw += elapsed;
		if (FlxG.keys.pressed.LEFT)
			yaw -= elapsed;
		if (FlxG.keys.pressed.UP)
			pitch += elapsed;
		if (FlxG.keys.pressed.DOWN)
			pitch -= elapsed;
		if (FlxG.keys.pressed.Z)
			roll += elapsed;
		if (FlxG.keys.pressed.X)
			roll -= elapsed;

		if (cameraStyle == LOOKTO)
		{
			var lookDir = new Vector3D();
			lookDir.x = Math.sin(yaw) * speed;
			lookDir.y = Math.sin(pitch) * speed;
			lookDir.z = Math.cos(yaw) * Math.cos(pitch) * speed;

			var strafe:Vector3D = lookDir.crossProduct(upVec);
			strafe.normalize();
			strafe.scaleBy(speed);

			if (FlxG.keys.pressed.W)
				eyePos = eyePos.add(lookDir);
			if (FlxG.keys.pressed.S)
				eyePos = eyePos.subtract(lookDir);
			if (FlxG.keys.pressed.A)
				eyePos = eyePos.add(strafe);
			if (FlxG.keys.pressed.D)
				eyePos = eyePos.subtract(strafe);

			if (FlxG.keys.pressed.SPACE)
				eyePos.y += speed;
			if (FlxG.keys.pressed.SHIFT)
				eyePos.y -= speed;
		}
		else if (cameraStyle == FOLLOW)
		{
			if (FlxG.keys.pressed.W)
				followDistance += speed;
			if (FlxG.keys.pressed.S)
				followDistance -= speed;
		}
	}

	/**
	 * Resets all of the camera values to their defaults.
	 */
	public function reset()
	{
		lookAt.setTo(0, 0, 1);
		eyePos.setTo(0, 0, 0);
		upVec.setTo(0, 1, 0);
		cameraStyle = LOOKTO;
		yaw = 0;
		pitch = 0;
		roll = 0;
		followDistance = 1;
	}


	//TODO: fix this to match correctly with flixel coordinates

	function set_x(value:Float):Float
	{
		return eyePos.x = value * 0.001;
	}

	function set_y(value:Float):Float
	{
		return eyePos.y = value * 0.001;
	}

	function set_z(value:Float):Float
	{
		return eyePos.z = value * 0.001;
	}

	function get_x():Float
	{
		return eyePos.x * 1000;
	}

	function get_y():Float
	{
		return eyePos.y * 1000;
	}

	function get_z():Float
	{
		return eyePos.z * 1000;
	}

	public function destroy()
	{
		lookAt = null;
		eyePos = null;
		upVec = null;
		_perspectiveMatrix = null;
		_viewMatrix = null;
		perspectiveEnabled = false;
	}
}
