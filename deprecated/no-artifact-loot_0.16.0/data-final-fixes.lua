local ALIEN_ARTIFACT = "alien-artifact"
local ALIEN_ARTIFACT_LENGTH = string.len(ALIEN_ARTIFACT)

local SMALL_ALIEN_ARTIFACT = "small-alien-artifact"
local SMALL_ALIEN_ARTIFACT_LENGTH = string.len(SMALL_ALIEN_ARTIFACT)

local function is_alien_artifact(loot)
  local has_name = string.sub(loot.item, 1, ALIEN_ARTIFACT_LENGTH) == ALIEN_ARTIFACT
  local has_small_name = string.sub(loot.item, 1, SMALL_ALIEN_ARTIFACT_LENGTH) == SMALL_ALIEN_ARTIFACT
  return has_name or has_small_name
end

local function delete_artifacts_from(loot)
  local move_to = 1
  local count = #loot

  for i = 1, count do
    if not is_alien_artifact(loot[i]) then
      if i ~= move_to then
        loot[move_to] = loot[i]
        loot[i] = nil
      end
      move_to = move_to + 1
    else
      loot[i] = nil
    end
  end
end

local function check_for_loot(unit_type)
  for _, unit in pairs(unit_type) do
    if unit.loot then
      local removed_count = 0
      delete_artifacts_from(unit.loot)

      for i, loot in ipairs(unit.loot) do
        if is_alien_artifact(loot) then
          table.remove(loot, i - removed_count)
          removed_count = removed_count + 1
        end
      end
    end
  end
end

for _, raw_table in pairs(data.raw) do
  -- Theoretically only data.raw.turret, data.raw["unit-spawner"], data.raw.unit is needed.
  check_for_loot(raw_table)
end
