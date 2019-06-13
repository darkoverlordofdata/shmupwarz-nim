# The Shmup Warriors of NIM


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
nim --define:release --define:useRealtimeGC --out:build/example compile example/main 
cp  -rf example/res build
cd build
./example

Stuttering fixed, thanks to this for comfirming what I was beginning to suspect:
http://devcry.heiho.net/html/2015/20150211-rock-solid-frame-rates.html

Once you start drawing, you don't want to do anything else in that frame. 
Draw time will expand to fill all remaining time. So the new bosco game loop flow is:

events
update
gc
(sleep)
draw

upgraded to nim 0.20 in preparation for 1.0!


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
