-------------------------------------------------
-- Round switch

function BalloonFlight:NextRound(bPrepare)
	local nMap = self.nNextMap
	if nMap then
		self.nNextMap = nil
	else
		if not self.tRemainigMaps or table.size(self.tRemainigMaps) == 0 then
			self.tRemainigMaps = {}
			for n = 1, MAP.SUBMAP_COUNT do
				self.tRemainigMaps[n] = 1
			end
		end

		nMap = table.random(self.tRemainigMaps)
		self.tRemainigMaps[nMap] = nil
	end

	self:SetMap(nMap)

	if bPrepare then
		self.nNextMap = nMap
	else
		self:RespawnAll()
	end
end

-------------------------------------------------
-- Set active map

function BalloonFlight:SetMap(nMap)
	self:SetSpawnPoints(nMap)

	Obstacles:RegisterTriggers(function(hTrigger)
		local sName = hTrigger:GetName()
		return sName:match('_'..nMap)
	end)
end

function BalloonFlight:SetSpawnPoints(nMap)
	local qTargets = Entities:FindAllByClassname('info_target')
	local sTargetName = 'spawnpoint_' .. nMap
	self.qSpawnPoints = {}

	for _, hTarget in ipairs(qTargets) do
		if hTarget:GetName() == sTargetName then
			table.insert(self.qSpawnPoints, hTarget:GetOrigin())
		end
	end
end

-------------------------------------------------
-- Hero pick

function BalloonFlight:StartHeroPick()
	-- Start warm-up round
	self:NextRound(true)
	
	local tPick = require('settings/hero_pick')
	local nEndTime = GameRules:GetGameTime() + tPick.DURATION

	-- Send pick data and hero pool to players
	for nPlayer in Players() do
		SetPlayerJsData(nPlayer, 'HeroPick', {
			bActive = true,
			tHeroes = self:GenHeroPoolForPlayer(nPlayer),
			nEndTime = nEndTime,
		})
	end

	-- listen to hero pick
	self.nHeroPickListener = CustomGameEventManager:RegisterListener('sv_select_hero', function(_, t)
		AddPlayerJsData(t.PlayerID, 'HeroPick', {
			bActive = false,
		})

		self:SetHeroName(t.PlayerID, t.sHero)
		self:RespawnPlayer(t.PlayerID)
	end)

	-- Delay pick ending
	Timer(tPick.DURATION, function()
		self:EndHeroPick()
	end)
end

function BalloonFlight:EndHeroPick()
	-- Unregister pick listener
	if self.nHeroPickListener then
		CustomGameEventManager:UnregisterListener(self.nHeroPickListener)
		self.nHeroPickListener = nil
	end

	-- Hide pick screen & random hero for not picked players
	for nPlayer in Players() do
		if not self:GetHeroName(nPlayer) then
			local tPool = (GetPlayerJsData(nPlayer, 'HeroPick') or {}).tHeroes
			if tPool then
				tPool = table.copy(tPool)
				for n, tHeroData in pairs(tPool) do
					if tHeroData.bLocked then
						tPool[n] = nil
					end
				end

				if table.size(tPool) > 0 then
					local _, tHeroData = table.random(tPool)
					self:SetHeroName(nPlayer, tHeroData.sHero)
				end
			end
		end

		AddPlayerJsData(nPlayer, 'HeroPick', {
			bActive = false,
		})
	end

	-- Start game
	self:NextRound()
end

function BalloonFlight:GenHeroPoolForPlayer(nPlayer)
	local tPick = require('settings/hero_pick')
	local tHeroSettings = tPick.HEROES or {}
	local tHeroes = {}
	local tFullPool
	local tFreePool

	local fUpdatePool = function()
		tFullPool = table.copy(KV.HERO_LIST)
		tFreePool = {}

		for sHero in pairs(tFullPool) do
			local tHeroData = tHeroSettings[sHero]
			if not tHeroData or not tHeroData.PAID_ONLY then
				tFreePool[sHero] = 1
			end
		end
	end

	fUpdatePool()

	for n = 1, 3 do
		local bPaid = (n==3)
		local tPool = bPaid and tFullPool or tFreePool

		if table.size(tPool) < 1 then
			fUpdatePool()
			tPool = bPaid and tFullPool or tFreePool

			if table.size(tPool) < 1 then
				error('Empty pool. Paid: '..tostring(bPaid))
			end
		end

		local sHero = table.random(tPool)
		tFreePool[sHero] = nil
		tFullPool[sHero] = nil

		table.insert(tHeroes, {
			sHero = sHero,
			bLocked = bPaid,
			bPaid = bPaid,
		})
	end

	return tHeroes
end

function BalloonFlight:SetHeroName(nPlayer, sName)
	goc(self, 'tPickedHeroes', {})[nPlayer] = sName
end

function BalloonFlight:GetHeroName(nPlayer)
	return (self.tPickedHeroes or {})[nPlayer]
end

-------------------------------------------------
-- Players respawn

function BalloonFlight:RespawnAll()
	for nPlayer in Players() do
		self:RespawnPlayer(nPlayer)
	end
end

function BalloonFlight:RespawnPlayer(nPlayer)
	if not IsActivePlayer(nPlayer) then
		return
	end

	local vPos = self:NextSpawnPoint()
	local hPlayer = PlayerResource:GetPlayer(nPlayer)

	local hHero = PlayerResource:GetSelectedHeroEntity(nPlayer)
	if exist(hHero) then
		hHero:Destroy()
	end

	hHero = CreateHeroForPlayer(self:GetHeroName(nPlayer) or 'npc_dota_hero_pudge', hPlayer)
	hHero:SetPlayerID(nPlayer)
	hHero:SetOwner(hPlayer)
	hPlayer:SetAssignedHeroEntity(hHero)

	hHero:SetAbsOrigin(vPos)
	
	BalloonController(hHero, {
		FIXED_Y = vPos.y,
	})
end

function BalloonFlight:NextSpawnPoint()
	if not self.qSpawnPoints or #self.qSpawnPoints < 1 then
		error('No spawn points')
	end

	local nMaxSpawnPoint = #self.qSpawnPoints
	self.nSpawnPoint = (self.nSpawnPoint or 0) + 1
	while self.nSpawnPoint > nMaxSpawnPoint do
		self.nSpawnPoint = self.nSpawnPoint - nMaxSpawnPoint
	end

	return self.qSpawnPoints[self.nSpawnPoint]
end