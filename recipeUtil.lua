function compressInputItems(inputItems)
    local m = {};
    for _, inputItem in ipairs(inputItems) do
        local itemName = inputItem[1];
        local amount = inputItem[2];
        
        if m[itemName] == nil then
            m[itemName] = 0;
        end

        m[itemName] = m[itemName] + amount;
    end

    local compressedInputItems = {};
    for _, inputItem in ipairs(inputItems) do
        local itemName = inputItem[1];
        local amount = inputItem[2];

        if m[itemName] ~= nil then
            table.insert(compressedInputItems, {itemName, m[itemName]});
            m[itemName] = nil;
        end
    end

    return compressedInputItems;
end

--[[ Return a key that is used to identify recipe in the table. ]]
function getRecipeKey(recipe)
    local compressedInputItems = compressInputItems(recipe.inputItems);
    
    local key = {};
    for i = 1, 3 do
        local inputItem = compressedInputItems[i];
        local itemName = inputItem[1];
        local amount = inputItem[2];
        key[i] = string.format('%s%i', itemName, amount);
    end
    return table.concat(key);
end


return {
    getRecipeKey=getRecipeKey,
};