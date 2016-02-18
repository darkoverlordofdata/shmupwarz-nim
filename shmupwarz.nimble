# Package

version       = "0.1.0"
author        = "bruce"
description   = "Game POC"
license       = "MIT"

srcDir        = "src"
binDir        = "build"
bin           = @["main"]
# Dependencies

requires @["nim >= 0.13.0", "sdl2", "strfmt", "nuuid"]
