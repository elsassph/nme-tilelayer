package aze.display.behaviours;

import aze.display.TileGroup;
import aze.display.TileLayer;
import aze.display.TileSprite;

/**
 * Controls transformations of a TileGroup:
 * - create a TileGroupTransform for a TileGroup you want to manipulate,
 * - each TileSprite child will have a corresponding TileSpriteProxy,
 * - you can modify the TileGroupTransform's and/or a proxy's transforms,
 * - then call .update() to apply the combined transforms to the children.
 * @author Philippe / http://philippe.elsass.me
 */
class TileGroupTransform
{
	public var rotation:Float;
	public var scale:Float;
	public var alpha:Float;
	public var proxies:Array<TileSpriteProxy>;

	public function new(group:TileGroup) 
	{
		rotation = 0.0;
		scale = alpha = 1.0;
		proxies = [];

		for (child in group)
		{
			if (Std.is(child, TileSprite))
				proxies.push(new TileSpriteProxy(cast child));
		}
	}

	/**
	 * Transform the group's children, combining the proxies transforms
	 */
	public function update() 
	{
		var cos = Math.cos(-rotation);
		var sin = Math.sin(-rotation);
		for (proxy in proxies)
		{
			var sprite = proxy.sprite;
			sprite.x = (cos * proxy.x + sin * proxy.y) * scale;
			sprite.y = (-sin * proxy.x + cos * proxy.y) * scale;
			sprite.rotation = proxy.rotation + rotation;
			sprite.scaleX = proxy.scaleX * scale;
			sprite.scaleY = proxy.scaleY * scale;
			sprite.alpha = proxy.alpha * alpha;
		}
	}

	/**
	 * Register an additional TileSprite
	 */
	public function addProxy(sprite:TileSprite)
	{
		proxies.push(new TileSpriteProxy(sprite));
	}

	/**
	 * @return a specify TileSprite's proxy
	 */
	public function getProxy(sprite:TileSprite) 
	{
		for (proxy in proxies)
			if (proxy.sprite == sprite) return proxy;
		return null;
	}
}

/**
 * A TileSprite shadow copy of its transforms for use by behaviours
 */
class TileSpriteProxy implements haxe.Public
{
	var sprite:TileSprite;
	var x:Float;
	var y:Float;
	var rotation:Float;
	var scaleX:Float;
	var scaleY:Float;
	var alpha:Float;
	var tag:Float;

	function new(sprite:TileSprite)
	{
		this.sprite = sprite;
		x = sprite.x;
		y = sprite.y;
		rotation = sprite.rotation;
		scaleX = sprite.scaleX;
		scaleY = sprite.scaleY;
		alpha = sprite.alpha;
	}
}
