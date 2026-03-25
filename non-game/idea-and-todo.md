# To-Do


GENERATION:

* Find all "crossroads" (grid points with multiple connections from different trucks). If we think there are _too few_, randomly add new connections to unify the network and make the puzzle harder.
  * Find a point on our route that is in the same row/column as some other truck's route. (So, on the same line horizontally or vertically)
  * Now we can create a straight road between the two points. (Create a "connection" between all points in-between, which is just not used by any truck in the solution.)
  * **Really though it's first about checking if a route intersects with ANY other or is "standalone"**.
* If our total number of roads ended up rather short (for whatever reason), just add a few random connections.



FEEDBACK / VISUALS / FINISHING TOUCHES:

* Fix `get_car_color` to work with MORE CARS and DIFFERENT PUZZLE MODES => How to cleanly link `car index` to a randomized `type`?? Can we SHUFFLE static variables?
  * YES YOU CAN, BUT THIS MEANS RETRIES ARE INCONSISTENT BECAUSE YOU'RE STILL SHUFFLING THE SAME ARRAY!
* GRID OVERLAY -> Why the fuck is it sometimes correct and sometimes not???
* TUTORIAL AUDIO => "Tap somewhere to move your car in that direction. Get the car home! Its home is the spot with the same color as the car."
* RECORD AUDIO FOR NUMBERS AND LETTERS (add to shared library for Webshop already)
* FEEDBACK:
  * "Oh no! A car already drove there!"
  * "Oh no! There's no road there!"


Stretch Goals:

* Allow YOU to decide the ORDER of the cars?
* Can the line be PRETTIER? Shader? Road stripes? => Some simple noise shader to roughen the edges?
  * Maybe we need to go through LINE2D for shaders to work?
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
  * Rename PuzzleTween to more general PuzzleEffects or something?
  * Add a simple fire-and-forget function for textual feedback and icon feedback
* Settings =>
  * Check TOOLTIP style




@SOURCE: Great website to compress WebM I record for these video games => https://www.xconvert.com/compress-webm

@SOURCE: Turn recursive backtracker into iterative? 
* https://stackoverflow.com/questions/13782136/can-a-backtracking-tail-recursive-algorithm-be-converted-to-iteration -->
* https://stackoverflow.com/questions/20514267/how-can-i-collect-and-return-solutions-from-a-recursive-backtracking-algorithm/20531704#20531704
