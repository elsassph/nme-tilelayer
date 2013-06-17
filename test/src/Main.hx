package ;

import aze.display.behaviours.TileGroupTransform;
import aze.display.TileGroup;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import nme.Assets;
import nme.display.Shape;
import nme.display.Sprite;
import nme.events.Event;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.Lib;

/**
 * ...
 * @author Philippe
 */

class Main extends Sprite 
{
	var inited:Bool;
	var layer:TileLayer;
	var bunny:TileSprite;
	var group:TileGroup;
	var groupTransform:TileGroupTransform;
	var k:Float;

	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;

		var bmp = Assets.getBitmapData("img/wabbit_alpha.png");
		var r:Rectangle = cast bmp.rect.clone();
		var sheet:TilesheetEx = new TilesheetEx(bmp);
		#if flash
		sheet.addDefinition("bunny", r, bmp);
		#else
		sheet.addDefinition("bunny", r, r, new Point(r.width/2, r.height/2));
		#end
		
		layer = new TileLayer(sheet, false);
		addChild(layer.view);
		
		k = 100;
		
		/* COL 1 */
		
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k;
		bunny.y = k;
		layer.addChild(bunny);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k*2;
		bunny.y = k;
		bunny.scale = 2;
		layer.addChild(bunny);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k*3;
		bunny.y = k;
		bunny.scaleX = 2;
		bunny.scaleY = 0.5;
		layer.addChild(bunny);
		
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k;
		bunny.y = k*2;
		bunny.rotation = 0.5;
		layer.addChild(bunny);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k*2;
		bunny.y = k*2;
		bunny.scale = 2;
		bunny.rotation = 0.5;
		layer.addChild(bunny);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k*3;
		bunny.y = k*2;
		bunny.scaleX = 2;
		bunny.scaleY = 0.5;
		bunny.rotation = 0.5;
		layer.addChild(bunny);
		
		/* COL 1 GROUP 1 */
		
		var g = new TileGroup(layer);
		g.y = k * 3;
		layer.addChild(g);
		
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k;
		bunny.y = 0;
		g.addChild(bunny);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k*2;
		bunny.y = 0;
		bunny.scale = 2;
		g.addChild(bunny);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k*3;
		bunny.y = 0;
		bunny.scaleX = 2;
		bunny.scaleY = 0.5;
		g.addChild(bunny);
		
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k;
		bunny.y = k;
		bunny.rotation = 0.5;
		g.addChild(bunny);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k*2;
		bunny.y = k;
		bunny.scale = 2;
		bunny.rotation = 0.5;
		g.addChild(bunny);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k*3;
		bunny.y = k;
		bunny.scaleX = 2;
		bunny.scaleY = 0.5;
		bunny.rotation = 0.5;
		g.addChild(bunny);
		
		/* COL 2 */
		
		var p = new Point( -r.width / 2, -r.height / 2);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k*3+k;
		bunny.y = 0;
		bunny.offset = p;
		layer.addChild(bunny);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k*3+k*2;
		bunny.y = 0;
		bunny.scale = 2;
		bunny.offset = p;
		layer.addChild(bunny);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k*3+k*3;
		bunny.y = 0;
		bunny.scaleX = 2;
		bunny.scaleY = 0.5;
		bunny.offset = p;
		layer.addChild(bunny);
		
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k*3+k;
		bunny.y = k;
		bunny.rotation = 0.5;
		bunny.offset = p;
		layer.addChild(bunny);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k*3+k*2;
		bunny.y = k;
		bunny.scale = 2;
		bunny.rotation = 0.5;
		bunny.offset = p;
		layer.addChild(bunny);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k*3+k*3;
		bunny.y = k;
		bunny.scaleX = 2;
		bunny.scaleY = 0.5;
		bunny.rotation = 0.5;
		bunny.offset = p;
		layer.addChild(bunny);
		
		/* COL 2 GROUP 2 */
		
		g = new TileGroup(layer);
		g.x = k * 5;
		g.y = k * 3;
		layer.addChild(g);
		group = g;
		
		var p = new Point( -r.width / 2, -r.height / 2);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = -k;
		bunny.y = -k;
		bunny.offset = p;
		g.addChild(bunny);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = 0;
		bunny.y = -k;
		bunny.scale = 2;
		bunny.offset = p;
		g.addChild(bunny);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k;
		bunny.y = -k;
		bunny.scaleX = 2;
		bunny.scaleY = 0.5;
		bunny.offset = p;
		g.addChild(bunny);
		
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = -k;
		bunny.y = 0;
		bunny.rotation = 0.5;
		bunny.offset = p;
		g.addChild(bunny);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = 0;
		bunny.y = 0;
		bunny.scale = 2;
		bunny.rotation = 0.5;
		bunny.offset = p;
		g.addChild(bunny);
		var bunny = new TileSprite(layer, "bunny");
		bunny.x = k;
		bunny.y = 0;
		bunny.scaleX = 2;
		bunny.scaleY = 0.5;
		bunny.rotation = 0.5;
		bunny.offset = p;
		g.addChild(bunny);
		
		groupTransform = new TileGroupTransform(g);
		
		
		/* GRID */
		
		var grid:Shape = new Shape();
		for (i in 0...Std.int(stage.stageWidth / k)) 
		{
			grid.graphics.lineStyle(i == 2 ? 4 : 1, 0xff0000, 0.5);
			grid.graphics.moveTo((i+1) * k, 0);
			grid.graphics.lineTo((i+1) * k, stage.stageHeight);
		}
		for (i in 0...Std.int(stage.stageHeight/k)) 
		{
			grid.graphics.lineStyle(i == 2 ? 4 : 1, 0xff0000, 0.5);
			grid.graphics.moveTo(0, (i+1) * k);
			grid.graphics.lineTo(stage.stageWidth, (i+1) * k);
		}
		grid.graphics.drawCircle(k * 5, k * 3, k * 2);
		addChild(grid);
		
		addEventListener(Event.ENTER_FRAME, enterFrame);
	}
	
	private function enterFrame(e:Event):Void 
	{
		var dx = group.x - stage.mouseX;
		var dy = group.y - stage.mouseY;
		var d = Math.sqrt(dx * dx + dy * dy);
		var a = Math.atan2(dy, dx);
		groupTransform.rotation = a;
		groupTransform.scale = Math.max(d, k) / (k * 2);
		groupTransform.update();
		
		layer.render();
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = nme.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
