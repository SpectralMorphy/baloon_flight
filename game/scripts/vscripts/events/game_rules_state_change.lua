----------------------------------------------------------------
-- event: game_rules_state_change

----------------------------------------------------------------
-- Gameplay Start

function StartGameplay()
	BalloonFlight:StartHeroPick()
end

----------------------------------------------------------------
-- EventProcessing

return function()
	local fState = ({
		[DOTA_GAMERULES_STATE_PRE_GAME] = StartGameplay,
	})[GameRules:State_Get()]

	if fState then
		fState()
	end
end