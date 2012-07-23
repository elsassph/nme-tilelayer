nme-tilelayer
=============

A lightweight and very optimized wrapper over NME's powerful but lowlevel 'drawTiles' which offers the best rendering performance 
(ie. batching) on native platforms.

**See [NME RunnerMark][1] for a sample project using this library.**

 - provides a basic display-list, spritesheet animations, mirroring (tile flipping), scale X/Y,
 - includes a Sparrow spritesheet parser, supporting trimming,
 - uses (and caches computations of) the new drawTiles' transform2x2 for native platforms,
 - uses Bitmaps for Flash & HTML5 target rendering,
 - very optimized memory management, near-zero garbage collection.

**Warning:** TileLayer is a "batching" class so it should be used to display "many elements" - that means you should 
include as many sprites/anims as possible in the spritesheet. Creating many TileLayers is conter-productive, because 
having many textures and not doing batching is inefficient for GPU performance.

Usage
-----
- install the library: type `haxelib install tilelayer` in your terminal
- add `<haxelib name="tilelayer" />` in your nmml

Configure it:

    // sprite sheet
    var tilesheet = new SparrowTilesheet(
        Assets.getBitmapData("assets/spritesheet.png"), Assets.getText("assets/spritesheet.xml"));
    
    // tile-layer
    var layer = new TileLayer(tilesheet); // optional flags: smoothing, additive blendmode

Add/manipulate elements as a display list:

    // static tile
    var sprite = new TileSprite("spritename");
    layer.addChild(sprite);
    
    // animated tile
    var clip = new TileClip("animname");
    clip.loop = false;
    layer.addChild(clip);
    
    // tile group (only translation, use the TileGroupTransform behaviour for more)
    var group = new TileGroup();
    group.addChild(new TileSprite("othername"));
    group.addChild(new TileClip("yetanother"));
    layer.addChild(group);

Render it:

    // batch it!
    addChild(layer.view); // layer is NOT a DisplayObject
    layer.render();

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
 - rotation
 - scale / scaleX / scaleY
 - alpha
 - mirror *(1: horizontal, 2: vertical)*
 - r / g / b
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
 - Tiles' size is null until they are added to the virtual display list,
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

