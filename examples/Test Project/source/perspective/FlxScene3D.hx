package perspective;

// import flixel.FlxG;
// import flixel.FlxSprite;
// import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
// import flixel.graphics.tile.FlxDrawBaseItem;
// import flixel.graphics.tile.FlxDrawQuadsItem;
import flixel.group.FlxGroup;

// import flixel.util.FlxColor;
// import openfl.display.Bitmap;
// import openfl.display.BitmapData;
// import openfl.display.Sprite;
// using flixel.util.FlxColorTransformUtil;

/**
 * `FlxGroup` that can contain multiple `FlxPerspectiveSprite` objects,
 * and automatically sort them based on their position from the camera.
 */
class FlxScene3D extends FlxTypedGroup<FlxPerspectiveSprite>
{
	// private var depthMap:Sprite;
	// private var depthBitmap:BitmapData;
	// var depthSpr:FlxPerspectiveSprite;
	// var testSprite:FlxPerspectiveSprite;
	override public function new()
	{
		super();

		// depthMap = new Sprite();
		// depthBitmap = new BitmapData(1280, 720);

		// depthSpr = new FlxPerspectiveSprite();
		// depthSpr.loadGraphic(depthBitmap);
		// add(depthSpr);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		for (m in members) // update closest z value
			m.getViewSpaceVector();

		members.sort(function(spr1, spr2) // basic painters algorithm
		{
			var a = spr1.viewSpaceCenterPos.z;
			var b = spr2.viewSpaceCenterPos.z;
			if (spr1.isFloor && !spr2.isFloor)
				return -1;
			if (!spr1.isFloor && spr2.isFloor)
				return 1;
			if (spr1.isFloor && spr2.isFloor)
			{
				if (spr1.y > spr2.y)
					return -1;
				else if (spr1.y < spr2.y)
					return 1;
			}

			if (a > b)
				return -1;
			else if (a < b)
				return 1;
			return 0;
		});

		// depthMap.graphics.
	}

	override public function draw()
	{
		// FlxG.stage.context3D.setDepthTest(true, LESS_EQUAL);
		// drawDepthMap();
		super.draw();
		// FlxG.stage.context3D.doDepthTest = false;
		// FlxG.stage.context3D.depthTestMode = ALWAYS;
		// FlxG.stage.context3D.setDepthTest(false, ALWAYS);
	}
	/*
		private function drawDepthMap()
		{
			var quads:Array<FlxDrawQuadsItem> = [];

			depthMap.x = camera.canvas.x;
			depthMap.y = camera.canvas.y;
			depthMap.scaleX = camera.canvas.scaleX;
			depthMap.scaleY = camera.canvas.scaleY;

			@:privateAccess
			{
				for (sprite in members)
				{
					
					sprite._frame.prepareMatrix(sprite._matrix, FlxFrameAngle.ANGLE_0, sprite.checkFlipX(), sprite.checkFlipY());
					sprite._matrix.translate(-sprite.origin.x, -sprite.origin.y);
					sprite._matrix.scale(sprite.scale.x, sprite.scale.y);
			
					if (sprite.bakedRotationAngle <= 0)
					{
						sprite.updateTrig();
			
						if (sprite.angle != 0)
							sprite._matrix.rotateWithTrig(sprite._cosAngle, sprite._sinAngle);
					}
			
					sprite.getScreenPosition(sprite._point, sprite.camera).subtractPoint(sprite.offset);
					sprite._point.add(sprite.origin.x, sprite.origin.y);
					sprite._matrix.translate(sprite._point.x, sprite._point.y);
			
					if (sprite.isPixelPerfectRender(sprite.camera))
					{
						sprite._matrix.tx = Math.floor(sprite._matrix.tx);
						sprite._matrix.ty = Math.floor(sprite._matrix.ty);
					}
			
					//camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
					if (FlxG.renderBlit)
					{

					}
					else
					{
						var isColored = (sprite.colorTransform != null && sprite.colorTransform.hasRGBMultipliers());
						var hasColorOffsets:Bool = (sprite.colorTransform != null && sprite.colorTransform.hasRGBAOffsets());
			
						var drawItem = new FlxDrawQuadsItem();
						drawItem.graphics = sprite.frame.parent;
						drawItem.antialiasing = sprite.antialiasing;
						drawItem.colored = isColored;
						drawItem.hasColorOffsets = hasColorOffsets;
						drawItem.blending = FlxDrawBaseItem.blendToInt(sprite.blend);
						drawItem.blend = sprite.blend;
						drawItem.shader = sprite.shader;
						//var drawItem = startQuadBatch(sprite.frame.parent, isColored, hasColorOffsets, sprite.blend, sprite.antialiasing, sprite.shader);
						drawItem.addQuad(sprite.frame, sprite._matrix, sprite.colorTransform);
						quads.push(drawItem);
					}
				}

				depthMap.graphics.clear();
				depthBitmap.fillRect(depthBitmap.rect, 0xFF000000);
				

				for (quad in quads)
				{
					var shader = quad.shader != null ? quad.shader : quad.graphics.shader;
					shader.bitmap.input = quad.graphics.bitmap;
					shader.bitmap.filter = (camera.antialiasing || quad.antialiasing) ? LINEAR : NEAREST;
					shader.alpha.value = quad.alphas;

					if (quad.colored || quad.hasColorOffsets)
					{
						shader.colorMultiplier.value = quad.colorMultipliers;
						shader.colorOffset.value = quad.colorOffsets;
					}

					quad.setParameterValue(shader.hasTransform, true);
					quad.setParameterValue(shader.hasColorTransform, quad.colored || quad.hasColorOffsets);

					#if (openfl > "8.7.0")
					depthMap.graphics.overrideBlendMode(quad.blend);
					#end
					depthMap.graphics.beginShaderFill(shader);
					depthMap.graphics.drawQuads(quad.rects, null, quad.transforms);

					depthBitmap.draw(depthMap);
				}
				depthSpr.loadGraphic(depthBitmap);
				
			}



			//trace(quads);

			for (quad in quads)
			{
				quad.dispose();
				quad = null;
			}
			
		}
	 */
}
