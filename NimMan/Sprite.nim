import sdl2;
import sdl2/image;

type Sprite* = object
    path*: string
    img: SurfacePtr
    tex*: TexturePtr

proc New*(spr: var Sprite; RenPtr: RendererPtr, path: string) =
    spr.path = path;

    spr.img = load(spr.path);
    if spr.img == nil:
        echo "Error loading image: ", spr.path

    spr.tex = RenPtr.createTextureFromSurface(spr.img);
    if spr.tex == nil:
        echo "Error creating texture from: ", spr.path;
