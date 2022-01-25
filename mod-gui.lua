local mod_gui = {}
mod_gui.button_style = "mod_gui_button"
mod_gui.frame_style = "non_draggable_frame"

--[[
Hello script explorer, if you are looking to upgrade your mod to use the mod gui, its pretty simple.
Typically you will have something like:
player.gui.left.add{...}
All you will need to do, is change it to:
mod_gui.get_frame_flow(player).add{...}
And for buttons its just the same:
mod_gui.get_button_flow(player).add{...}
It should be as simple as find and replace.
Any other questions please feel free to ask on the modding help forum.
]]

function mod_gui.get_button_flow(player)
  local gui = player.gui.top

  --legacy...
  if gui.mod_gui_button_flow then
    return gui.mod_gui_button_flow
  end

  local frame = gui.mod_gui_top_frame or gui.add{type = "frame", name = "mod_gui_top_frame", direction = "horizontal", style = "quick_bar_window_frame"}
  return frame.mod_gui_inner_frame or frame.add{type = "frame", name = "mod_gui_inner_frame", style = "mod_gui_inside_deep_frame"}
end

function mod_gui.get_frame_flow(player)
  local gui = player.gui.left
  return gui.mod_gui_frame_flow or gui.add{type = "flow", name = "mod_gui_frame_flow", direction = "horizontal", style = "mod_gui_spacing_horizontal_flow"}
end

return mod_gui