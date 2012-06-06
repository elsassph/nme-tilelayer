package aze.display;

import aze.display.TileLayer;
import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.Lib;

using StringTools;


// graceful Jeash compatibility
#if js
class Tilesheet { 
	function new(img:BitmapData) {
	}
}
#else
typedef Tilesheet = nme.display.Tilesheet;
#end


/**
 * Sparrow spritesheet parser for TileLayer
 * - supports animations
 * - supports sprite trimming
 * - does NOT support sprite rotation
 * @author Philippe / http://philippe.elsass.me
 */
class SparrowTilesheet extends Tilesheet, implements TilesheetEx
{
	var defs:Array<String>;
	var sizes:Array<Rectangle>;
	var anims:Hash<Array<Int>>;
	#if (flash||js)
	var bmps:Array<BitmapData>;
	#end

	public function new(img:BitmapData, xml:String) 
	{
		super(img);
		
		defs = new Array<String>();
		anims = new Hash<Array<Int>>();
		sizes = new Array<Rectangle>();
		#if (flash||js)
		bmps = new Array<BitmapData>();
		#end

		var ins = new Point(0,0);
		var x = new haxe.xml.Fast( Xml.parse(xml).firstElement() );

		for (texture in x.nodes.SubTexture)
		{
			defs.push(texture.att.name);
			var r = new Rectangle(
				Std.parseInt(texture.att.x), Std.parseInt(texture.att.y),
				Std.parseInt(texture.att.width), Std.parseInt(texture.att.height));

			var s = if (texture.has.frameX) // trimmed
					new Rectangle(
						Std.parseInt(texture.att.frameX), Std.parseInt(texture.att.frameY),
						Std.parseInt(texture.att.frameWidth), Std.parseInt(texture.att.frameHeight));
				else 
					new Rectangle(0,0, r.width, r.height);
			sizes.push(s);

			#if (flash||js)
			var bmp = new BitmapData(cast s.width, cast s.height, true, 0);
			ins.x = -s.left;
			ins.y = -s.top;
			bmp.copyPixels(img, r, ins);
			bmps.push(bmp);
			#else
			addTileRect(r, new Point(s.x + s.width / 2, s.y + s.height / 2));
			#end
		}
	}

	public function getAnim(name:String):Array<Int>
	{
		if (anims.exists(name))
			return anims.get(name);
		var indices = new Array<Int>();
		for (i in 0...defs.length)
		{
			if (defs[i].startsWith(name)) 
				indices.push(i);
		}
		anims.set(name, indices);
		return indices;
	}

	inline public function getSize(indice:Int):Rectangle
	{
		if (indice < sizes.length) return sizes[indice];
		else return new Rectangle();
	}

	#if (flash||js)
	inline public function getBitmap(indice:Int):BitmapData
	{
		return bmps[indice];
	}
	#end
}
