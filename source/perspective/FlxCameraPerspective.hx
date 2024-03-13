package perspective;

import perspective.graphics.FlxDrawTrianglesItemPerspective;
import flixel.FlxG;
import flixel.FlxCamera;
import openfl.display.TriangleCulling;
import openfl.geom.ColorTransform;
import flixel.graphics.FlxGraphic;
import flixel.graphics.tile.FlxDrawBaseItem;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxShader;
import openfl.display.BlendMode;

using flixel.util.FlxColorTransformUtil;

/**
 * An edited version of `FlxCamera` to enable triangle culling and change the triangle bounds check.
 * Use this when using `FlxPerspectiveStrip`, otherwise you might get rendering issues!
 */
class FlxCameraPerspective extends FlxCamera
{
	public var cullingMode:TriangleCulling = TriangleCulling.POSITIVE;

	public var boundsDistance:Float = 100000;

	override public function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>,
			?position:FlxPoint, ?blend:BlendMode, repeat:Bool = false, smoothing:Bool = false, ?transform:ColorTransform, ?shader:FlxShader):Void
	{
		if (FlxG.renderBlit)
		{
			if (position == null)
				position = FlxCamera.renderPoint.set();

			_bounds.set(-boundsDistance, -boundsDistance, boundsDistance*2, boundsDistance*2);

			var verticesLength:Int = vertices.length;
			var currentVertexPosition:Int = 0;

			var tempX:Float, tempY:Float;
			var i:Int = 0;
			var bounds = FlxCamera.renderRect.set();
			FlxCamera.drawVertices.splice(0, FlxCamera.drawVertices.length);

			while (i < verticesLength)
			{
				tempX = position.x + vertices[i];
				tempY = position.y + vertices[i + 1];

				FlxCamera.drawVertices[currentVertexPosition++] = tempX;
				FlxCamera.drawVertices[currentVertexPosition++] = tempY;

				if (i == 0)
				{
					bounds.set(tempX, tempY, 0, 0);
				}
				else
				{
					FlxDrawTrianglesItem.inflateBounds(bounds, tempX, tempY);
				}

				i += 2;
			}

			position.putWeak();

			if (!_bounds.overlaps(bounds))
			{
				FlxCamera.drawVertices.splice(FlxCamera.drawVertices.length - verticesLength, verticesLength);
			}
			else
			{
				FlxCamera.trianglesSprite.graphics.clear();
				FlxCamera.trianglesSprite.graphics.beginBitmapFill(graphic.bitmap, null, repeat, smoothing);
				FlxCamera.trianglesSprite.graphics.drawTriangles(FlxCamera.drawVertices, indices, uvtData, cullingMode);
				FlxCamera.trianglesSprite.graphics.endFill();

				// TODO: check this block of code for cases, when zoom < 1 (or initial zoom?)...
				if (_useBlitMatrix)
					_helperMatrix.copyFrom(_blitMatrix);
				else
				{
					_helperMatrix.identity();
					_helperMatrix.translate(-viewMarginLeft, -viewMarginTop);
				}

				buffer.draw(FlxCamera.trianglesSprite, _helperMatrix);
				#if FLX_DEBUG
				if (FlxG.debugger.drawDebug)
				{
					var gfx:Graphics = FlxSpriteUtil.flashGfx;
					gfx.clear();
					gfx.lineStyle(1, FlxColor.BLUE, 0.5);
					gfx.drawTriangles(drawVertices, indices);
					buffer.draw(FlxSpriteUtil.flashGfxSprite, _helperMatrix);
				}
				#end
				// End of TODO...
			}

			bounds.put();
		}
		else
		{
			_bounds.set(-boundsDistance, -boundsDistance, boundsDistance*2, boundsDistance*2);
			var isColored:Bool = (colors != null && colors.length != 0);

			#if !flash
			var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
			isColored = isColored || (transform != null && transform.hasRGBMultipliers());
			var drawItem:FlxDrawTrianglesItem = startTrianglesBatch(graphic, smoothing, isColored, blend, hasColorOffsets, shader);
			drawItem.addTriangles(vertices, indices, uvtData, colors, position, _bounds, transform);
			#else
			var drawItem:FlxDrawTrianglesItem = startTrianglesBatch(graphic, smoothing, isColored, blend);
			drawItem.addTriangles(vertices, indices, uvtData, colors, position, _bounds);
			#end
		}
	}

	/**
	 * Last draw triangles item
	 */
	var _headTrianglesPerspective:FlxDrawTrianglesItemPerspective;

	/**
	 * Draw triangles stack items that can be reused
	 */
	static var _storageTrianglesHeadPerspective:FlxDrawTrianglesItemPerspective;

	 @:noCompletion
	 override public function startTrianglesBatch(graphic:FlxGraphic, smoothing:Bool = false, isColored:Bool = false, ?blend:BlendMode, ?hasColorOffsets:Bool, ?shader:FlxShader):FlxDrawTrianglesItem
	 {
		 var blendInt:Int = FlxDrawBaseItem.blendToInt(blend);
 
		 if (_currentDrawItem != null
			 && _currentDrawItem.type == FlxDrawItemType.TRIANGLES
			 && _headTrianglesPerspective.graphics == graphic
			 && _headTrianglesPerspective.antialiasing == smoothing
			 && _headTrianglesPerspective.colored == isColored
			 && _headTrianglesPerspective.blending == blendInt
			 #if !flash
			 && _headTrianglesPerspective.hasColorOffsets == hasColorOffsets
			 && _headTrianglesPerspective.shader == shader
			 #end
			 )
		 {
			 return _headTrianglesPerspective;
		 }
 
		 return getNewDrawTrianglesItem(graphic, smoothing, isColored, blend, hasColorOffsets, shader);
	 }

	@:noCompletion
	override public function getNewDrawTrianglesItem(graphic:FlxGraphic, smoothing:Bool = false, isColored:Bool = false, ?blend:BlendMode, ?hasColorOffsets:Bool, ?shader:FlxShader):FlxDrawTrianglesItem
	{
		var itemToReturn:FlxDrawTrianglesItemPerspective = null;
		var blendInt:Int = FlxDrawBaseItem.blendToInt(blend);

		if (_storageTrianglesHeadPerspective != null)
		{
			itemToReturn = _storageTrianglesHeadPerspective;
			var newHead:FlxDrawTrianglesItemPerspective = itemToReturn.nextTypedPerspective;
			itemToReturn.reset();
			_storageTrianglesHeadPerspective = newHead;
		}
		else
		{
			itemToReturn = new FlxDrawTrianglesItemPerspective();
		}

		itemToReturn.graphics = graphic;
		itemToReturn.antialiasing = smoothing;
		itemToReturn.colored = isColored;
		itemToReturn.blending = blendInt;
		itemToReturn.culling = cullingMode;
		#if !flash
		itemToReturn.hasColorOffsets = hasColorOffsets;
		itemToReturn.shader = shader;
		#end

		itemToReturn.nextTypedPerspective = _headTrianglesPerspective;
		_headTrianglesPerspective = itemToReturn;

		if (_headOfDrawStack == null)
		{
			_headOfDrawStack = itemToReturn;
		}

		if (_currentDrawItem != null)
		{
			_currentDrawItem.next = itemToReturn;
		}

		_currentDrawItem = itemToReturn;

		return itemToReturn;
	}


	@:allow(flixel.system.frontEnds.CameraFrontEnd)
	override function clearDrawStack():Void
	{
		var currTiles = _headTiles;
		var newTilesHead;

		while (currTiles != null)
		{
			newTilesHead = currTiles.nextTyped;
			currTiles.reset();
			currTiles.nextTyped = FlxCamera._storageTilesHead;
			FlxCamera._storageTilesHead = currTiles;
			currTiles = newTilesHead;
		}

		var currTriangles:FlxDrawTrianglesItemPerspective = _headTrianglesPerspective;
		var newTrianglesHead:FlxDrawTrianglesItemPerspective;

		while (currTriangles != null)
		{
			newTrianglesHead = currTriangles.nextTypedPerspective;
			currTriangles.reset();
			currTriangles.nextTypedPerspective = _storageTrianglesHeadPerspective;
			_storageTrianglesHeadPerspective = currTriangles;
			currTriangles = newTrianglesHead;
		}

		_currentDrawItem = null;
		_headOfDrawStack = null;
		_headTiles = null;
		_headTriangles = null;
		_headTrianglesPerspective = null;
	}
}