-- auto_decon_miners.lua
-- May 2020
-- My shitty softmod version which is buggy

function OarcAutoDeconOnInit(event)
    if (not global.oarc_decon_miners) then
        global.oarc_decon_miners = {}
    end
end

function OarcAutoDeconOnTick(event)
    if event.tick > 10 then
        if (global.oarc_decon_miners and (#global.oarc_decon_miners > 0)) then
            for i,miner in pairs(global.oarc_decon_miners) do
                if ((not miner) or (not miner.valid)) then
                    table.remove(global.oarc_decon_miners, i)
                else
                    if (#miner.surface.find_entities_filtered{
                        area = {
                            {miner.position.x-2, miner.position.y-2}, 
                            {miner.position.x+2, miner.position.y+2}}, 
                            type = "resource", limit = 1} == 0) then
                                miner.order_deconstruction(miner.force)
                            end
                            table.remove(global.oarc_decon_miners, i)
                        end
                    end
                end
            end
        end
        
        
        function OarcAutoDeconOnResourceDepleted(event)
            if (not global.oarc_decon_miners) then
                global.oarc_decon_miners = {}
            end
            if (event.entity and event.entity.position and event.entity.surface) then
                
                if event.entity.name == "uranium-ore" then return end
                
                
                local nearby_miners = event.entity.surface.find_entities_filtered{
                    area = {
                        {event.entity.position.x-1, event.entity.position.y-1},
                        {event.entity.position.x+1, event.entity.position.y+1}
                    },
                    name = {"burner-mining-drill", "electric-mining-drill"}
                }
                
                
                
                
                for i,v in pairs(nearby_miners) do
                    table.insert(global.oarc_decon_miners, v)
                end
            end
        end
        