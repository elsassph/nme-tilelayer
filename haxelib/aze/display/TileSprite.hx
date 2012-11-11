package aze.display;

import aze.display.TileLayer;
import nme.geom.Matrix;
import nme.display.Bitmap;
import nme.display.DisplayObject;
import nme.geom.Rectangle;

/**
 * Static tile for TileLayer
 * @author Philippe / http://philippe.elsass.me
 */
class TileSprite extends TileBase
{
	var _tile:String;
	var _indice:Int;
	var size:Rectangle;

	var dirty:Bool;
	var _rotation:Float;
	var _scaleX:Float;
	var _scaleY:Float;
	var _mirror:Int;

	#if !flash
	var _transform:Array<Float>;
	#else
	var _matrix:Matrix;
	public var bmp:Bitmap;
	#end

	public var alpha:Float;
	public var r:Float;
	public var g:Float;
	public var b:Float;

	public function new(tile:String) 
	{
		super();
		_rotation = 0;
		alpha = _scaleX = _scaleY = 1;
		_mirror = 0;
		dirty = true;
		this.tile = tile;
		_indice = -1;
		#if flash
		bmp = new Bitmap();
		bmp.y = -9999; // jeash flicker
		_matrix = new Matrix();
		#else
		_transform = new Array<Float>();
		#end
	}

	override public function init(layer:TileLayer):Void
	{
		this.layer = layer;
		var indices = layer.tilesheet.getAnim(tile);
		indice = indices[0];
		size = layer.tilesheet.getSize(indice);
	}

	#if flash
	override public function getView():DisplayObject { return bmp; }
	#end

	public var tile(get_tile, set_tile):String;
	inline function get_tile():String { return _tile; }
	function set_tile(value:String):String
	{
		if (_tile != value) {
			_tile = value;
			if (layer != null) init(layer); // update visual
		}
		return value;
	}

	public var indice(get_indice, set_indice):Int;
	inline function get_indice():Int { return _indice; }
	function set_indice(value:Int)
	{
		if (_indice != value)
		{
			_indice = value;
			#if flash
			bmp.bitmapData = layer.tilesheet.getBitmap(value);
			bmp.smoothing = layer.useSmoothing;
			#end
		}
		return value;
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
	inline function get_scale():Float { return _scaleX; }
	function set_scale(value:Float):Float 
	{
		if (_scaleX != value) {
			_scaleX = value;
			_scaleY = value;
			dirty = true;
		}
		return value;
	}

	public var scaleX(get_scaleX, set_scaleX):Float;
	inline function get_scaleX():Float { return _scaleX; }
	function set_scaleX(value:Float):Float 
	{
		if (_scaleX != value) {
			_scaleX = value;
			dirty = true;
		}
		return value;
	}

	public var scaleY(get_scaleY, set_scaleY):Float;
	inline function get_scaleY():Float { return _scaleY; }
	function set_scaleY(value:Float):Float 
	{
		if (_scaleY != value) {
			_scaleY = value;
			dirty = true;
		}
		return value;
	}

	public var color(get_color, set_color):Int;
	function get_color():Int 
	{ 
		return Std.int(r * 256.0) << 16
			+ Std.int(g * 256.0) << 8
			+ Std.int(b * 256.0);
	}
	function set_color(value:Int):Int 
	{
		r = (value >> 16) / 255.0;
		g = ((value >> 8) & 0xff) / 255.0;
		b = (value & 0xff) / 255.0;
		return value;
	}

	#if !flash
	public var transform(get_transform, null):Array<Float>;
	function get_transform():Array<Float>
	{
		if (dirty == true) 
		{
			dirty = false;
			var dirX:Int = mirror == 1 ? -1 : 1;
			var dirY:Int = mirror == 2 ? -1 : 1;
			if (rotation != 0) {
				var cos = Math.cos(-rotation);
				var sin = Math.sin(-rotation);
				_transform[0] = dirX * cos * scaleX;
				_transform[1] = dirY * sin * scaleY;
				_transform[2] = -dirX * sin * scaleX;
				_transform[3] = dirY * cos * scaleY;
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
		if (dirty == true)
		{
			dirty = false;
			var tileWidth = width / 2;
			var tileHeight = height / 2;
			var m = _matrix;
			m.identity();
			if (layer.useTransforms) {
				m.scale(scaleX, scaleY);
				if (mirror != 0) {
					if (mirror == 1) { m.scale(-1, 1); m.translate(tileWidth * 2, 0); }
					else if (mirror == 2) { m.scale(1, -1); m.translate(0, tileHeight * 2); }
				}
				if (rotation != 0) {
					m.translate(-tileWidth, -tileHeight);
					m.rotate(rotation);
					m.translate(tileWidth, tileHeight);
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
