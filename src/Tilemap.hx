import haxe.xml.Fast;
import flash.utils.ByteArray;
import starling.display.Image;
import starling.display.Sprite;
import starling.utils.AssetManager;

enum Orientation {
  Orthogonal;
  Isometric;
  IsometricStaggered;
  HexagonalStaggered;
}

enum RenderOrder {
  RightDown;
  RightUp;
  LeftDown;
  LeftUp;
}

private class Tile {
  public var id:Int;
  public var width:Int;
  public var height:Int;
  public var source:String;
  // properties

  public function new() {
  }
}

private class Layer {
  public var name:String;
  public var data:Array<Array<Tile>>;
  public var visible:Bool;
  // properties

  public function new() {
    data = new Array<Array<Tile>>();
  }
}

class Tilemap extends Sprite {

  public var mapWidth(default, null):Int;
  public var mapHeight(default, null):Int;
  public var tileWidth(default, null):Int;
  public var tileHeight(default, null):Int;
  public var orientation(default, null):Orientation;
  public var renderOrder(default, null):RenderOrder;
  private var _tiles:Array<Tile>;
  private var _layers:Array<Layer>;
  private var _assets:AssetManager;

  public function new(assets:AssetManager, xml:String) {
    super();
    _assets = assets;

    var xml = Xml.parse(haxe.Resource.getString(xml));
    var source = new Fast(xml.firstElement());

    var txt:String;

    txt = source.att.orientation;
    if (txt == "") {
      orientation = Orientation.Orthogonal;
    } else if (txt == "orthogonal") {
      orientation = Orientation.Orthogonal;
    } else if (txt == "isometric") {
      orientation = Orientation.Isometric;
    } else if (txt == "isometric-staggered") {
      orientation = Orientation.IsometricStaggered;
    } else if (txt == "hexagonal-staggered") {
      orientation = Orientation.HexagonalStaggered;
    }

    txt = source.att.renderorder;
    if (txt == "") {
      renderOrder = RenderOrder.RightDown;
    } else if (txt == "right-down") {
      renderOrder = RenderOrder.RightDown;
    } else if (txt == "right-up") {
      renderOrder = RenderOrder.RightUp;
    } else if (txt == "left-down") {
      renderOrder = RenderOrder.LeftDown;
    } else if (txt == "left-up") {
      renderOrder = RenderOrder.LeftUp;
    }

    mapWidth = Std.parseInt(source.att.width);
    mapHeight = Std.parseInt(source.att.height);

    tileWidth = Std.parseInt(source.att.tilewidth);
    tileHeight = Std.parseInt(source.att.tileheight);

    _tiles = new Array<Tile>();
    for (tileset in source.nodes.tileset) {
      if (tileset.has.source) {
        throw "External tileset source not supported.";
      }
      if (tileset.has.margin || tileset.has.spacing) {
        throw "Only image collections are supported.";
      }

      for (tile in tileset.nodes.tile) {
        if (tile.has.id) {
          var t = new Tile();
          t.id = Std.parseInt(tile.att.id);
          for (image in tile.nodes.image) {
            t.width = Std.parseInt(image.att.width);
            t.height = Std.parseInt(image.att.height);
            t.source = image.att.source;
            t.source = t.source.substr(0, t.source.length-4);
          }
          _tiles.push(t);
        }
      }
    }

    _layers = new Array<Layer>();
    for (layer in source.nodes.layer) {
      var t = new Layer();
      t.name = layer.att.name;
      for (i in 0...mapHeight) {
        t.data.push(new Array<Tile>());
        for (j in 0...mapWidth) {
          t.data[i].push(null);
        }
      }
      var i = 0;
      for (data in layer.nodes.data) {
        for (tile in data.nodes.tile) {
          t.data[Std.int(i / mapWidth)][Std.int(i % mapWidth)] = _tiles[Std.parseInt(tile.att.gid)-1];
          i += 1;
        }
      }
      _layers.push(t);
    }


    for (layer in _layers) {

      // The default is renderOrder == RenderOrder.RightDown
      var xi = 0;
      var xf = mapWidth;
      var dx = 1;
      var yi = 0;
      var yf = mapHeight;
      var dy = 1;
      
      if (renderOrder == RenderOrder.RightUp) {
        xi = 0;
        xf = mapWidth;
        dx = 1;
        yi = mapHeight-1;
        yf = -1;
        dy = -1;
      }

      if (renderOrder == RenderOrder.LeftDown) {
        xi = mapWidth-1;
        xf = -1;
        dx = -1;
        yi = 0;
        yf = mapHeight;
        dy = 1;
      }

      if (renderOrder == RenderOrder.LeftUp) {
        xi = mapWidth-1;
        xf = -1;
        dx = -1;
        yi = mapHeight-1;
        yf = -1;
        dy = -1;
      }

      var _x = 0;
      var _y = 0;
      while (_y != yf) {
        while (_x != xf) {
          var cell = layer.data[_y][_x];
          if (cell != null && cell.source != null && cell.source != "") {
            var img = new Image(_assets.getTexture(cell.source));
            img.pivotY = img.height;
            img.x = _x*tileWidth;
            img.y = _y*tileHeight + 32;
            addChild(img);
          }
          _x += dy;
        }
        _x = xi;
        _y += dy;
      }
    }

  }

}