package aze.display;

import aze.display.TileLayer;
import aze.display.TileGroup;
import aze.display.TileSprite;
import nme.display.DisplayObject;
import nme.display.Sprite;

/**
 * Tiles container for TileLayer
 * - can contain types compatible with TileSprite or TileGroup
 * - only offers x/y position offset to its content
 * @author Philippe / http://philippe.elsass.me
 */
class TileGroup extends TileBase
{
	public var children:Array<TileBase>;
	#if (flash||js)
	var container:Sprite;
	#end

	public function new()
	{
		super();
		children = new Array<TileBase>();
		#if (flash||js)
		container = new Sprite();
		#end
	}

	override public function init(layer:TileLayer):Void
	{
		this.layer = layer;
		initChildren();
	}

	#if (flash||js)
	override public function getView():DisplayObject { return container; }
	#end

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

	public inline function indexOf(item:TileBase)
	{
		return Lambda.indexOf(children, item);
	}

	public function addChild(item:TileBase)
	{
		#if (flash||js)
		container.addChild(item.getView());
		#end
		removeChild(item);
		initChild(item);
		return children.push(item);
	}

	public function addChildAt(item:TileBase, index:Int)
	{
		#if (flash||js)
		container.addChildAt(item.getView(), index);
		#end
		removeChild(item);
		initChild(item);
		children.insert(index, item);
		return index;
	}

	public function removeChild(item:TileBase)
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
			container.removeChild(item.getView());
			#end
			children.splice(index, 1);
			item.parent = null;
		}
		return item;
	}

	public function removeChildAt(index:Int)
	{
		#if (flash||js)
		container.removeChildAt(index);
		#end
		var res = children.splice(index, 1);
		res[0].parent = null;
		return res[0];
	}

	public function getChildIndex(item:TileBase)
	{
		return indexOf(item);
	}

	public inline function iterator() { return children.iterator(); }

	public var numChildren(get_numChildren, null):Int;
	inline function get_numChildren() { return children.length; }

	public var height(get_height, null):Float; // TOFIX incorrect with sub groups
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

	public var width(get_width, null):Float; // TOFIX incorrect with sub groups
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