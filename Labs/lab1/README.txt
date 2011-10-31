Lab 1 implements a portion of pong. For lab1 there is no input device, so the
paddle tracks the position of the ball and plays the ball automatically. The
movement of the ball is given an initial dx and dy. To simplify this
iteration, I have chosen a slop of 1, e.g. the ball moves at 45 degrees. 
Registers are dedicated to storage for the paddles x-position, y-position,
length, width, the ball's x, y, dx, and dy. Since the dx and dy have a
magnitude of one, handling the edge-case of when the ball hits the wall, or
the paddle, is a matter of negatign the direction of dy and dx.

The stall function adjusts the speed of the game.
