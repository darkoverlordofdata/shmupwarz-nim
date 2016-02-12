import sdl2;
import sdl2/image;
import Sprite;

const UpKey = 82;
const DownKey = 81;
const LeftKey = 80;
const RightKey = 79;

type DIRECTIONS = enum
    NONE, UP, DOWN, LEFT, RIGHT

type Player* = object
    x*: float
    y*: float
    w*: int
    h*: int
    speed*: float
    angle*: cdouble

proc New*(p: var Player;) =
    p.x = 300;
    p.y = 300;
    p.w = 24;
    p.h = 24;
    p.speed = 200;
    p.angle = 0;

proc SetPos*(p: var Player; x, y: float) =
    p.x = x;
    p.y = y;

var Player_Direction: DIRECTIONS;
proc Move*(p: var Player; KeyDown: ptr array[0..512, uint8], deltaTime: float) =
    #Move Player
    let dtSpeed = p.speed * deltaTime;

    if (bool)KeyDown[UpKey]:
        Player_Direction = UP;
        p.angle = 0;
    if (bool)KeyDown[DownKey]:
        Player_Direction = DOWN;
        p.angle = 180;
    if (bool)KeyDown[LeftKey]:
        Player_Direction = LEFT;
        p.angle = 270;
    if (bool)KeyDown[RightKey]:
        Player_Direction = RIGHT;
        p.angle = 90;

    case Player_Direction
        of UP:
            p.y -= dtSpeed;
        of DOWN:
            p.y += dtSpeed;
        of LEFT:
            p.x -= dtSpeed;
        of RIGHT:
            p.x += dtSpeed;
        else:
            Player_Direction = NONE;

    #Wrap Player Around Screen
    if p.x > 816:
        p.x = 0;
    elif int(p.x)+p.w < 0:
        p.x = 816;
    if p.y > 600:
        p.y = 0;
    elif int(p.y)+p.h < 0:
        p.y = 600;

proc Draw*(p: var Player; RenPtr: var RendererPtr, sprite: var Sprite) =
    var srcRect = rect(0, 0, (cint)p.w, (cint)p.h);
    var dstRect = rect((cint)p.x, (cint)p.y, (cint)p.w, (cint)p.h);
    var center = point(p.w/2, p.h/2);

    RenPtr.setDrawColor(255, 255, 255, 255);
    RenPtr.copyEx(sprite.tex, addr(srcRect), addr(dstRect), p.angle, addr(center), Renderer_Flip(SDL_FLIP_NONE));
