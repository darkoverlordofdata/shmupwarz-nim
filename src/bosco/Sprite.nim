import sdl2
import sdl2/image
import sdl2/ttf

type
  Scale* = ref object of RootObj
    x* : float64
    y* : float64

  Sprite* = ref object of RootObj
    texture* : TexturePtr
    x* : int
    y* : int
    width* : int
    height* : int
    scale* : Scale
    centered* : bool
    layer* : int
    id* : int

var
  SpriteUniqueId : int = 0

proc SpriteFromFile*(renderer : RendererPtr, path : string) : Sprite =
  let loadedSurface = load(path)
  if loadedSurface == nil:
      echo "Unable to load image: ", path
  else:
    result.new()
    result.texture = renderer.createTextureFromSurface(loadedSurface)
    if result.texture == nil:
      echo "Error creating texture from: ", path
    else:
      SpriteUniqueId += 1
      result.id = SpriteUniqueId
      result.texture.setTextureBlendMode BlendMode_Blend
      result.height = loadedSurface.h
      result.width = loadedSurface.w

proc SpriteFromText*(renderer : RendererPtr, text : string, font : FontPtr, fg : Color, bg : Color) : Sprite =
  let textSurface = font.renderText(text, fg, bg)
  if textSurface == nil:
    echo "Unable to render text surface: ", text
  else:
    result.new()
    result.texture = renderer.createTextureFromSurface(textSurface)
    if result.texture == nil:
      echo "Unable to create texture from rendered text: ", text
    else:
      SpriteUniqueId += 1
      result.id = SpriteUniqueId
      result.width = textSurface.w
      result.height = textSurface.h

proc setText*(this : Sprite, renderer : RendererPtr, text : string, font : FontPtr, fg : Color, bg : Color) : Sprite =
  let textSurface = font.renderText(text, fg, bg)
  if textSurface == nil:
    echo "Unable to render text surface: ", text
  else:
    this.texture = renderer.createTextureFromSurface(textSurface)
    if this.texture == nil:
      echo "Unable to create texture from rendered text: ", text
    else:
      this.width = textSurface.w
      this.height = textSurface.h


proc render*(this : Sprite, renderer : RendererPtr) =
  let x1 = if this.centered: this.x-(int(this.width/2)) else: this.x
  let y1 = if this.centered: this.y-(int(this.height/2)) else: this.y
  var src = rect(0, 0, cint(this.width), cint(this.height))
  var dst = rect(cint(x1), cint(y1), cint(this.width), cint(this.height))
  renderer.copy this.texture, addr(src), addr(dst)
