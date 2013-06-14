nme-tilelayer
=============

A lightweight and very optimized wrapper over NME's powerful but lowlevel 'drawTiles' which offers the best rendering performance 
(ie. batching) on native platforms.

**See [NME RunnerMark][1] for a sample project using this library.**

 - provides a basic display-list, spritesheet animations, mirroring (tile flipping), scale X/Y,
 - includes a Sparrow spritesheet parser, supporting trimming,
 - uses (and caches computations of) the new drawTiles' transform2x2 for native platforms,
 - uses Bitmaps for Flash target rendering,
 - very optimized memory management, near-zero garbage collection.

**Warning:** TileLayer is a "batching" class so it should be used to display "many elements" - that means you should 
include as many sprites/anims as possible in the spritesheet. Creating many TileLayers is conter-productive, because 
having many textures and not doing batching is inefficient for GPU performance.

Usage
-----
- install the library: type `haxelib install tilelayer` in your terminal
- add `<haxelib name="tilelayer" />` in your nmml

Configure it:

```as3
// sprite sheet
var sheetData = Assets.getText("assets/spritesheet.xml");
var tilesheet = new SparrowTilesheet(Assets.getBitmapData("assets/spritesheet.png"), sheetData);

// you can now load higher/lower resolution textures seamlessly
var tilesheet = new SparrowTilesheet(Assets.getBitmapData("assets/spritesheet@2x.png"), sheetData, 2);
var tilesheet = new SparrowTilesheet(Assets.getBitmapData("assets/spritesheet-low.png"), sheetData, 0.5);

// tile-layer
var layer = new TileLayer(tilesheet); // optional flags: smoothing, additive blendmode
```

Add/manipulate elements as a display list:

```as3
// static tile
var sprite = new TileSprite(layer, "spritename");
layer.addChild(sprite);

// animated tile
var clip = new TileClip(layer, "animname");
clip.loop = false;
layer.addChild(clip);

// tile group (only translation, use the TileGroupTransform behaviour for more)
var group = new TileGroup(layer);
group.addChild(new TileSprite(layer, "othername"));
group.addChild(new TileClip(layer, "yetanother"));
layer.addChild(group);
```
*Note: you can provide* null *as the layer reference, but then Tiles will have a* null *size until 
they are added to the layer's display list.*

Render it:

```as3
// batch it!
addChild(layer.view); // layer is NOT a DisplayObject
layer.render();
```

Tiles Features
--------------

**TileLayer properties**
 - view *(root DisplayObject)*
 - useAlpha *(default true)*
 - useTransforms *(default true)*
 - useSmoothing
 - useAdditive
 - useTint

**TileSprite / TileClip properties**
 - tile (set image)
 - x, y
 - offset (change pivot, relative to center)
 - rotation
 - scale / scaleX / scaleY
 - alpha
 - mirror *(1: horizontal, 2: vertical)*
 - r / g / b (defaults to 0.0, up to 1.0)
 - width / height *(readonly)*
 - visible

**TileClip properties**
 - tile (set anim)
 - animated
 - loop
 - currentFrame
 - totalFrames
 - onComplete (TileClip->Void)
 - play / stop

**TileGroup**
 - x, y
 - width / height *(readonly, buggy)*
 - visible
 - addChild / addChildAt / removeChild / removeChildAt

Spritesheets Features
---------------------

**SparrowTilesheet**
 - extends TilesheetEx to parse Sparrow engine tilesheets,
 - supports animation and trimming.

**TilesheetEx**
 - Base class required by TileLayer,
 - animations are matched by name (startsWith) and cached,
 - can be used directly to dynamically build a spritesheet: TilesheetEx.createFromImages, TilesheetEx.createFromAssets

TODO
----
 - fix TileGroup width/height measurement
 - support useTint in Flash/JS fallback

Known issues
------------
 - TileGroups inside TileGroup returns incorrect width/height.

License
-------

    This code was created by Philippe Elsass and is provided under a MIT-style license. 
    Copyright (c) Philippe Elsass. All rights reserved.

    Permission is hereby granted, free of charge, to any person obtaining a 
    copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
    THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.

[1]:https://github.com/elsassph/nme-runnermark

