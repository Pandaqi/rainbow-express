# Rainbow Express (Devlog)

Welcome to my developer's diary for my educational puzzle game [Rainbow Express](https://thewaywardmelody.com/puzzlepages/level-1/maths/video-games/rainbow-express/). I'll try to explain how it was made, interesting problems faced and lessons learned, and most of all give a fun overview of the process.

## What's the idea?

While brainstorming ideas for educational puzzle games, focusing mostly on _color_ and _shape_ for now, I stumbled upon _"RGB Express"_. An old mobile game that was well-received and inspired me to make a simpler, educational version.

In that game,

* You get a network of (straight) roads and a few trucks (RGB = Red, Green, and Blue).
* Each truck wants to get to the destination with the same color.
* Sometimes, they also need to pick up same-colored objects along the way.
* You pick each truck's route by touching it with your finger, then sliding over the roads, until you end at the destination.
* Trucks can't _overlap_, but they _can_ cross over each other.
* Once satisfied, run the game, the trucks will follow your assigned path, and hopefully you solved it.

The core idea is very useful for a color puzzle game. But I saw some ways to simplify it: the fact that you need to precisely map out each truck's route is a bit too hard for <4 year olds, the fact you need to plan all trucks ahead of time is also a step too far, and so forth.

As such, my idea was...

* You get a (smaller) network of roads.
* Each truck is presented _in turn_ (instead of all at once). It just says "Now you're moving truck RED".
* By tapping in some direction, the truck immediately moves there. (So, tap to the left of the truck, and it goes one step to the left.)
* Once you bring your current truck home, the path you took simply stays visible. Now move the next truck.

Of course, for the easiest levels, we can just stick to a single truck in the first place.

This was my way of reducing the game to just a _single simple action that young kids can do_, giving _immediate feedback_, and allowing maps to stay small and simple.

## How to make such puzzles?

Randomly generating such puzzles is easier than you might think. Or, well, I initially wrote down this idea as "the hardest puzzle idea to generate by far" and it turned out to be only medium difficulty in the end. My "simpler rules", though, made this possible. I purposely left out some bits and changed some of my requirements to keep the algorithm simple.

What does every puzzle need? A road network and a solution. Fortunately, the "solution" (for each truck) is a _path over these roads_, which means we can ...

