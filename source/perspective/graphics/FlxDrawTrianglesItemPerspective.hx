package perspective.graphics;

import flixel.graphics.tile.FlxDrawBaseItem;
import flixel.FlxG;
import flixel.FlxCamera;
import openfl.display.TriangleCulling;
import flixel.graphics.tile.FlxDrawTrianglesItem;

/**
 * An edit of `FlxDrawTrianglesItem` to enable triangle culling.
 */
class FlxDrawTrianglesItemPerspective extends FlxDrawTrianglesItem
{
	public var culling:TriangleCulling = TriangleCulling.NONE;

	public var nextTypedPerspective:FlxDrawTrianglesItemPerspective;

	override public function render(camera:FlxCamera):Void
	{
		if (!FlxG.renderTile)
			return;

		if (numTriangles <= 0)
			return;

		#if !flash
		var shader = shader != null ? shader : graphics.shader;
		shader.bitmap.input = graphics.bitmap;
		shader.bitmap.filter = (camera.antialiasing || antialiasing) ? LINEAR : NEAREST;
		shader.bitmap.wrap = REPEAT; // in order to prevent breaking tiling behaviour in classes that use drawTriangles
		shader.alpha.value = alphas;

		if (colored || hasColorOffsets)
		{
			shader.colorMultiplier.value = colorMultipliers;
			shader.colorOffset.value = colorOffsets;
		}

		setParameterValue(shader.hasTransform, true);
		setParameterValue(shader.hasColorTransform, colored || hasColorOffsets);

		#if (openfl > "8.7.0")
		camera.canvas.graphics.overrideBlendMode(blend);
		#end

		camera.canvas.graphics.beginShaderFill(shader);
		#else
		camera.canvas.graphics.beginBitmapFill(graphics.bitmap, null, true, (camera.antialiasing || antialiasing));
		#end

		camera.canvas.graphics.drawTriangles(vertices, indices, uvtData, culling);
		camera.canvas.graphics.endFill();

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
		{
			var gfx:Graphics = camera.debugLayer.graphics;
			gfx.lineStyle(1, FlxColor.BLUE, 0.5);
			gfx.drawTriangles(vertices, indices, uvtData);
		}
		#end

		FlxDrawBaseItem.drawCalls++;
	}
	override public function reset():Void
	{
		nextTypedPerspective = null;
		super.reset();
	}
	
	override public function dispose():Void
	{
		nextTypedPerspective = null;
		super.dispose();
	}
}