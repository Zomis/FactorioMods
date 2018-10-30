local function gui_header_create(parent)
  local header = parent.add({ type = "flow", name = "header", direction = "horizontal" })
  header.add { type = "button", name = "usage_detector_start", caption = "Start" }
  header.add { type = "button", name = "usage_detector_stop", caption = "Stop" }

  header.add { type = "label", name = "item_label", caption = "Item" }
  local item = header.add { type = "choose-elem-button", name = "item", elem_type = "item" }

  header.add { type = "label", name = "fluid_label", caption = "or Fluid" }
  local fluid = header.add { type = "choose-elem-button", name = "fluid", elem_type = "fluid" }
  -- TODO: If a job exists, load it
end

local function create(player)
  local frame = player.gui.center.add({ type = "frame", name = "usage_detector_center", direction = "vertical" })

  local section = frame.add { type = "flow", name = "section0", direction = "vertical" }
  gui_header_create(section)
  section.add { type = "label", name = "job_status", caption = "Not started." }

  local table_container = section.add { type = "flow", name = "table_container", direction = "horizontal" }
	table_container.style.minimal_width = 700
	table_container.style.minimal_height = 600
end

local function recreate_table_with_results(section, results)
  local table_container = section["table_container"]
  local table = table_container.add { type = "table", name = "table", column_count = 7 }
  table.add { type = "label", name = "header_name", caption = "Recipe Name" }
  table.add { type = "label", name = "header_amount", caption = "Amount" }
  table.add { type = "label", name = "header_count", caption = "Times produced" }
  table.add { type = "label", name = "header_sum", caption = "Total used" }
  table.add { type = "label", name = "header_machine_count", caption = "Machine count" }
  table.add { type = "label", name = "header_per_second", caption = "Used per second" }
  table.add { type = "label", name = "header_percent", caption = "Used %" }

  local sum = 0
  for _, result in pairs(results) do
    sum = sum + result.amount * result.count
  end

  for recipe_name, result in pairs(results) do
    local name_prefix = "result_" .. recipe_name .. "_"
    table.add { type = "label", name = name_prefix .. "name", caption = recipe_name }
    table.add { type = "label", name = name_prefix .. "amount", caption = result.amount }
    table.add { type = "label", name = name_prefix .. "count", caption = result.count }
    table.add { type = "label", name = name_prefix .. "sum", caption = result.amount * result.count }
    table.add { type = "label", name = name_prefix .. "machine_count", caption = result.machine_count }
    table.add { type = "label", name = name_prefix .. "per_second", caption = "" }
    table.add { type = "label", name = name_prefix .. "percent", caption = "" }
  end
end

local function update_job(player, section_name, job_data)
  local job_gui = player.gui.center.usage_detector_center[section_name]
  if job_gui.table_container["table"] then
    job_gui.table_container.table.destroy()
  end
  local stopped_at = job_data.stopped_at > job_data.started_at and job_data.stopped_at or game.tick
  local running_label = string.format("Running for %d ticks.", stopped_at - job_data.started_at)
  job_gui.job_status.caption = job_data.running and running_label or "Not started."

  recreate_table_with_results(job_gui, job_data.results)
end

local function click(player, event, usage_detector)
  if event.element.name == "usage_detector_start" then
    local section_name = event.element.parent.parent.name
    usage_detector.start(player, { type = "item", name = "iron-plate" }, section_name)
  end
  if event.element.name == "usage_detector_stop" then
    local section_name = event.element.parent.parent.name
    usage_detector.stop(player, section_name)
  end
end

-- TODO: When changing item, erase fluid, and vice-versa.

local function update_gui(player, player_data)
  if not player.gui.center["usage_detector_center"] then
    return
  end
  for section_name, job_data in pairs(player_data.jobs) do
    if not player.gui.center.usage_detector_center[section_name] then
      return
    end
    update_job(player, section_name, job_data)
  end
end

return {
  create = create,
  click = click,
  update_gui = update_gui
}
