local tables = require("__flib__.table")

local function expected_amount(product)
    local expected = product.amount
    if not expected then
      expected = (product.amount_min + product.amount_max) / 2.0
    end
    local probability = product.probability or 1
  
    return expected * probability
  end
  
  return function(source, player_info)
    local player_settings = player_info.settings
    local ingredients_multiplier = player_settings["copy-paste-recipe-signals-ingredient-multiplier"].value
    local products_multiplier = player_settings["copy-paste-recipe-signals-product-multiplier"].value
    local add_ticks = player_settings["copy-paste-recipe-signals-include-ticks"].value
    local add_seconds = player_settings["copy-paste-recipe-signals-include-seconds"].value
    local time_includes_modules = player_settings["copy-paste-recipe-time-includes-modules"].value
    local item_count_as_request_chest = player_settings["copy-paste-recipe-copy-item-count-as-request-chest"].value

    if source.prototype.type == "assembling-machine" or source.prototype.type == "furnace" then
        local recipe = source.get_recipe()
        if not recipe and source.prototype.type == "furnace" then
          recipe = source.previous_recipe
        end
        if not recipe then
            return nil
        end
        local speed_adjustment = time_includes_modules and source.crafting_speed or 1

        -- Calculation of the ingredients/products multiplier 
        -- for the function of simulating copying to the request chest
        -- https://wiki.factorio.com/Copy_and_paste#Entity_settings
        local product_per30s_multiplier = 1
        if item_count_as_request_chest then
            product_per30s_multiplier = (30 * source.crafting_speed) / recipe.energy
        end

        local signals = {}
        if ingredients_multiplier ~= 0 then
          for _, ingredient in pairs(recipe.ingredients) do
            table.insert(signals, {
              signal = {
                type = ingredient.type,
                name = ingredient.name
              },
              --in vanilla factorio, the copy-pasting feature cannot copy less than the amount of the ingredient (this also prevents items equal to 0)
              count = math.max(ingredient.amount * product_per30s_multiplier, ingredient.amount) * ingredients_multiplier
            })
          end
        end
        if products_multiplier ~= 0 then
          for _, product in pairs(recipe.products) do
            local expected = expected_amount(product)
            table.insert(signals, {
              signal = {
                type = product.type,
                name = product.name
              },
              --same as in the ingredient
              count = math.max(expected * product_per30s_multiplier, expected) * products_multiplier
            })
          end
        end
        if add_ticks then
          table.insert(signals, {
            signal = { type = "virtual", name = "signal-T" },
            count = recipe.energy * 60 / speed_adjustment
          })
        end
        if add_seconds then
          table.insert(signals, {
            signal = { type = "virtual", name = "signal-S" },
            count = recipe.energy / speed_adjustment
          })
        end
        return signals
    end
    if source.prototype.type == "constant-combinator" then
        local result = source.get_or_create_control_behavior().parameters
        result = tables.filter(result, function(v) return v.signal.name ~= nil end, true)
        return result
    end
end
