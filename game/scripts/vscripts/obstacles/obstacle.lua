Obstacle = Obstacle or class{}

Obstacle.TYPE = {
	SOLID = 1,
	SPACE = 2,
}

Obstacle.COLLISION = {
	TOP = 1,
	LEFT = 2,
	RIGHT = 3,
	BOT = 4,
}

------------------------------------------------------------------
-- Constructor with bounds and material settings

function Obstacle:constructor( tEdges, tMaterial )
	self.tEdges = tEdges
	self.MATERIAL = table.overlay( MATERIAL.DEFAULT, tMaterial )

	table.insert( Obstacles.qList, self )
end

------------------------------------------------------------------
-- Get material info

function Obstacle:GetMaterial()
	return table.deepcopy( self.MATERIAL )
end

function Obstacle:GetType()
	return self.MATERIAL.TYPE
end

------------------------------------------------------------------
-- Check collision between 2 points

function Obstacle:FindCollision( v1, v2, nRadius )
	local function fIntersect( x1, y1, x2, y2, x, yMin, yMax )
		if x < x1 or x2 <= x1 then
			return false
		end

		local nPct = ( x - x1 ) / ( x2 - x1 )
		if nPct >= 0 and nPct <= 1 then
			local y = y1 + ( y2 - y1 ) * nPct
			if y + nRadius > yMin and y - nRadius < yMax then
				return x, y
			end
		end

		return false
	end

	local x, z = fIntersect( v1.x, v1.z, v2.x, v2.z, self.tEdges.l - nRadius, self.tEdges.b, self.tEdges.t )
	if x then
		return Obstacle.COLLISION.LEFT, Vector( x, 0, z ), Vector( self.tEdges.l, 0, z )
	end

	local x, z = fIntersect( v2.x, v2.z, v1.x, v1.z, self.tEdges.r + nRadius, self.tEdges.b, self.tEdges.t )
	if x then
		return Obstacle.COLLISION.RIGHT, Vector( x, 0, z ), Vector( self.tEdges.r, 0, z )
	end

	local z, x = fIntersect( v2.z, v2.x, v1.z, v1.x, self.tEdges.t + nRadius, self.tEdges.l, self.tEdges.r )
	if x then
		return Obstacle.COLLISION.TOP, Vector( x, 0, z ), Vector( x, 0, self.tEdges.t )
	end

	local z, x = fIntersect( v1.z, v1.x, v2.z, v2.x, self.tEdges.b - nRadius, self.tEdges.l, self.tEdges.r )
	if x then
		return Obstacle.COLLISION.BOT, Vector( x, 0, z ), Vector( x, 0, self.tEdges.b )
	end
end

------------------------------------------------------------------
-- Is player colliding with this obstacle

function Obstacle:IsColliding( vPos, nRadius )
	return vPos.x + nRadius >= self.tEdges.l and vPos.x - nRadius <= self.tEdges.r
		and vPos.z + nRadius >= self.tEdges.b and vPos.z - nRadius <= self.tEdges.t
end