package aze.display;

import aze.display.TileLayer;
import aze.display.TileSprite;

/**
 * Animated tile for TileLayer
 * @author Philippe / http://philippe.elsass.me
 */
class TileClip extends TileSprite
{
	public var onComplete:TileClip->Void;

	public var frames:Array<Int>;
	public var fps:Int;
	public var loop:Bool;
	var time:Int;
	var prevFrame:Int;

	public function new(tile:String, fps = 18)
	{
		super(tile);
		this.fps = fps;
		animated = loop = true;
		time = 0;
		prevFrame = -1;
	}

	override function init(layer:TileLayer):Void
	{
		this.layer = layer;
		frames = layer.tilesheet.getAnim(tile);
		setIndice(frames[0]);
		size = layer.tilesheet.getSize(indice);
	}

	override function step(elapsed:Int)
	{
		time += elapsed;
		var newFrame = currentFrame;
		if (newFrame == prevFrame) return;
		var looping = newFrame < prevFrame;
		prevFrame = newFrame;
		if (looping)
		{
			if (!loop) 
			{
				animated = false;
				currentFrame = totalFrames - 1;
			}
			if (onComplete != null) onComplete(this);
		}
		else setIndice(frames[newFrame]);
	}

	public function play() 
	{ 
		if (!animated) 
		{
			animated = true;
			if (currentFrame == totalFrames - 1)
			{
				currentFrame = 0;
				prevFrame = -1;
			}
		}
	}
	public function stop() { animated = false; }

	public var currentFrame(get_currentFrame, set_currentFrame):Int;

	function get_currentFrame():Int 
	{
		var frame:Int = Math.floor((time / 1000) * fps);
		return frame % frames.length;
	}
	function set_currentFrame(value:Int):Int 
	{
		if (value >= totalFrames) value = totalFrames - 1;
		time = Math.floor(1000 * value / fps);
		return value;
	}

	public var totalFrames(get_totalFrames, null):Int;

	inline function get_totalFrames():Int
	{
		return frames.length;
	}
}
