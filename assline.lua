--[[ 
    Assline space layout:
    [1] robot starting loc, charger, ME interface on top of robot.
    [2] assline input bus #1, input hatch #1
    ...
    [11] assline input bus #10
    [12] assline output bus
 ]]

dofile('third_party/table_io.lua');
local recipeUtil = require('recipeUtil');

local os = require('os');
local robot = require('robot');
local component = require('component');
local sides = require('sides');
local inventory_controller = component.inventory_controller;
local tank_controller = component.tank_controller;


local function matchRecipe(recipes)
    local recipe = {inputItems = {}};
    for i = 1, robot.inventorySize() do
        local itemStack = inventory_controller.getStackInInternalSlot(i);

        if itemStack ~= nil then
            recipe.inputItems[i] = {
                itemStack.label,
                itemStack.size,
            };
        end
    end

    local matchedRecipe = recipes[recipeUtil.getRecipeKey(recipe)];
    if not matchedRecipe then
        print('Cannot find recipe in DB!');
        return nil;
    end
    
    return matchedRecipe;
end

local function navigateTo(currentLoc, newLoc)
    if currentLoc == newLoc then
        return;
    end

    if currentLoc > newLoc then
        for _ = newLoc, currentLoc - 1 do
            os.sleep(0.1);
            robot.back();
        end
    else
        for _ = currentLoc, newLoc - 1 do
            robot.forward();
        end
    end
end

--[[ Fetch fluid from tanks. 
    Args:
        fluid: A {fluidName, amount} pair.
        fluidLocations: A mapping from fluidName to fluidLocation.
        origin: The starting location of the robot.
]]
local function fetchFluid(fluid, fluidLocations, origin)
    local fluidName = fluid[1];
    local amount = fluid[2];
    local fluidLocation = fluidLocations[fluidName];
    if fluidLocation == nil then
        print(string.format("Bad fluid name %s.", fluidName));
        return false;
    end

    navigateTo(origin, fluidLocation);
    if tank_controller.getTankLevel(sides.down) < amount then
        print(string.format('insufficient %s. Need %i.', fluidName, amount));
        return false;
    end

    if not robot.drainDown(amount) then
        print(string.format('Internal tank full.'));
        return false;
    end

    navigateTo(fluidLocation, origin);
    return true;
end

--[[ 
    Load the fluids in the fluid tanks to assline input hatches.
    Load items in the robot's internal inventory to assline input buses. 

    Assumes that items in robot's internal inventory is in the same order
    as appeared in the recipe.
]]
local ASSLINE_LENGTH = 11;
local MAX_FLUID_INPUTS = 4;
local function loadAssline(recipe, fluidLocations)
    local currentInventorySlot = 1;

    for i = 1, ASSLINE_LENGTH - 1 do
        robot.forward();

        -- Load fluid.
        local fluidToLoad = recipe.inputFluids[i];
        if fluidToLoad ~= nil then
            if fetchFluid(fluidToLoad, fluidLocations, i + 1) then
                local fluidAmount = fluidToLoad[2];
                robot.turnLeft();
                robot.fill(fluidAmount);
                robot.turnRight();
            else
                return false;
            end
        end

        -- Load item.
        robot.select(currentInventorySlot);
        if recipe.inputItems[i] ~= nil then
            local itemToLoad = recipe.inputItems[i];
            local itemAmount = itemToLoad[2];

            local itemStack = inventory_controller.getStackInInternalSlot(currentInventorySlot);
            if itemStack.size < itemAmount then 
                print(string.format("Fatal: Need %i %s, but only get %i at slot %i", itemAmount, itemToLoad[1], itemStack.size, i));
                return false;
            elseif itemStack.size == itemAmount then
                inventory_controller.dropIntoSlot(sides.up, 1);
                currentInventorySlot = currentInventorySlot + 1;
            else -- itemStack.size > itemAmount
                inventory_controller.dropIntoSlot(sides.up, 1, itemAmount);
            end
        end
    end
    
    -- Get the output item.
    robot.forward();
    while inventory_controller.getStackInInternalSlot(1) == nil do
        os.sleep(5);
    end
    
    -- Return to origin.
    navigateTo(ASSLINE_LENGTH + 1, 1);
    
    robot.select(1);
    inventory_controller.dropIntoSlot(sides.up, 1);
    return true;
end

local function main()
    if robot.tankCount == 0 then
        print('Need at least 1 tank upgrade.');
        return;
    end

    if robot.inventorySize() == 0 then
        print('Need at least 1 inventory upgrade.');
        return;
    end

    local recipes = table.load('asslineRecipes.data');
    local fluidLocations = table.load('asslineFluidLocations.data');
    
    while true do
        if (inventory_controller.getStackInInternalSlot(1) ~= nil) then
            os.sleep(1); -- sleep 1s for other items to fully load.
            local recipe = matchRecipe(recipes);
            if recipe ~= nil then
                if not loadAssline(recipe, fluidLocations) then
                    return;
                end
            end
        end
        os.sleep(2);
    end
end

main();

