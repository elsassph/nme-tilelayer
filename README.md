nme-tilelayer
=============

A lightweight wrapper over NME's powerful but lowlevel 'drawTiles' which offers the best rendering performance 
(ie. batching) on native platforms.

**See [NME RunnerMark][1] for a sample project using this library.**

 - provides a basic display-list, spritesheet animations, mirroring (tile flipping), scale X/Y,
 - includes a Sparrow spritesheet parser, supporting trimming,
 - uses (and caches computations of) the new drawTiles' transform2x2 for native platforms,
 - uses Bitmaps for Flash & HTML5 target rendering.

Usage
-----

    // sprite sheet
    var tilesheet = new SparrowTilesheet(
        Assets.getBitmapData("assets/spritesheet.png"), Assets.getText("assets/spritesheet.xml"));
    
    // tile-layer
    var layer = new TileLayer(tilesheet); // optional flags: smoothing, additive blendmode
        
    // static tile
    var sprite = new TileSprite("spritename");
    layer.dom.addChild(sprite);
    
    // animated tile
    var clip = new TileClip("animname");
    layer.dom.addChild(clip);
    
    // tile group (only translation)
    var group = new TileGroup();
    group.addChild(new TileSprite("othername"));
    group.addChild(new TileClip("yetanother"));
    layer.dom.addChild(group);
    
    // batch it!
    addChild(layer);
    layer.render();

Features
--------

**TileLayer properties**
 - dom *(root TileGroup)*
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

TODO
----
 - actually change tile when setting .tile
 - add optional looping and complete callback to TileClip
 - FIX TileGroup to return correct width/height
 - support useTint in Flash/JS fallback

[1]:https://github.com/elsassph/nme-runnermark

