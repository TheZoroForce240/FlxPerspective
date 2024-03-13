# FlxPerspective
3D Rendering in HaxeFlixel by using a modified Vertex shader to transform sprites and triangles into a 3D space.
![](https://github.com/TheZoroForce240/FlxPerspective/blob/main/examples/loop.gif)

## Features
* FlxPerspectiveSprites that can change the Z value and offset the corners to skew the sprite
* A 3D Camera system that can move and look around the environment (with some built-in debug controls)
* FlxPerspectiveStrips to render triangles and support for loading in 3D models (.obj files)

## Limitations
* No depth testing right now! Sprites will need to be layered manually or will need to be added to a FlxScene3D that attempts to auto layer based on the camera position, its not perfect but its the only option right now.
* Flixel's culling system needed to be turned off for this to work! Frustum culling will hopefully be implemented at some point in the future to fix this.
* A few edited Flixel files are be needed to correctly render 3D models with FlxPerspectiveStrip, this is to enable triangle culling and disable the camera boundary check.

## Planned Features
* Depth testing
* 3D Rotation on sprites/models
* Parenting system for multi-textured 3D models instead of separate pieces
* Frustum culling
* Lighting? Normal/specular mapping maybe?
* Support for more 3D model formats?
* Skeletal animation?

## Example usage

FlxPerspectiveSprite
```haxe
var scene = new FlxScene3D();
add(scene);
                                   //x, y, z
var spr = new FlxPerspectiveSprite(-200, 0, 200);
spr.makeGraphic(200, 200, FlxColor.BLUE);
scene.add(spr);
```

FlxPerspectiveStrip with a 3D Model
```haxe
var sphere = new FlxPerspectiveStrip(0, 600, 0);
sphere.repeat = true;
sphere.loadGraphic(FlxGraphic.fromClass(GraphicLogo));
sphere.applyModelData(OBJLoader.loadFromAssets("assets/models/sphere.obj")[0]); //index 0 because its using a single material
scene.add(sphere);

//example of multi-textured model
var modelData = OBJLoader.loadFromAssets("assets/models/coolmodel.obj");
for (md in modelData)
{
  var piece = new FlxPerspectiveStrip(0, 0, 0);
  piece.repeat = true;
  piece.loadGraphic("assets/models/" + md.mtl.diffuseTexture);
  piece.applyModelData(md, true, true);
  scene.add(piece);
}
```
