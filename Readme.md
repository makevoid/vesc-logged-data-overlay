# SDL2 VESC video maker 

### creates a video 

(at the moment you need to record the app window yourself)

this is istantaneous, instead of the rmagick based logger (  https://gist.github.com/makevoid/d68a4e95ba518cc84ed584afe2445f1d ) which can take quite a bit of time


## Prereqs.

- SDL2

    apt install libsdl2-dev libsdl2-ttf-dev

## Running this


    ruby sdl2.rb


(at the moment you need to record the app window yourself)

you will get a .mp4/.mov/.mkv video (depending on the app you use to record, I found vokoscreen for linux alright) that you can embed in your video like this one:

<iframe width="420" height="315" src="https://www.youtube.com/embed/hgoqK2bQ5JE" frameborder="0" allowfullscreen></iframe> 
