package perspective;

#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.FlxG;
import lime.utils.Assets;
using StringTools;

/**
 * Simple .obj file loader for 3D models.
 */
class OBJLoader
{
    /**
     * Loads in a .obj file and creates an array of model data which can be applied to a `FlxPerspectiveStrip`,
     * the file extension is not required and will automatically load in an mtl file if there is one found.
     * @param path The path the file will be loaded from
     * @param flipTextureY Flips the texture coorindates of the model, some models may need their texture's flipped to look correct
     */
    public static function loadFromAssets(path:String, ?flipTextureY:Bool = false)
    {
        var modelDataGroup:Array<ModelData> = [];

        //get paths
        var objPath:String = path;
        if (!path.endsWith(".obj"))
        {
            objPath = objPath + ".obj"; //add extension if not there
        }
        var folderPath = "";
        var folderItems = path.split("/");
        for (i in 0...folderItems.length-1)
            folderPath += folderItems[i] + "/"; //construct path

        if (!Assets.exists(objPath))
        {
            FlxG.log.warn(".obj file at :" + path + " does not exist!");
            return modelDataGroup;
        }
           

        var objData = Assets.getText(objPath);
        var mtlData:String = null;
        for (l in objData.split("\n")) //find mtl file name
        {
            if (l.startsWith("mtllib "))
            {
                var mtlName = l.substring(7, l.length).trim();
                if (Assets.exists(folderPath+mtlName))
                    mtlData = Assets.getText(folderPath+mtlName);
                break; //should be near the top so wont loop for long
            }
        }

        modelDataGroup = loadString(objData, mtlData, flipTextureY);

        return modelDataGroup;
    }

    #if sys
    /**
     * Loads in a .obj file and creates an array of model data which can be applied to a `FlxPerspectiveStrip`,
     * the file extension is not required and will automatically load in an mtl file if there is one found.
     * @param path The path the file will be loaded from
     * @param flipTextureY Flips the texture coorindates of the model, some models may need their texture's flipped to look correct
     */
    public static function loadFromFile(path:String, ?flipTextureY:Bool = false)
    {
        var modelDataGroup:Array<ModelData> = [];

        //get paths
        var objPath:String = path;
        if (!path.endsWith(".obj"))
        {
            objPath = objPath + ".obj"; //add extension if not there
        }
        var folderPath = "";
        var folderItems = path.split("/");
        for (i in 0...folderItems.length-1)
            folderPath += folderItems[i] + "/";


        if (!FileSystem.exists(objPath))
        {
            FlxG.log.warn(".obj file at :" + path + " does not exist!");
            return modelDataGroup;
        }
            
        var objData = File.getContent(objPath);
        var mtlData:String = null;
        for (l in objData.split("\n")) //find mtl file name
        {
            if (l.startsWith("mtllib "))
            {
                var mtlName = l.substring(7, l.length).trim();
                if (FileSystem.exists(folderPath+mtlName))
                    mtlData = File.getContent(folderPath+mtlName);
                break; //should be near the top so wont loop for long
            }
        }

        modelDataGroup = loadString(objData, mtlData, flipTextureY);

        return modelDataGroup;
    }
    #end


