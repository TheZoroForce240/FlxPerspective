package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import openfl.geom.Rectangle;
import perspective.*;
import perspective.models.*;

class PlayState extends FlxState
{
	var scene:FlxScene3D;

	override public function create()
	{
		super.create();

		FlxG.cameras.reset(new FlxCameraPerspective()); //required for 3D models to look right

		scene = new FlxScene3D();
		add(scene);

		FlxSprite.defaultAntialiasing = true;

		FlxPerspectiveSprite.globalCamera.cameraStyle = FOLLOW;

		FlxPerspectiveSprite.globalCamera.lookAt.z = 0;

		var wall = new FlxPerspectiveSprite(0, 0, 640);
		wall.loadGraphic(FlxGradient.createGradientBitmapData(1, 720, [FlxColor.LIME, FlxColor.RED]));
		wall.setGraphicSize(1280, 720);
		wall.updateHitbox();
		wall.screenCenter();
		scene.add(wall);

		var floor = new FlxPerspectiveStrip(0, 720, 0);
		floor.isFloor = true;
		floor.repeat = true;
		floor.makeGraphic(100, 100, FlxColor.WHITE);
		floor.pixels.fillRect(new Rectangle(0, 0, 50, 50), 0xFF000000); // make checkerboard
		floor.pixels.fillRect(new Rectangle(50, 50, 50, 50), 0xFF000000);
		floor.addVertex({x: 0, y: 0, z: 640, uvX: 0, uvY: 0});
		floor.addVertex({x: 1280, y: 0, z: 640, uvX: 10, uvY: 0});
		floor.addVertex({x: 0, y: 0, z: -640, uvX: 0, uvY: 10});
		floor.addVertex({x: 0, y: 0, z: -640, uvX: 0, uvY: 10});
		floor.addVertex({x: 1280, y: 0, z: 640, uvX: 10, uvY: 0});
		floor.addVertex({x: 1280, y: 0, z: -640, uvX: 10, uvY: 10});
		floor.indices.push(1);
		floor.indices.push(0);
		floor.indices.push(2);
		floor.indices.push(5);
		floor.indices.push(4);
		floor.indices.push(3);
		scene.add(floor);

		var testObj = new FlxPerspectiveSprite(0, 0, 0);
		testObj.loadGraphic(FlxGraphic.fromClass(GraphicLogo));
		testObj.setGraphicSize(200);
		testObj.updateHitbox();
		testObj.screenCenter(X);
		testObj.y = 520;
		scene.add(testObj);

		var testQuad = new FlxPerspectiveSprite(0, 0, 0);
		testQuad.makeGraphic(200, 200, FlxColor.BLUE);
		testQuad.updateHitbox();
		testQuad.x = 1000;
		testQuad.y = 720 - testQuad.height;
		testQuad.offsetBR[2] = 100;
		testQuad.offsetTR[2] = -100;
		scene.add(testQuad);

		var monkey = new FlxPerspectiveStrip(100, 600);
		monkey.repeat = true;
		monkey.makeGraphic(100, 100, FlxColor.GRAY);
		monkey.applyModelData(OBJLoader.loadFromAssets("assets/models/monkey.obj")[0], true, true);
		monkey.alpha = 0.5;
		scene.add(monkey);

		//var sphere = new FlxPerspectiveStrip(640, 600, -600);
		//sphere.repeat = true;
		//sphere.loadGraphic(FlxGraphic.fromClass(GraphicLogo));
		//sphere.applyModelData(OBJLoader.loadFromAssets("assets/models/sphere.obj")[0]);
		//scene.add(sphere);

		
		/*
		var totalVertCount:Int = 0;

		// example of loading a multi textured model
		var wuhuIslandData = OBJLoader.loadFromAssets("assets/models/wuhu island/wuhuIsland.obj");
		for (md in wuhuIslandData)
		{
			var piece = new FlxPerspectiveStrip(0, 5000, 0);
			piece.repeat = true;
			piece.loadGraphic("assets/models/wuhu island/" + md.mtl.diffuseTexture);
			piece.applyModelData(md, true, true);
			scene.add(piece);
			totalVertCount += piece.stripVertices.length;
		}
		trace(totalVertCount / 3);
		*/
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxPerspectiveSprite.globalCamera.debugControls(elapsed);
		FlxPerspectiveSprite.globalCamera.updateViewMatrix();
	}
}
