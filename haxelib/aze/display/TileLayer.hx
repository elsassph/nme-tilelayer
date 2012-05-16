package aze.display;

import flash.geom.Matrix;
import haxe.Public;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.BlendMode;
import nme.display.DisplayObject;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.geom.Rectangle;
import nme.Lib;

/**
 * A little wrapper of NME's Tilesheet rendering (for native platform)
 * and using Bitmaps for Flash platform.
 * Features basic containers (TileGroup) and spritesheets animations.
 * @author Philippe / http://philippe.elsass.me
 */
class TileLayer extends Sprite
{
	public var dom:TileGroup;
	public var useSmoothing:Bool;
	public var useAdditive:Bool;
	public var useAlpha:Bool;
	public var useTransforms:Bool;
	public var useTint:Bool;

	public var tilesheet:TilesheetEx;
	var drawList:DrawList;

	public function new(tilesheet:TilesheetEx, smooth:Bool=false, additive:Bool=false)
	{
		super();
		mouseChildren = false;

		this.tilesheet = tilesheet;
		useSmoothing = smooth;
		useAdditive = additive;
		useAlpha = true;
		useTransforms = true;

		dom = new TileGroup();
		dom.init(this);
		drawList = new DrawList();
	}

	public function render()
	{
		drawList.begin(useTransforms, useAlpha, useTint, useAdditive);
		renderGroup(dom, 0, 0, 0);
		drawList.end();
		#if (flash||js)
		addChild(dom.view);
		#else
		graphics.clear();
		tilesheet.drawTiles(graphics, drawList.list, useSmoothing, drawList.flags);
		#end
	}

