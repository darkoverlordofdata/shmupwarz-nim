import sdl2;
import sdl2/image;
import sdl2/ttf;
import Player;
import Sprite;
import strfmt;

type Game* = object
    width*: cint
    height*: cint
    title*: string
    WinPtr*: WindowPtr
    RenPtr*: RendererPtr
    KeyDown*: ptr array[0..512, uint8]
    font*: FontPtr

proc Init*(g: var Game;) =
    #Initialize SDL2 and SDL2_image
    discard sdl2.init(INIT_EVERYTHING);
    discard image.init(IMG_INIT_PNG);
    discard ttf.ttfInit();
    g.font = ttf.openFont("res/skranji.regular.ttf", 32);
    if g.font == nil:
        echo "Error creating SDL_Font: ", getError();
        quit(1);

    g.width = 816;
    g.height = 600;
    g.title = "NimMan";

    #Create a Window and a Renderer
    g.WinPtr = createWindow(g.title, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, g.width, g.height, SDL_WINDOW_SHOWN);
    if g.WinPtr == nil:
        echo "Error creating SDL_Window: ", getError();
        quit(1);

    g.RenPtr = createRenderer(g.WinPtr, -1, Renderer_Accelerated or Renderer_PresentVsync);
    if g.RenPtr == nil:
        echo "Error creating SDL_Renderer: ", getError();
        quit(1);
    g.KeyDown = getKeyboardState(nil);


proc Run*(g: var Game;) =
    var evt = defaultEvent;
    var running: bool = true;

    #Getting Delta Time
    var timeNow = getTicks();
    var timeLast: uint32 = 0;

    #Instance Player
    var player: Player;
    player.New();
    player.SetPos(250, 250);

    #Create Player Sprite
    var playerSprite: Sprite;
    playerSprite.New(g.RenPtr, "res/player.png");

    var fg, bg: Color;
    fg.r = 255;
    fg.g = 255;
    fg.b = 255;
    fg.a = 255;
    bg.r = 0;
    bg.g = 0;
    bg.b = 0;
    bg.a = 0;
    var su = g.font.renderText("fps: 00.00", fg, bg);
    echo "Width ",su.w
    echo "Height ",su.h
    var srcRect = rect(0, 0, (cint)su.w, (cint)su.h);
    var dstRect = rect(0, 0, (cint)su.w, (cint)su.h);

    while running:
        while pollEvent(evt):
            case evt.kind
                of QuitEvent:
                    running = false;
                else: discard
        #Exit game if escape key is pressed
        if (bool)g.KeyDown[41]:
            running = false;
        g.RenPtr.setDrawColor(0, 0, 0, 255);
        g.RenPtr.clear();

        #Geting Delta Time
        timeLast = timeNow;
        timeNow = getTicks();
        let deltaTime: float = float((timeNow - timeLast)) / float(1000);

        let s = (deltaTime*3600).format("02.2f");
        let su = g.font.renderText("fps: {0}".fmt(s), fg, bg);
        let tx = g.RenPtr.createTextureFromSurface(su);
        g.RenPtr.copy(tx, addr(srcRect), addr(dstRect))

        #Do Player
        player.Move(g.KeyDown, deltaTime);
        player.Draw(g.RenPtr, playerSprite);

        g.RenPtr.present();
    destroy g.RenPtr;
    destroy g.WinPtr;
