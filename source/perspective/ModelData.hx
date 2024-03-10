package perspective;

typedef ModelData = 
{
    var vertices:Array<StripVertex>;
    var indices:Array<Int>;
    var mtl:Material;

    var _vertInds:Array<Int>;
    var _uvInds:Array<Int>;
    var _normalInds:Array<Int>;
}

typedef Material = 
{
    var name:String;
    var ?diffuseTexture:String;
    var ?normalTexture:String;
    var ?specularTexture:String;
    var ?diffuseColor:Array<Float>;
    var ?ambientColor:Array<Float>;
    var ?specularColor:Array<Float>;
    var ?specularExponent:Float;
    var ?alpha:Float;
}