# To-Do

PUZZLE FRAMEWORK:
* Remember that we extended our GRID (with neighbors, connections, etc), so DO NOT OVERWRITE those files.
* Then import the final version from Potion Puzzle

GENERATION:

* Find all "crossroads" (grid points with multiple connections from different trucks). If we think there are _too few_, randomly add new connections to unify the network and make the puzzle harder.
  * Find a point on our route that is in the same row/column as some other truck's route. (So, on the same line horizontally or vertically)
  * Now we can create a straight road between the two points. (Create a "connection" between all points in-between, which is just not used by any truck in the solution.)
* If our total number of roads ended up rather short (for whatever reason), just add a few random connections.

FEEDBACK / VISUALS:

* Clearly show some ARROW for the direction the game thinks you wanted to move.
* Show a cross or SAD SMILEY when you try to go in a direction you can't. (So show it over mid point of connections or where the connection WOULD be if it existed.)
* Maybe show a happy smiley too (permanently?) on cars that have finished correctly.



Finishing:

* Sound Effects: => switch to `PuzzleAudio.play_sound_nice` once framework added
  * Collect SET
  * Reach destination SET
  * ERROR SOUND when trying to go out of bounds / no path / already used path
* Proper camera centering/zooming on level
* Difficulty Levels (see below)
* Tutorial
  * Simply show the indicator in the right direction for the car.
  * Play audio again? "Tap somewhere to move your car in that direction. Get the car home! Do this by bringing it to the road with the same color."
* Settings & Stuff


Stretch Goals:

* Can the line be PRETTIER? Shader? Road stripes?
* COLLECTIBLES: Make less dark, make prettier / more fitting with the rest
* DECORATION: Make colors match environment?
* IMPROV: The front/back sides should probably be slightly _smaller_, now they seem huge in comparison to side view.
* Allow switching to "SHAPES" or "NUMBERS" or "LETTERS" or some other thing to match? This is something I probably want in most of my puzzle games, so maybe make this a standard functionality in the framework ...


## Difficulties

### Easiest

* grid_size = (3,3)
* num_cars_bounds = (1,1)
* allow_collectibles = false
* route_length_bounds = (3,6)

### Easy

* grid_size = (4,4)
* num_cars_bounds = (2,2)
* allow_collectibles = false
* route_length_bounds = (3,6)

### Medium

* grid_size = (5,5)
* num_cars_bounds = (3,3)
* allow_collectibles = false
* route_length_bounds = (4,8)

### Hard

* grid_size = (6,6)
* num_cars_bounds = (3,3)
* allow_collectibles = true
* route_length_bounds = (5,10)

### Hardest

* grid_size = (9,9)
* num_cars_bounds = (3,5)
* allow_collectibles = true
* route_length_bounds = (6, 12)





## PuzzleFramework:

* Button to PLAY THE SOLUTION -> I can hide that in the game itself but at least use it for my own debugging
  * Maybe more like a "HINT" system?
* Write some short docs on the few steps to take to _integrate the framework_ in each new game => WHERE would I put that file though?
  * **Add frameworks like these to the `Games/Shared` folder?** One Button Games, PuzzleFramework, the Rust puzzle one, etc.
* Actually _save_ user settings between sessions? (And save other data, like completed puzzles/highscore/etc?)
* Even more generic tutorial support?
  * Allow giving a _sequence_ of things to highlight + timings and methods?
  * Allow duplicating the sprite and darkening the BG, to really highlight that one thing?
* Localization (both text and audio)
* Feedback:
  * Rename PuzzleTween to more general PuzzleEffects or something
  * Add a simple fire-and-forget function for textual feedback and icon feedback
* Settings =>
  * Add TOOLTIP again
  * Create a `PuzzleSettings` static class so I can just do `PuzzleSettings.get_value()` for settings?
* Commands =>
  * Move AudioUndo to some other place, so we DON'T need to add Commands as a child each time?


@SOURCE: Great website to compress WebM I record for these video games => https://www.xconvert.com/compress-webm

@SOURCE: Turn recursive backtracker into iterative? 
* https://stackoverflow.com/questions/13782136/can-a-backtracking-tail-recursive-algorithm-be-converted-to-iteration -->
* https://stackoverflow.com/questions/20514267/how-can-i-collect-and-return-solutions-from-a-recursive-backtracking-algorithm/20531704#20531704
