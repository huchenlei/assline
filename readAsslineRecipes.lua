--[[ 
    Read the inventory full of assline datasticks, and save these recipes as lua structuers.
 ]]

dofile('third_party/table_io.lua');
local recipeUtil = require('recipeUtil');

local sides = require('sides');
local component = require('component');
local inventory_controller = component.inventory_controller;

local DATASTICK_LABEL = 'gt.metaitem.01.32708.name';

function readRecipes(side) 
    local recipes = {};

    for i=1, inventory_controller.getInventorySize(side) do
        local datastick = inventory_controller.getStackInSlot(side, i);
        
        if datastick ~= nil and datastick.label == DATASTICK_LABEL then 
            local recipe = {
                inputFluids=datastick.inputFluids,
                inputItems=datastick.inputItems,
                output=datastick.output,
            };
            recipes[recipeUtil.getRecipeKey(recipe)] = recipe;
        end
    end

    return recipes;
end

function readFluids(side)
    local fluids = {};
    local fluid_id = 2;

    for i=1, inventory_controller.getInventorySize(side) do
        local datastick = inventory_controller.getStackInSlot(side, i);
        
        if datastick ~= nil and datastick.label == DATASTICK_LABEL then 
            for _, fluid in ipairs(datastick.inputFluids) do
                local fluidName = fluid[1];
                if fluids[fluidName] == nil then
                    fluids[fluidName] = fluid_id;
                    fluid_id = fluid_id + 1;
                end
            end
        end
    end

    return fluids;    
end

function main()
    table.save(readRecipes(sides.down), 'asslineRecipes.data');
    table.save(readFluids(sides.down), 'asslineFluidLocations.data');
end

main();