	function renderGroup(group:TileGroup, index:Int, gx:Float, gy:Float)
	{
		var list = drawList.list;
		var fields = drawList.fields;
		var offsetTransform = drawList.offsetTransform;
		var offsetRGB = drawList.offsetRGB;
		var offsetAlpha = drawList.offsetAlpha;
		var elapsed = drawList.elapsed;
		gx += group.x;
		gy += group.y;
		#if (flash||js)
		group.view.x = gx;
		group.view.y = gy;
		var blend = useAdditive ? BlendMode.ADD : BlendMode.NORMAL;
		#end

		for(child in group)
		{
			if (Std.is(child, TileGroup)) 
			{
				index = renderGroup(cast child, index, gx, gy);
			}
			else 
			{
				var sprite:TileSprite = cast child;
				if (sprite.animated) sprite.step(elapsed);

				#if (flash||js)
				var m = sprite.view.transform.matrix;
				m.identity();
				m.concat(sprite.matrix);
				m.translate(sprite.x, sprite.y);
				sprite.view.transform.matrix = m;
				sprite.view.blendMode = blend;
				sprite.view.alpha = sprite.alpha;
				// TODO apply tint

				#else
				list[index] = sprite.x + gx;
				list[index+1] = sprite.y + gy;
				list[index+2] = sprite.indice;
				if (offsetTransform > 0) {
					var t = sprite.transform;
					list[index+offsetTransform] = t[0];
					list[index+offsetTransform+1] = t[1];
					list[index+offsetTransform+2] = t[2];
					list[index+offsetTransform+3] = t[3];
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

class TileBase implements Public
{
	var layer:TileLayer;
	var parent:TileGroup;
	var x:Float;
	var y:Float;
	#if (flash||js)
	var view:DisplayObject;
	#end

	function new()
	{
		x = y = 0;
	}

	function init(layer:TileLayer):Void
	{
		this.layer = layer;
		// override to init
	}
}

class TileGroup extends TileBase, implements Public
{
	var children:Array<TileBase>;

	function new()
	{
		super();
		children = new Array<TileBase>();
		#if (flash||js)
		view = new Sprite();
		#end
	}

	override function init(layer:TileLayer):Void
	{
		this.layer = layer;
		initChildren();
	}

	function initChild(item:TileBase)
	{
		item.parent = this;
		if (layer != null && item.layer == null) 
			item.init(layer);
	}

	function initChildren()
	{
		for(child in children)
			initChild(child);
	}

	inline function indexOf(item:TileBase)
	{
		return Lambda.indexOf(children, item);
	}

	function addChild(item:TileBase)
	{
		#if (flash||js)
		var sprite:Sprite = cast view;
		sprite.addChild(item.view);
		#end
		removeChild(item);
		initChild(item);
		return children.push(item);
	}

	function addChildAt(item:TileBase, index:Int)
	{
		#if (flash||js)
		var sprite:Sprite = cast view;
		sprite.addChildAt(item.view, index);
		#end
		removeChild(item);
		initChild(item);
		children.insert(index, item);
		return index;
	}

	function removeChild(item:TileBase)
	{
		if (item.parent == null) return item;
		if (item.parent != this) {
			trace("Invalid parent");
			return item;
		}
		var index = indexOf(item);
		if (index >= 0) 
		{
			#if (flash||js)
			var sprite:Sprite = cast view;
			sprite.removeChild(item.view);
			#end
			children.splice(index, 1);
			item.parent = null;
		}
		return item;
	}

	function removeChildAt(index:Int)
	{
		#if (flash||js)
		var sprite:Sprite = cast view;
		sprite.removeChildAt(index);
		#end
		var res = children.splice(index, 1);
		res[0].parent = null;
		return res[0];
	}

	function getChildIndex(item:TileBase)
	{
		return indexOf(item);
	}

	inline function iterator() { return children.iterator(); }

	var numChildren(get_numChildren, null):Int;
	inline function get_numChildren() { return children.length; }

	var height(get_height, null):Float; // TOFIX incorrect with sub groups
	function get_height():Float 
	{
		if (numChildren == 0) return 0;
		var ymin = 9999.0, ymax = -9999.0;
		for(child in children)
			if (Std.is(child, TileSprite)) {
				var sprite:TileSprite = cast child;
				var h = sprite.height;
				var top = sprite.y - h/2;
				var bottom = top + h;
				if (top < ymin) ymin = top;
				if (bottom > ymax) ymax = bottom;
			}
		return ymax - ymin;
	}

	var width(get_width, null):Float; // TOFIX incorrect with sub groups
	function get_width():Float 
	{
		if (numChildren == 0) return 0;
		var xmin = 9999.0, xmax = -9999.0;
		for(child in children)
			if (Std.is(child, TileSprite)) {
				var sprite:TileSprite = cast child;
				var w = sprite.width;
				var left = sprite.x - w/2;
				var right = left + w;
				if (left < xmin) xmin = left;
				if (right > xmax) xmax = right;
			}
		return xmax - xmin;
	}
}

class TileSprite extends TileBase
{
	public var tile:String;
	var indice:Int;
	var size:Rectangle;
	var animated:Bool;

	var dirty:Bool;
	var _rotation:Float;
	var _scaleX:Float;
	var _scaleY:Float;
	var _mirror:Int;

	#if (cpp||neko)
	var _transform:Array<Float>;
	#else
	var _matrix:Matrix;
	#end

	public var alpha:Float;
	public var r:Float;
	public var g:Float;
	public var b:Float;

	function new(tile:String) 
	{
		super();
		_rotation = 0;
		alpha = _scaleX = _scaleY = 1;
		dirty = true;
		this.tile = tile;
		#if (flash||js)
		view = new Bitmap();
		view.y = -9999;
		#end
	}

	override function init(layer:TileLayer):Void
	{
		this.layer = layer;
		var indices = layer.tilesheet.getAnim(tile);
		setIndice(indices[0]);
		size = layer.tilesheet.getSize(indice);
	}

	function setIndice(index:Int)
	{
		indice = index;
		#if (flash||js)
		var bmp:Bitmap = cast view;
		bmp.bitmapData = layer.tilesheet.getBitmap(index);
		bmp.smoothing = layer.useSmoothing;
		#end
	}

	function step(elapsed:Int)
	{
		// to be overriden
	}

	public var mirror(get_mirror, set_mirror):Int;
	inline function get_mirror():Int { return _mirror; }
	function set_mirror(value:Int):Int 
	{
		if (_mirror != value) {
			_mirror = value;
			dirty = true;
		}
		return value;
	}

	public var rotation(get_rotation, set_rotation):Float;	
	inline function get_rotation():Float { return _rotation; }
	function set_rotation(value:Float):Float 
	{
		if (_rotation != value) {
			_rotation = value;
			dirty = true;
		}
		return value;
	}

	public var scale(get_scale, set_scale):Float;
	inline function get_scale():Float {
		return _scaleX;
	}
	function set_scale(value:Float):Float {
		if (_scaleX != value) {
			_scaleX = _scaleY = value;
			dirty = true;
		}
		return value;
	}

	public var scaleX(get_scaleX, set_scaleX):Float;
	inline function get_scaleX():Float {
		return _scaleX;
	}
	function set_scaleX(value:Float):Float {
		if (_scaleX != value) {
			_scaleX = value;
			dirty = true;
		}
		return value;
	}

	public var scaleY(get_scaleY, set_scaleY):Float;
	inline function get_scaleY():Float {
		return _scaleY;
	}
	function set_scaleY(value:Float):Float {
		if (_scaleY != value) {
			_scaleY = value;
			dirty = true;
		}
		return value;
	}

	#if (cpp||neko)
	public var transform(get_transform, null):Array<Float>;
	function get_transform():Array<Float>
	{
		if (_transform == null) _transform = new Array<Float>();
		if (dirty) 
		{
			dirty = false;
			var dirX:Int = mirror == 1 ? -1 : 1;
			var dirY:Int = mirror == 2 ? -1 : 1;
			if (rotation != 0) {
				var cos = Math.cos(-rotation);
				var sin = Math.sin(-rotation);
				_transform[0] = dirX * cos * scaleX;
				_transform[1] = dirX * sin * scaleY;
				_transform[2] = -dirY * sin * scaleX;
				_transform[3] = dirY * cos * _scaleY;
			}
			else {
				_transform[0] = dirX * scaleX;
				_transform[1] = 0;
				_transform[2] = 0;
				_transform[3] = dirY * _scaleY;
			}
		}
		return _transform;
	}

	#else
	public var matrix(get_matrix, null):Matrix;
	function get_matrix():Matrix 
	{ 
		if (_matrix == null) _matrix = new Matrix();
		if (dirty)
		{
			dirty = false;
			var tileWidth = width / 2;
			var tileHeight = height / 2;
			var m = _matrix;
			m.identity();
			if (layer.useTransforms) {
				m.scale(scaleX, scaleY);
				if (rotation != 0) {
					m.translate(-tileWidth, -tileHeight);
					m.rotate(rotation);
					m.translate(tileWidth, tileHeight);
				}
				if (mirror != 0) {
					if (mirror == 1) { m.scale(-1, 1); m.translate(tileWidth * 2, 0); }
					else if (mirror == 2) { m.scale(1, -1); m.translate(0, tileHeight * 2); }
				}
			}
			m.translate(-tileWidth, -tileHeight);
		}
		return _matrix;
	}
	#end

	public var height(get_height, null):Float;
	inline function get_height():Float {
		return size.height * _scaleY;
	}

	public var width(get_width, null):Float;
	inline function get_width():Float {
		return size.width * _scaleX;
	}
}

class TileClip extends TileSprite, implements Public
{
	var indices:Array<Int>;
	var fps:Int;
	var time:Int;

	function new(tile:String, fps = 18)
	{
		super(tile);
		this.fps = fps;
		this.animated = true;
		time = 0;
	}

	override function init(layer:TileLayer):Void
	{
		this.layer = layer;
		indices = layer.tilesheet.getAnim(tile);
		setIndice(indices[0]);
		size = layer.tilesheet.getSize(indice);
	}

	override function step(elapsed:Int)
	{
		time += elapsed;
		setIndice(indices[currentFrame]);
	}

	function play() { animated = true; }
	function stop() { animated = false; }

	var currentFrame(get_currentFrame, set_currentFrame):Int;

	function get_currentFrame():Int 
	{
		var frame:Int = Math.floor((time / 1000) * fps);
		return frame % indices.length;
	}
	function set_currentFrame(value:Int):Int 
	{
		time = cast 1000 * value / fps;
		return value;
	}
}

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

	function new() 
	{
		list = new Array<Float>();
		elapsed = 0;
	}

	function begin(useTransforms:Bool, useAlpha:Bool, useTint:Bool, useAdditive:Bool) 
	{
		#if (cpp||neko)
		flags = 0;
		fields = 3;
		if (useTransforms) {
			offsetTransform = fields;
			fields += 4;
			flags |= neash.display.Graphics.TILE_TRANS_2x2;
		}
		else offsetTransform = 0;
		if (useTint) {
			offsetRGB = fields; 
			fields+=3; 
			flags |= neash.display.Graphics.TILE_RGB;
		}
		else offsetRGB = 0;
		if (useAlpha) {
			offsetAlpha = fields; 
			fields++; 
			flags |= neash.display.Graphics.TILE_ALPHA;
		}
		else offsetAlpha = 0;
		if (useAdditive) flags |= neash.display.Graphics.TILE_BLEND_ADD;
		#end

		index = 0;
		if (time > 0) {
			var t = Lib.getTimer();
			elapsed = cast Math.min(67, t - time);
			time = t;
		}
		else time = Lib.getTimer();
	}

	function end()
	{
		if (list.length > index) 
			list.splice(index, list.length - index);
	}
}

interface TilesheetEx
{
	function getAnim(name:String):Array<Int>;
	function getSize(indice:Int):nme.geom.Rectangle;

	#if (flash||js)
	function getBitmap(indice:Int):BitmapData;
	#else
	function drawTiles(graphics:Graphics, tileData:Array<Float>, smooth:Bool = false, flags:Int = 0):Void;
	#end
}

