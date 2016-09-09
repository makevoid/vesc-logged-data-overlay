# VESC Logged Data overlay

in Ruby + SDL2

from a `VESC_LOG.TXT` file exported by this or a similar app: https://github.com/makevoid/VESC_Logger


### example video:

alpha version

<iframe width="560" height="315" src="https://www.youtube.com/embed/bxSrCjUnLUc" frameborder="0" allowfullscreen></iframe>

### creates a video 

(at the moment you need to record the app window yourself - via ffmpeg for example)

check https://github.com/makevoid/vesc-logged-data-overlay/blob/master/sdl2.rb at the end of the file or start from this ffmpeg snippet:

(this example requires more args than the original one)

    ffmpeg -f avfoundation -r 25  -s 1600x800 -i 1:0 -vf crop=1600:800:0:90  -c:v libx264   ~/Pictures/out.mov"

use x11grab on linux, avfoundation on mac


    ffmpeg -f x11grab -r 25  -s 1600x800 -i 1:0 -vf crop=1600:800:0:90  -c:v libx264   ~/Pictures/out.mp4"


this is istantaneous, instead of the rmagick based logger (  https://gist.github.com/makevoid/d68a4e95ba518cc84ed584afe2445f1d ) which can take quite a bit of time

if you don't want to use ffmpeg for screen recording you can always use any screen-recording / screencasting app.


## Prereqs.

- Ruby

- SDL2

    apt install libsdl2-dev libsdl2-ttf-dev

## Running this


    ruby sdl2.rb


(at the moment you need to record the app window yourself)

you will get a .mp4/.mov/.mkv video (depending on the app you use to record, I found vokoscreen for linux alright) that you can embed in your video like this one:


[![](https://img.youtube.com/vi/hgoqK2bQ5JE/0.jpg)](https://www.youtube.com/watch?v=hgoqK2bQ5JE)


[youtube.com/watch?v=hgoqK2bQ5JE](https://www.youtube.com/watch?v=hgoqK2bQ5JE)


<iframe width="420" height="315" src="https://www.youtube.com/embed/hgoqK2bQ5JE" frameborder="0" allowfullscreen></iframe> 
