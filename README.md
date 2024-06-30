# FPGAGraphicSprayingSimulator
A spraying simulator using FPGA and emulating via a graphic interface through VGA port.

## Rotation Values

The tractor image can be rotated in different directions based on the input value provided to the `direction` signal. The table below shows the mapping between the direction values and the corresponding rotation in degrees:

| Direction Value | Rotation (Degrees) |
|-----------------|---------------------|
| `00`            | 0° (Normal)         |
| `01`            | 90° (Clockwise)     |
| `10`            | 180° (Upside Down)  |
| `11`            | 270° (Counterclockwise) |
