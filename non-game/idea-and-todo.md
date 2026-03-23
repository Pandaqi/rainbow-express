# To-Do

PUZZLE FRAMEWORK:
* Remember that we extended our GRID, so DO NOT OVERWRITE those files.
* Then import the final version from Potion Puzzle

Logic:

* Register (unhandled) tap anywhere on screen
* Check direction to current car
* Issue command to move it
  * Then let commands + data refresh handle EVERYTHING
* Check game over
  * If car has finished, but not all its collectibles collected, FAIL
  * If a car is just STUCK, then you can undo to get out right?
  * If all cars have finished, we WIN!

Graphics:

* Have a setting to overlay a GRID onto the world for clarity?
* DESTINATION: Also place something on the ground + make prettier 
* Cars could be prettier. 
  * Thicker outline?
  * Smaller size? => Cars that are not yet active are much smaller? (So the BIG one stands out?)
  * Animated? (Always bouncy, shadow on the floor, particles from exhaust of active car)
* Pretty LINE showing path already taken from car