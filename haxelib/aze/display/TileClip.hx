package aze.display;

import aze.display.TileLayer;
import aze.display.TileSprite;

/**
 * Animated tile for TileLayer
 * @author Philippe / http://philippe.elsass.me
 */
class TileClip extends TileSprite
{
	public var fps:Int;
	//public var loop:Bool; // TODO
	//public var onComplete:TileClip->Void // TODO
	var indices:Array<Int>;
	var time:Int;

	public function new(tile:String, fps = 18)
	{
		super(tile);
		this.fps = fps;
		animated = true;
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
