# Assembling line automation

## Install
Because there are only 4 files and the internet card in GTNH is very annoying to craft, it is recommended to install by 
copying each file to the open computer robots with `insert` key.
(Will add a installation script if many people request it.)

## Usage
By default the script assumes that the assembling line length is 11. Change it in `assline.lua` if necessary.  

Build the assline as following structure:  
```
[- H H H H - - - - - - -]  
[C I I I I I I I I I I O]  
[- - - - - - - - - - - -]
```
Where
- H: input hatch, with a fluid tank set to auto output attached to it.
- I: input bus.
- O: output bus.
- C: Robot Charger.

Place the robot on top of an inventory that contains recipe datasticks (data access hatch) and run `readAsslineRecipes`.
It will generate 2 .data file. Run `edit asslineFluidLocations.data` to see the locations to provide each fluid.

Place robot on top of the charger and run `assline` to let the robot waiting for item input. The robot will constantly
check its own inventory to see if there is task.

## Feature
- Handles split stack recipes.
- TODO

## Video Demo
- TODO