* Start with a completely empty grid!
* For each truck, find a **random route** through this grid.
  * Start in a random space.
  * Take random steps left/right/up/down (if allowed).
  * Cut it off when we've found a route that's our desired length.
  * (If none exists, try again from a different starting point. If none work out, try again but with "desired length" one shorter. Keep going down this path, whatever it takes, and at some point we're guaranteed to find some route.)
* After finding a route for each truck, **save it**.
  * Mark all the connections as "used by the RED truck"
  * (Such that the next truck knows it _can't_ move that way anymore and will find routes that don't overlap.)

By simply generating _the solution_ (the route of each truck), we also get our actual _road network_ (the connections that must exist for them). 

If we pick suitable numbers (in terms of road length and grid size), then those roads will automatically intersect in some places, creating one nice organic road network.

This isn't _always_ the case, though, so we can do some "cleaning up" afterwards.

* Find all "crossroads" (grid points with multiple connections from different trucks). If we think there are _too few_, randomly add new connections to unify the network and make the puzzle harder.
  * Find a point on our route that is in the same row/column as some other truck's route. (So, on the same line horizontally or vertically)
  * Now we can create a straight road between the two points. (Create a "connection" between all points in-between, which is just not used by any truck in the solution.)
* If our total number of roads ended up rather short (for whatever reason), just add a few random connections.

This obscures the solution a bit more and prevents randomly creating puzzles that are way too obvious.

Finally, we can step through every truck's route and randomly place some "collectibles" to pick up. By far the easiest (and most controllable) method I've found for this, is the "interval method":

* Plan a random index to place a collectible (say, `place_next_collectible_at = 3`)
* Loop through every point in the route, keeping track of the index. (So point 1, point 2, point 3)
* When our index is the same as our planned index, 
  * Place a collectible here!
  * Plan the next index (say, `place_next_collectible_at = 5`)

This ensures we place them spaced out randomly, but with an interval ("maximum randomness") that we control.

This was about an hour of frantic coding, most of it boilerplate (setting up the grid ... looping through the right things ...), and to my surprise it worked instantly. It delivered nice road networks with puzzles that are not too hard for kids, but also not obvious (the "not a game at all really"-kind of educational games). The algorithm never fails or takes longer than the blink of an eye. And we can modify all the variables (size of the map, crossroads desired, number of trucks, etcetera) freely.

If we pick "bad numbers" for this, the algorithm will just find "bad routes" (length 1 or 2) for trucks. The puzzle becomes silly or ugly. But it does not crash or break, which is the worse result.

In the end, I also made some other tweaks to the algorithm to make maps more balanced/consistent.

* Instead of "randomly" adding connections, I calculate the _longest stretch_ I can add. This is usually a long road that connects two parts of the map, or one that leads to the edge of the map. These connections _look best_ and fill up the map nicely, so I sort them and prefer picking these.
* Conversely, I prefer picking _the shortest possible connection_ when fixing standalone routes. This is, again, because it simply works best with the game. If I connect two separate roads with a long line somewhere at the edge ... this isn't fooling anyone because the roads are still clearly separate. By connecting them with a few close crossroads, they become much more entangled.
* I only pick roads that go "nowhere" (they lead to the edge of the map and stop; not part of any route) some percentage of the time. Do it too often, and the map is filled with nonsense. Don't do it at all, and the solution becomes obvious because there are no "decoy" routes.

As usual, play with numbers, play some more with numbers, try different approaches, and you slowly get closer to a consistent output :p

## How to actually play the puzzle?

After generating the puzzle, I give the result to my "visualizing" script.

* It already places an image for all the trucks and destinations, because you want to know this ahead of time. (Otherwise you can't know if the route you're taking now is going to lead to problems later.)
* It registers a "click/tap" on the screen.
  * It finds the current truck---the one you're moving right now. (Which is highlighted and animated to show this, of course.)
  * It calculates the direction of your tap. (Was it on the left of the truck? On the right?)
  * It checks if there's a road in that direction; if so, it animates a simple movement to that new space.
  * If the truck finishes, play some happy sound and make the _next_ truck active.
* If all trucks have finished, you've beaten the puzzle!

As usual, the visual element is "smoke and mirrors" (as in al video games). Behind the scenes, your truck position just instantly moves to the new one, or a collectible is just set to "hidden" once you pass it. But on the screen things are animated, and take time, and move around to make it feel like you drive a truck and collect stuff.

## Conclusion

As stated, I was surprised how "easy" it was to generate these puzzles. But once generated---once all these truck routes are overlapping and creating crossroads and such---it's actually a _puzzle_. One that's not obvious, but also not too hard for young kids to play.

Additionally, this game has a nice _blend_ of educational topics. It's not just about colors, but also directions (another important Level 1 topic of my online store) and sequencing (first truck, middle truck, last truck). By simplifying the idea it's able to cover these topics in a very streamlined way, as opposed to "regular" puzzle games. 

> For example, moving the truck just means tapping to the left/right/top/bottom of it. Nothing diagonal, nothing more complicated, no longer sequences, certainly no 3D. This teaches kids directions and spatial awareness, but without overwhelming them with more difficult 2D/geometry/puzzle grid stuff.

The game itself could have received some more fancy graphics and visual niceties. But I'm actively trying _not_ to do that, because it takes far too much time, while it's not critical (or "warranted") for tiny puzzle games like these. I'd rather reserve more time and effort for art and design for _big_ games.

Until the next devlog,

Pandaqi

