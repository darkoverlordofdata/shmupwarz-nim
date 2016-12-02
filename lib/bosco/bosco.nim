import sdl2
import sdl2/image
import sdl2/ttf
import strfmt

type
  Vector2* = object of RootObj
    x* : float64
    y* : float64

  Sprite* = ref object of RootObj
    texture* : TexturePtr
    x* : int
    y* : int
    width* : int
    height* : int
    scale* : Vector2
    centered* : bool
    layer* : int
    id* : int
    path* : string

  AbstractGame* = ref object of RootObj
    name* : string
    width* : cint
    height* : cint
    running* : bool
    window* : WindowPtr
    renderer* : RendererPtr
    font* : FontPtr
    sprites* : seq[Sprite]
    currentKeyStates* : ptr array[0..512, uint8]
    delta* : float64
    ticks* : uint32
    lastTick : uint32
    showFps : bool
    fpsTimes : array[0..14, int]
    fpsTimeLast : int
    fpsCount : int
    fpsTickLast : int
    fpsSprite : Sprite
    fpsBg : Color
    fpsFg : Color
    fpsSrcRect : Rect
    fpsDstRect : Rect
    lastCount : int


proc SpriteFromFile*(renderer : RendererPtr, path : string): Sprite
proc SpriteFromText*(renderer : RendererPtr, text : string, font : FontPtr, fg : Color, bg : Color) : Sprite
proc setText*(this : Sprite, renderer : RendererPtr, text : string, font : FontPtr, fg : Color, bg : Color) : Sprite
proc render*(this : Sprite, renderer : RendererPtr)

proc init_sdl(this : AbstractGame)
proc render*(this : AbstractGame)
proc get_fps(this : AbstractGame) : Sprite
method start*(this : AbstractGame) {.base.}
method event*(this : AbstractGame, evt : Event) {.base.}
method update*(this : AbstractGame, delta : float64) {.base.}
method cleanup*(this : AbstractGame) {.base.}
method initialize*(this : AbstractGame) {.base.}


include AbstractGame
include Sprite
