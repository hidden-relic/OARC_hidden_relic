local player = game.player
local test_frame = player.gui.screen.add {
    name="test_frame",
    type="frame",
    direction="vertical"
}
test_frame.auto_center=true
local test_flow = test_frame.add {
    type = "flow",
    direction = "vertical"
}
local test_preview = test_flow.add{
    type = "entity-preview"
}
test_preview.entity = player.selected