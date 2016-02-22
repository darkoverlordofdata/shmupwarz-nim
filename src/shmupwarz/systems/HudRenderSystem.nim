##
## HudRenderSystem
##
const ACTIVE_ENTITIES : string  = "Active entities:         "
const TOTAL_RETAINED : string   = "Total reusable:          "
const TOTAL_REUSABLE : string   = "Total retained:          "
const FONT_PATH = "res/fonts/skranji.regular.ttf"
const FONT_SIZE = 16

proc newHudRenderSystem*(game : Game) : HudRenderSystem =
  new(result)
  result.game = game

proc createText(this : HudRenderSystem, x : int, y : int, text : string) : Sprite =
  this.fg = color(255, 255, 255, 255)
  this.bg = color(0, 0, 0, 0)
  var sprite = SpriteFromText(this.game.renderer, text, this.font, this.fg, this.bg)
  sprite.x = x
  sprite.y = y
  sprite.layer = int(Layer.HUD)
  sprite.centered = false
  return sprite

proc setText(this : HudRenderSystem, sprite : Sprite, text : string) =
  discard sprite.setText(this.game.renderer, text, this.font, this.fg, this.bg)

method initialize*(this : HudRenderSystem) =
  this.font = ttf.openFont(FONT_PATH, FONT_SIZE)
  this.activeEntities = this.createText(0, 40, ACTIVE_ENTITIES & this.world.count.format("d"))
  this.totalRetained = this.createText(0, 60, TOTAL_RETAINED & this.world.reusableEntitiesCount.format("d"))
  this.totalReusable = this.createText(0, 80, TOTAL_REUSABLE & this.world.retainedEntitiesCount.format("d"))

  this.game.sprites.add(this.activeEntities)
  this.game.sprites.add(this.totalRetained)
  this.game.sprites.add(this.totalReusable)

method execute*(this : HudRenderSystem) =
  this.setText(this.activeEntities, ACTIVE_ENTITIES & this.world.count.format("d"))
  this.setText(this.totalRetained, TOTAL_RETAINED & this.world.reusableEntitiesCount.format("d"))
  this.setText(this.totalReusable, TOTAL_REUSABLE & this.world.retainedEntitiesCount.format("d"))
