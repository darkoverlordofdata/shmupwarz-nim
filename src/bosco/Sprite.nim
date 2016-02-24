import sdl2
import sdl2/image
import sdl2/ttf

type
  Scale* = object of RootObj
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
    path* : string

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
      result.texture.setTextureBlendMode BlendMode_Blend
      SpriteUniqueId += 1
      result.id = SpriteUniqueId
      result.path = path
      result.centered = true
      result.height = loadedSurface.h
      result.width = loadedSurface.w
      result.scale.x = 1
      result.scale.y = 1

proc SpriteFromText*(renderer : RendererPtr, text : string, font : FontPtr, fg : Color, bg : Color) : Sprite =
  assert font != nil

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
      result.scale.x = 1
      result.scale.y = 1

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
  let w = float64(this.width) * this.scale.x
  let h = float64(this.height) * this.scale.y
  let x1 = if this.centered: this.x-(int(w/2)) else: this.x
  let y1 = if this.centered: this.y-(int(h/2)) else: this.y
  var dst = rect(cint(x1), cint(y1), cint(w), cint(h))
  renderer.copy this.texture, nil, addr(dst)
