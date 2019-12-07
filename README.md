# ECE241 Digital Systems - Verilog Projects and Labs

This repo contains all of my labs as well as my final project for ECE241 - Digital Systems, which was part of my Computer Engineering curriculum at the University of Toronto. The labs start off basic - manually writing AND and OR gates - all the way up to a quite advanced project - creating an arcade game.

All Verilog files created and compiled using Quartus Prime software, and run on a DE1-SoC FPGA board.

## Final Project: "_Screaming Game: The Game_"

For the final project of this class, my partner @josephsawaya and I chose to make an FPGA based platformer game called _Screaming Game: The Game_. The objective of this game is to jump higher and higher on the screen using platforms, in order to get to a pot of gold at the top. To make the game more competitive, there is also a timer, which stops once the player has reached the topmost platform - making it a race against the clock. The player with the shortest time wins! 

What makes this game unique and gives it its name is its use of the microphone to control the player’s jump. In order to make the player jump on the screen, the user must yell into the microphone, making it a really enjoyable experience for the people around you, watching you play the game.

Below, is a GIF created using a simulation of the game, the player movement is smoother in the actual game, but the GIF gives an accurate portrayal of the game otherwise. A video of the game running on an actual FPGA board is coming soon.

![In-Game View of the game](/ScreamingGame_TheGame/READMEfiles/game_sim.gif)
