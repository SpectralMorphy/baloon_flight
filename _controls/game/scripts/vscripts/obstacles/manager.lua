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
	local vCenter = hTrigger:GetOrigin()
	local vMax = tBounds.Maxs + vCenter
	local vMin = tBounds.Mins + vCenter
	local tEdges = {
		l = vMin.x,
		b = vMin.z,
		r = vMax.x,
		t = vMax.z,
	}
	table.print( tEdges )

	Obstacle( tEdges, tMaterial )
end

function Obstacles:FindCollisions( v1, v2, nRadius )
	local tCollisions = {}
	local bHas = false

	local function fDistance( v )
		return math.abs( v1.x - v.x )
	end

	for _, hObstacle in ipairs( self.qList ) do
		local nCollision, vPos = hObstacle:FindCollision( v1, v2, nRadius )
		if nCollision then
			bHas = true
			local nType = hObstacle:GetType()
			local qCollisions = goc( tCollisions, nType )
			local nDistance = fDistance( vPos )

			local i = 1
			while qCollisions[i] and fDistance( qCollisions[i].vPos ) < nDistance do
				i = i + 1
			end

			table.insert( qCollisions, i, {
				hObstacle = hObstacle,
				nCollision = nCollision,
				vPos = vPos,
			})
		end
	end

	if bHas then
		return tCollisions
	end
end