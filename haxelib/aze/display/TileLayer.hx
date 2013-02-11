package aze.display;

import browser.geom.Point;
import haxe.Public;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.BlendMode;
import nme.display.DisplayObject;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.Lib;

/**
 * A little wrapper of NME's Tilesheet rendering (for native platform)
 * and using Bitmaps for Flash platform.
 * Features basic containers (TileGroup) and spritesheets animations.
 * @author Philippe / http://philippe.elsass.me
 */
class TileLayer extends TileGroup
{
	static var synchronizedElapsed:Float;

	public var view:Sprite;
	public var useSmoothing:Bool;
	public var useAdditive:Bool;
	public var useAlpha:Bool;
	public var useTransforms:Bool;
	public var useTint:Bool;

	public var tilesheet:TilesheetEx;
	var drawList:DrawList;

	public function new(tilesheet:TilesheetEx, smooth:Bool=true, additive:Bool=false)
	{
		super(this);

		view = new Sprite();
		view.mouseEnabled = false;
		view.mouseChildren = false;

		this.tilesheet = tilesheet;
		useSmoothing = smooth;
		useAdditive = additive;
		useAlpha = true;
		useTransforms = true;

		drawList = new DrawList();
	}

	public function render(?elapsed:Int)
	{
		drawList.begin(elapsed == null ? 0 : elapsed, useTransforms, useAlpha, useTint, useAdditive);
		renderGroup(this, 0, 0, 0);
		drawList.end();
		#if flash
		view.addChild(container);
		#else
		view.graphics.clear();
		tilesheet.drawTiles(view.graphics, drawList.list, useSmoothing, drawList.flags);
		#end
		return drawList.elapsed;
	}

	function renderGroup(group:TileGroup, index:Int, gx:Float, gy:Float)
	{
		var list = drawList.list;
		var fields = drawList.fields;
		var offsetTransform = drawList.offsetTransform;
		var offsetRGB = drawList.offsetRGB;
		var offsetAlpha = drawList.offsetAlpha;
		var elapsed = drawList.elapsed;

		#if flash
		group.container.x = gx + group.x;
		group.container.y = gy + group.y;
		var blend = useAdditive ? BlendMode.ADD : BlendMode.NORMAL;
		#else
		gx += group.x;
		gy += group.y;
		#end
		
		var n = group.numChildren;
		for(i in 0...n)
		{
			var child = group.children[i];
			if (child.animated) child.step(elapsed);

			#if (flash||js)
			var group:TileGroup = Std.is(child, TileGroup) ? cast child : null;
			#else
			if (!child.visible) 
				continue;
			var group:TileGroup = cast child;
			#end

			if (group != null) 
			{
				index = renderGroup(group, index, gx, gy);
			}
			else 
			{
				var sprite:TileSprite = cast child;

				#if flash
				if (sprite.visible && sprite.alpha > 0.0)
				{
					var m = sprite.bmp.transform.matrix;
					m.identity();
					m.concat(sprite.matrix);
					m.translate(sprite.x, sprite.y);
					sprite.bmp.transform.matrix = m;
					sprite.bmp.blendMode = blend;
					sprite.bmp.alpha = sprite.alpha;
					sprite.bmp.visible = true;
					// TODO apply tint
				}
				else sprite.bmp.visible = false;

				#else
				if (sprite.alpha <= 0.0) continue;
				list[index+2] = sprite.indice;
				
				if (sprite.offset != null) 
				{
					var off:Point = sprite.offset;					
					if (offsetTransform > 0) {
						var t = sprite.transform;
						list[index] = sprite.x - off.x * t[0] - off.y * t[1] + gx;
						list[index+1] = sprite.y - off.x * t[2] - off.y * t[3] + gy;
						list[index+offsetTransform] = t[0];
						list[index+offsetTransform+1] = t[1];
						list[index+offsetTransform+2] = t[2];
						list[index+offsetTransform+3] = t[3];
					}
					else {
						list[index] = sprite.x - off.x + gx;
						list[index+1] = sprite.y - off.y + gy;
					}
				}
				else {
					list[index] = sprite.x + gx;
					list[index+1] = sprite.y + gy;
					if (offsetTransform > 0) {
						var t = sprite.transform;
						list[index+offsetTransform] = t[0];
						list[index+offsetTransform+1] = t[1];
						list[index+offsetTransform+2] = t[2];
						list[index+offsetTransform+3] = t[3];
					}
				}
				
				if (offsetRGB > 0) {
					list[index+offsetRGB] = sprite.r;
					list[index+offsetRGB+1] = sprite.g;
					list[index+offsetRGB+2] = sprite.b;
				}
				if (offsetAlpha > 0) list[index+offsetAlpha] = sprite.alpha;
				index += fields;
				#end
			}
		}
		drawList.index = index;
		return index;
	}
}


/**
 * @private base tile type
 */
class TileBase implements Public
{
	var layer:TileLayer;
	var parent:TileGroup;
	var x:Float;
	var y:Float;
	var animated:Bool;
	var visible:Bool;

	function new(layer:TileLayer)
	{
		this.layer = layer;
		x = y = 0.0;
		visible = true;
	}

	function init(layer:TileLayer):Void
	{
		this.layer = layer;
	}

	function step(elapsed:Int)
	{
	}

	#if flash
	function getView():DisplayObject { return null; }
	#end
}


/**
 * @private render buffer
 */
class DrawList implements Public
{
	var list:Array<Float>;
	var index:Int;
	var fields:Int;
	var offsetTransform:Int;
	var offsetRGB:Int;
	var offsetAlpha:Int;
	var flags:Int;
	var time:Int;
	var elapsed:Int;
	var runs:Int;

	function new() 
	{
		list = new Array<Float>();
		elapsed = 0;
		runs = 0;
	}

	function begin(elapsed:Int, useTransforms:Bool, useAlpha:Bool, useTint:Bool, useAdditive:Bool) 
	{
		#if !flash
		flags = 0;
		fields = 3;
		if (useTransforms) {
			offsetTransform = fields;
			fields += 4;
			flags |= Graphics.TILE_TRANS_2x2;
		}
		else offsetTransform = 0;
		if (useTint) {
			offsetRGB = fields; 
			fields+=3; 
			flags |= Graphics.TILE_RGB;
		}
		else offsetRGB = 0;
		if (useAlpha) {
			offsetAlpha = fields; 
			fields++; 
			flags |= Graphics.TILE_ALPHA;
		}
		else offsetAlpha = 0;
		if (useAdditive) flags |= Graphics.TILE_BLEND_ADD;
		#end

		if (elapsed > 0) this.elapsed = elapsed;
		else
		{
			index = 0;
			if (time > 0) {
				var t = Lib.getTimer();
				this.elapsed = cast Math.min(67, t - time);
				time = t;
			}
			else time = Lib.getTimer();
		}
	}

	function end()
	{
		if (list.length > index) 
		{
			if (++runs > 60) 
			{
				list.splice(index, list.length - index); // compact buffer
				runs = 0;
			}
			else
			{
				while (index < list.length)
				{
					list[index + 2] = -2.0; // set invalid ID
					index += fields;
				}
			}
		}
	}
}
