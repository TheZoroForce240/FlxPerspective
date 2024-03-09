package;

import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.util.FlxGradient;
import perspective.*;

class TestState extends FlxState
{
    override public function create()
    {
        super.create();

        var scene = new FlxScene3D();
        add(scene);

        var wall = new FlxPerspectiveSprite(0, 0, 640);
        wall.loadGraphic(FlxGradient.createGradientBitmapData(1, 720, [FlxColor.LIME, FlxColor.RED]));
        wall.setGraphicSize(1280, 720);
        wall.antialiasing = true;
        wall.updateHitbox();
        wall.screenCenter();
        scene.add(wall);

        var plane:FlxPerspectiveSprite = new FlxPerspectiveSprite(0, 720);
        plane.makeGraphic(1280, 1280);
        plane.antialiasing = true;
        plane.isFloor = true;
        plane.scale.y = 0;
        plane.updateHitbox();
        plane.offsetTL = [0, 0, 640, 0];
        plane.offsetTR = [0, 0, 640, 0];
        plane.offsetBL = [0, 0, -640, 0];
        plane.offsetBR = [0, 0, -640, 0];
        scene.add(plane);

        var testObj = new FlxPerspectiveSprite(0, 0, 0);
        testObj.loadGraphic(FlxGraphic.fromClass(GraphicLogo));
        testObj.setGraphicSize(200);
        testObj.updateHitbox();
        testObj.antialiasing = true;
        testObj.screenCenter(X);
        testObj.y = 720-testObj.height;
        scene.add(testObj);

        var cubeN:FlxPerspectiveSprite = new FlxPerspectiveSprite(1000, 520);
        cubeN.makeGraphic(200, 200, FlxColor.RED);
        var cubeS:FlxPerspectiveSprite = new FlxPerspectiveSprite(1000, 520, 200);
        cubeS.makeGraphic(200, 200, FlxColor.GREEN);

        var cubeE:FlxPerspectiveSprite = new FlxPerspectiveSprite(900, 520, 100);
        cubeE.scale.x = 0; cubeE.updateHitbox();
        cubeE.offsetTL = cubeE.offsetBL = [0, 0, 100, 0];
        cubeE.offsetTR = cubeE.offsetBR = [0, 0, -100, 0];
        cubeE.makeGraphic(200, 200, FlxColor.BLUE);

        var cubeW:FlxPerspectiveSprite = new FlxPerspectiveSprite(1100, 520, 100);
        cubeW.scale.x = 0; cubeW.updateHitbox();
        cubeW.offsetTL = cubeW.offsetBL = [0, 0, 100, 0];
        cubeW.offsetTR = cubeW.offsetBR = [0, 0, -100, 0];
        cubeW.makeGraphic(200, 200, FlxColor.PURPLE);

        var cubeTop:FlxPerspectiveSprite = new FlxPerspectiveSprite(1000, 520, 100);
        cubeTop.offsetTL = cubeTop.offsetTR = [0, 0, 100, 0];
        cubeTop.offsetBL = cubeTop.offsetBR = [0, 0, -100, 0];
        cubeTop.makeGraphic(200, 200, FlxColor.ORANGE);
        cubeTop.scale.y = 0; cubeTop.updateHitbox();

        scene.add(cubeN);
        scene.add(cubeS);
        scene.add(cubeE);
        scene.add(cubeW);
        scene.add(cubeTop);

    }


    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        FlxPerspectiveSprite.globalCamera.debugControls(elapsed);
        FlxPerspectiveSprite.globalCamera.updateViewMatrix();

    }
}