function compressRecipe(recipe)
    local m = {};
    for _, inputItem in ipairs(recipe.inputItems) do
        local itemName = inputItem[1];
        local amount = inputItem[2];
        
        if m[itemName] == nil then
            m[itemName] = 0;
        end

        m[itemName] = m[itemName] + amount;
    end

    local compressedRecipe = {};
    for _, inputItem in ipairs(recipe.inputItems) do
        local itemName = inputItem[1];
        local amount = inputItem[2];

        if m[itemName] ~= nil then
            table.insert(compressedRecipe, {itemName, m[itemName]});
            m[itemName] = nil;
        end
    end

    return compressedRecipe;
end

--[[ Return a key that is used to identify recipe in the table. ]]
function getRecipeKey(recipe)
    local compressedRecipe = compressRecipe(recipe);
    local key = {};
    for i = 1, 3 do
        local inputItem = compressedRecipe.inputItems[i];
        local itemName = inputItem[1];
        local amount = inputItem[2];
        key[i] = string.format('%s%i', itemName, amount);
    end
    return table.concat(key);
end


return {
    getRecipeKey=getRecipeKey,
    compressedRecipe=compressedRecipe,
};