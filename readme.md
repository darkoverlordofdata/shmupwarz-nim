# Schmup Warz

One more time, with Nim!

git clone git@github.com/darkoverlordofdata/shmupwarz-nim
cd shmupwarz-nim
cd lib
cd entitas
nimble install
cd ..
cd bosco
nimble install
cd ../..
entitas generate --platform nim
nim --define:release --out:build/example compile example/main
cd build
./example


This is on an ASUS i7 with 12 gb. 
On a Inspiron i3 with 4 gb, the nim version stutters.

profile avg ms per frame:

            nim         fsharp
    exec - 0.0007       0.00005
            sdl2        monogame
    draw - 0.015        0.002


Most of each frame is spent in a loop, just drawing an array of textures using SDL2.
The same loop in FSharp, using MonoGame (SDL2 wrapper) runs 7-8 times faster.


# MIT License

Copyright (c) 2016 Bruce Davidson &lt;darkoverlordofdata@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