    /**
     * Creates a group of model data using the string data of a .obj file.
     * @param data The .obj file string data
     * @param mtlData The .mtl file string data (optional)
     * @param flipTextureY Flips the texture coorindates of the model, some models may need their texture's flipped to look correct
     */
    public static function loadString(data:String, ?mtlData:String, ?flipTextureY:Bool = false)
    {
        var curModelData:ModelData = {vertices: [], indices: [], mtl: {name: ""}, _vertInds: [], _uvInds: [], _normalInds: []};
        var modelDataGroup:Array<ModelData> = [];
        if (mtlData != null)
            modelDataGroup = loadMTLFromString(mtlData);

        var _verts:Array<Array<Float>> = [];
        var _uvs:Array<Array<Float>> = [];
        var _normals:Array<Array<Float>> = [];

        var lines = data.split("\n");

        for (line in lines)
        {
            var lineData = line.split(" ");
            if (line.startsWith("v "))
            {
                _verts.push([Std.parseFloat(lineData[1]), Std.parseFloat(lineData[2]), Std.parseFloat(lineData[3])]);
            }
            else if (line.startsWith("vt "))
            {
                _uvs.push([Std.parseFloat(lineData[1]), Std.parseFloat(lineData[2])]);
            }
            else if (line.startsWith("vn "))
            {
                _normals.push([Std.parseFloat(lineData[1]), Std.parseFloat(lineData[2]), Std.parseFloat(lineData[3])]);
            }
            else if (line.startsWith("f "))
            {
                
                var v1 = lineData[1].split("/");
                var v2 = lineData[2].split("/");
                var v3 = lineData[3].split("/");


                curModelData._vertInds.push(Std.parseInt(v1[0]));  curModelData._uvInds.push(Std.parseInt(v1[1]));  curModelData._normalInds.push(Std.parseInt(v1[2]));
                curModelData._vertInds.push(Std.parseInt(v2[0]));  curModelData._uvInds.push(Std.parseInt(v2[1]));  curModelData._normalInds.push(Std.parseInt(v2[2]));
                curModelData._vertInds.push(Std.parseInt(v3[0]));  curModelData._uvInds.push(Std.parseInt(v3[1]));  curModelData._normalInds.push(Std.parseInt(v3[2]));

                if (lineData[4] != null) //quad
                {
                    var v4 = lineData[4].split("/");
                    curModelData._vertInds.push(Std.parseInt(v3[0]));  curModelData._uvInds.push(Std.parseInt(v3[1]));  curModelData._normalInds.push(Std.parseInt(v3[2]));
                    curModelData._vertInds.push(Std.parseInt(v4[0]));  curModelData._uvInds.push(Std.parseInt(v4[1]));  curModelData._normalInds.push(Std.parseInt(v4[2]));
                    curModelData._vertInds.push(Std.parseInt(v1[0]));  curModelData._uvInds.push(Std.parseInt(v1[1]));  curModelData._normalInds.push(Std.parseInt(v1[2]));
                    
                }
            }
            else if (line.startsWith("usemtl "))
            {
                var name = lineData[1];
                var foundExisting = false;
                for (model in modelDataGroup) //check if already exists
                {
                    if (model.mtl.name == name)
                    {
                        //trace('found existing: ' + name);
                        foundExisting = true;
                        curModelData = model;
                    }
                }

                if (!foundExisting) //create new group in case there is no mtl file
                {
                    //trace('made new model data: ' + name);
                    var md = {vertices: [], indices: [], mtl: {name: name}, _vertInds: [], _uvInds: [], _normalInds: []};
                    modelDataGroup.push(md);
                    curModelData = md;
                }
            }
        }

        for (model in modelDataGroup)
        {
            for (i in 0...model._vertInds.length)
            {
                var vertex:StripVertex = 
                {
                    x: _verts[model._vertInds[i]-1][0]*100, //scale up to match better
                    y: _verts[model._vertInds[i]-1][1]*100,
                    z: _verts[model._vertInds[i]-1][2]*100,
    
                    uvX: _uvs[model._uvInds[i]-1][0],
                    uvY: flipTextureY ? (0-_uvs[model._uvInds[i]-1][1])+1 : _uvs[model._uvInds[i]-1][1],
    
                    normalX: _normals[model._normalInds[i]-1][0],
                    normalY: _normals[model._normalInds[i]-1][1],
                    normalZ: _normals[model._normalInds[i]-1][2],
                }
                //trace(vertex);
                model.vertices.push(vertex);
                model.indices.push(i);
            }
        }


        //trace(modelData.vertices.length);
        //trace(modelData.indices.length);

        return modelDataGroup;
    }

    /**
     * Creates a group of model data and applies the material using the string data of a .mtl file.
     * @param mtlData The .mtl file string data
     */
    public static function loadMTLFromString(mtlData:String)
    {
        var modelDataGroup:Array<ModelData> = [];
        var curModelData:ModelData = null;

        var lines = mtlData.split("\n");

        for (line in lines)
        {
            var lineData = line.split(" ");
            if (line.startsWith("newmtl ")) //new material
            {
                var name = line.substring(7, line.length);
                var md = {vertices: [], indices: [], mtl: {name: name}, _vertInds: [], _uvInds: [], _normalInds: []};
                modelDataGroup.push(md);
                curModelData = md;
            }
            else if (line.startsWith("map_Kd ")) //texture
            {
                curModelData.mtl.diffuseTexture = line.substring(7, line.length).trim();
            }
            else if (line.startsWith("norm ")) //normal map
            {
                curModelData.mtl.normalTexture = line.substring(5, line.length).trim();
            }
            else if (line.startsWith("map_Kn "))
            {
                curModelData.mtl.normalTexture = line.substring(7, line.length).trim();
            }
            else if (line.startsWith("map_Ks ")) //specular map
            {
                curModelData.mtl.specularTexture = line.substring(7, line.length).trim();
            }
            else if (line.startsWith("Ka ")) //ambient
            {
                curModelData.mtl.ambientColor = [Std.parseFloat(lineData[1]),Std.parseFloat(lineData[2]),Std.parseFloat(lineData[3])];
            }
            else if (line.startsWith("Kd ")) //diffuse
            {
                curModelData.mtl.diffuseColor = [Std.parseFloat(lineData[1]),Std.parseFloat(lineData[2]),Std.parseFloat(lineData[3])];
            }
            else if (line.startsWith("Ks ")) //specular
            {
                curModelData.mtl.specularColor = [Std.parseFloat(lineData[1]),Std.parseFloat(lineData[2]),Std.parseFloat(lineData[3])];
            }
            else if (line.startsWith("Ns ")) //specular expon
            {
                curModelData.mtl.specularExponent = Std.parseFloat(lineData[1]);
            }
            else if (line.startsWith("d ")) //specular expon
            {
                curModelData.mtl.alpha = Std.parseFloat(lineData[1]);
            }
        }
        return modelDataGroup;
    }
}