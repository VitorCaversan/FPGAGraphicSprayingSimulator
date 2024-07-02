# FPGA Graphic Spraying Simulator

This repository contains the source code and documentation for the **FPGA Graphic Spraying Simulator** project, developed as part of the reconfigurable logic course.

## Project Description

The project is a graphic spraying simulator developed in VHDL and implemented on an Intel MAX10 10M50DAF484C7G FPGA. It simulates the movement of a tractor in a field, spraying specific areas and avoiding obstacles, using a VGA interface for graphical visualization.

## System Blocks

- **Frequency Divider (div_freq)**: Divides the input clock frequency to generate slower clock signals.
- **Tractor Movement Control (tractorMover)**: Controls the position and direction of the tractor on the screen, avoiding obstacles.
- **Tractor Printer (tractorPrinter)**: Determines which pixels represent the tractor on the screen, adjusting the rotation as needed.
- **Spray Field (sprayField)**: Simulates the spray field, updating the color of blocks as the tractor passes.
- **Obstacle (rockObstacle)**: Represents rocks on the screen, adjusting the vertical position of obstacles during the simulation.

> **Note**: As the project was developed using Quartus, it is recommended to maintain the same directory path (`C:\fpgaGraphicSprayingSimulator`) when cloning the repository to ensure compatibility and ease of use.

---