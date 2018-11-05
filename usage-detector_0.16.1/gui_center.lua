local function gui_header_create(parent, job_data)
  local header = parent.add({ type = "flow", name = "header", direction = "horizontal" })
  header.add { type = "button", name = "usage_detector_start", caption = "Start" }
  header.add { type = "button", name = "usage_detector_stop", caption = "Stop" }

  header.add { type = "label", name = "item_label", caption = "Item" }
  local item = header.add { type = "choose-elem-button", name = "item", elem_type = "item" }

  header.add { type = "label", name = "fluid_label", caption = "or Fluid" }
  local fluid = header.add { type = "choose-elem-button", name = "fluid", elem_type = "fluid" }

  if job_data.current_thing then
    if job_data.current_thing.type == "item" then
      item.elem_value = job_data.current_thing.name
    end
    if job_data.current_thing.type == "fluid" then
      fluid.elem_value = job_data.current_thing.name
    end
  end
end

local function create_job_gui(frame, job_name, job_data)
  local section = frame.add { type = "flow", name = job_name, direction = "vertical" }
  gui_header_create(section, job_data)
  section.add { type = "label", name = "job_status", caption = "Not started." }

  section.add({type = "scroll-pane", name = "table_container",
     vertical_scroll_policy = "auto", horizontal_scroll_policy = "never", style = "usage_detector_scroll"})
end

local function create(player, player_data)
  local frame = player.gui.center.add({ type = "frame", name = "usage_detector_center", direction = "vertical" })
  for job_name, job_data in pairs(player_data.jobs) do
    create_job_gui(frame, job_name, job_data)
  end
end

local function round_to_closest(number, precision)
  return math.floor(number / precision + 0.5) * precision
end

local function recreate_table_with_results(section, results, running_time)
  local table_container = section["table_container"]
  local table = table_container.add { type = "table", name = "table", column_count = 7 }
  table.add { type = "label", name = "header_name", caption = "Recipe Name" }
  table.add { type = "label", name = "header_amount", caption = "Amount" }
  table.add { type = "label", name = "header_count", caption = "Times produced" }
  table.add { type = "label", name = "header_sum", caption = "Total used" }
  table.add { type = "label", name = "header_machine_count", caption = "Machines" }
  table.add { type = "label", name = "header_per_second", caption = "Used per second" }
  table.add { type = "label", name = "header_percent", caption = "Used %" }

  local all_sum = 0
  for _, result in pairs(results) do
    all_sum = all_sum + result.amount * result.count
  end

  local running_seconds = running_time / 60
  for recipe_name, result in pairs(results) do
    local name_prefix = "result_" .. recipe_name .. "_"
    local recipe_sum = result.amount * result.count
    table.add { type = "label", name = name_prefix .. "name", caption = recipe_name }
    table.add { type = "label", name = name_prefix .. "amount", caption = result.amount }
    table.add { type = "label", name = name_prefix .. "count", caption = result.count }
    table.add { type = "label", name = name_prefix .. "sum", caption = recipe_sum }
    table.add { type = "label", name = name_prefix .. "machine_count", caption = result.machine_count }
    local used_per_second = recipe_sum / running_seconds
    table.add { type = "label", name = name_prefix .. "per_second", caption = round_to_closest(used_per_second, 0.01) }
    local used_percent = recipe_sum / all_sum * 100
    table.add { type = "label", name = name_prefix .. "percent", caption = round_to_closest(used_percent, 0.01) }
  end
end

local function update_job(player, section_name, job_data)
  local job_gui = player.gui.center.usage_detector_center[section_name]
  if job_gui.table_container["table"] then
    job_gui.table_container.table.destroy()
  end
  local stopped = job_data.stopped_at > job_data.started_at
  local stopped_at = stopped and job_data.stopped_at or game.tick
  local running_time = stopped_at - job_data.started_at
  local running_label = string.format("Running for %d seconds (%d ticks).", math.floor(running_time / 60), running_time)
  local started = game.tick > job_data.started_at and job_data.started_at > 0
  job_gui.job_status.caption = started and running_label or "Not started."

  recreate_table_with_results(job_gui, job_data.results, running_time)
end

local function click(player, event, usage_detector)
  if event.element.name == "usage_detector_start" then
    local section_name = event.element.parent.parent.name
    local job_gui = player.gui.center.usage_detector_center[section_name]
    local current_thing = nil
    if job_gui.header.item.elem_value then
      current_thing = { type = "item", name = job_gui.header.item.elem_value }
    end
    if job_gui.header.fluid.elem_value then
      current_thing = { type = "fluid", name = job_gui.header.fluid.elem_value }
    end
    if not current_thing then
      player.print("[Usage Detector] No item or fluid selected")
      return
    end
    usage_detector.start(player, current_thing, section_name)
  end
  if event.element.name == "usage_detector_stop" then
    local section_name = event.element.parent.parent.name
    usage_detector.stop(player, section_name)
  end
end

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
