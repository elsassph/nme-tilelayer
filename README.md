nme-tilelayer
=============

A lightweight and very optimized wrapper over NME's powerful but lowlevel 'drawTiles' which offers the best rendering performance 
(ie. batching) on native platforms.

**See [NME RunnerMark][1] for a sample project using this library.**

 - provides a basic display-list, spritesheet animations, mirroring (tile flipping), scale X/Y,
 - includes a Sparrow spritesheet parser, supporting trimming,
 - uses (and caches computations of) the new drawTiles' transform2x2 for native platforms,
 - uses Bitmaps for Flash & HTML5 target rendering,
 - very optimized caching and memory management.

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
    layer.addChild(clip);
    
    // tile group (only translation)
    var group = new TileGroup();
    group.addChild(new TileSprite("othername"));
    group.addChild(new TileClip("yetanother"));
    layer.addChild(group);

Render it:

    // batch it!
    addChild(layer.view); // layer is NOT a DisplayObject
    layer.render();

Features
--------

**TileLayer properties**
 - view *(root DisplayObject)*
 - useAlpha *(default true)*
 - useTransforms *(default true)*
 - useSmoothing
 - useAdditive
 - useTint

**TileSprite / TileClip properties**
 - tile *(currently readonly)*
 - x, y
 - rotation
 - scale / scaleX / scaleY
 - alpha
 - mirror *(1: horizontal, 2: vertical)*
 - r / g / b
 - width / height *(readonly)*

**TileClip properties**
 - animated
 - currentFrame
 - totalFrames
 - play / stop

**TileGroup**
 - x, y
 - width / height *(readonly, buggy)*
 - addChild / addChildAt / removeChild / removeChildAt
 - if you want to transform a TileGroup, use the TileGroupTransform behaviour

TODO
----
 - actually change tile when setting .tile
 - add optional looping and complete callback to TileClip
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

