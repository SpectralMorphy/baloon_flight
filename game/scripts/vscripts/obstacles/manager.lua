Obstacles = Obstacles or {}

Obstacles.qList = Obstacles.qList or {}

------------------------------------------------------------------
-- Create obstacles from material triggers

function Obstacles:RegisterTriggers()
	local qTriggers = Entities:FindAllByClassname('trigger_dota')
	
	for _, hTrigger in ipairs( qTriggers ) do
		local sName = hTrigger:GetName()
		if sName:match('^material_') then
			local sMaterial = sName:gsub( 'material_', '' )
			local tMaterial = MATERIAL[ sMaterial ]
			self:CreateFromTrigger( hTrigger, tMaterial )
		end
	end
end

------------------------------------------------------------------
-- Create obstacle from trigger

function Obstacles:CreateFromTrigger( hTrigger, tMaterial )
	local tBounds = hTrigger:GetBounds()
	local vCenter = hTrigger:GetCenter()
	local vMax = tBounds.Maxs + vCenter
	local vMin = tBounds.Mins + vCenter
	local tEdges = {
		l = vMin.x,
		b = vMin.z,
		r = vMax.x,
		t = vMax.z,
	}

	Obstacle( tEdges, tMaterial )
end

function Obstacles:FindCollisions( v1, v2 )
	local tCollisions = {}
	local bHas = false

	local function fDistance( v )
		return math.abs( v1.x - v.x )
	end

	for _, hObstacle in ipairs( self.qList ) do
		local nCollision, vPos = hObstacle:FindCollision( v1, v2 )
		if nCollision then
			local nType = hObstacle:GetType()
			local tConcurent = tCollisions[ nType ]
			if not tConcurent or fDistance( tConcurent.vPos ) > fDistance( vPos ) then
				bHas = true
				tCollisions[ nType ] = {
					tMaterial = hObstacle:GetMaterial(),
					nCollision = nCollision,
					vPos = vPos,
				}
			end
		end
	end

	if bHas then
		return tCollisions
	end
end