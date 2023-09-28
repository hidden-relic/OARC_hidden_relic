local function walk_tech(tech, t)
    local t = t or {tech}
    local tech = game.technology_prototypes[tech]
    if table_size(tech.prerequisites) > 0 then
    for name, data in pairs(tech.prerequisites) do
    table.insert(t, name)
end
for name, data in pairs(tech.prerequisites) do
    t = walk_tech(name, t)
end
end
if table_size(tech.prerequisites) == 0 then
    table.insert(t, tech.name)
end
return t
end
local t = walk_tech("mining-productivity-4")
local r = {}
for i=#t, 1, -1 do
    table.insert(r, t[i])
end
local nt = {}
for i=1, #r do
    nt[r[i]] = i
end
local nnt = {}
for k, v in pairs(nt) do
    table.insert(nnt, k)
end
game.player.force.research_queue = nnt

for _, tech in pairs(game.get_filtered_technology_prototypes{{filter="has-prerequisites", invert=true}}) do
    game.player.force.
end

/sc
for _, tech in pairs(game.get_filtered_technology_prototypes{
        {filter="research-unit-ingredient", ingredient="military-science-pack", invert=true},
        {filter="research-unit-ingredient", ingredient="space-science-pack", invert=true, mode="and"},
        {filter="research-unit-ingredient", ingredient="production-science-pack", invert=true, mode="and"},
        {filter="research-unit-ingredient", ingredient="utility-science-pack", invert=true, mode="and"},
        {filter="research-unit-ingredient", ingredient="chemical-science-pack", invert=true, mode="and"}
}) do
    game.player.force.add_research(tech.name)
end