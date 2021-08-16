BalloonController = BalloonController or class({})

------------------------------------------------------------
-- Apply custom physics to unit and link controller interface to it.

function BalloonController:constructor( hUnit )
    self.bNull = false
    self.bMoveLeft = false
    self.bMoveRight = false
    self.nDirX = 0
    self.nDirZ = -1
    self.vVel = Vector( 0, 0, 0 )
    self.vAcc = Vector( 0, 0, 0 )
    self.nBlockZ = 0
    self.nBlockX = 0
    self.tSpaces = {}
    self.nSpaces = 0
	
	self.tSolids = {}
	self.nSolids = {}
	for sName, nCol in pairs( Obstacle.COLLISION ) do
		self.tSolids[ nCol ] = {}
		self.nSolids[ nCol ] = 0
	end

	self:ApplySettings({})

    self.hUnit = hUnit
    hUnit.Balloon = self

    self.hMod = hUnit:AddNewModifier( hUnit, nil, 'modifier_balloon', {} )

    if not exist( self.hMod ) then
        self:Destroy()
        error( 'BalloonController: Failed to apply balloon modifier to unit ' .. hUnit:GetUnitName() )
    end

	local tUnitKV = KV.HEROES[ hUnit:GetUnitName() ]
	if tUnitKV then
		self.sWalkModel = tUnitKV.Model
		self.nWalkModelScale = tUnitKV.ModelScale
		self.sFlyModel = tUnitKV.FlyModel
		self.nFlyModelScale = tUnitKV.FlyModelScale
		self.nWalkAnimIdle = _G[ tUnitKV.WalkAnimIdle ]
		self.nWalkAnimRun = _G[ tUnitKV.WalkAnimRun ]
		self.nWalkAnimFall = _G[ tUnitKV.WalkAnimFall ]
		self.nFlyAnimIdle = _G[ tUnitKV.FlyAnimIdle ]
		self.nFlyAnimRun = _G[ tUnitKV.FlyAnimRun ]
	end
	
	local vPos = self.hUnit:GetOrigin()
	vPos.y = self.CONST.FIXED_Y
    self.vOldPos = vPos
	self:SetPos( vPos )

    self:StopMove()
	self.sForm = 'FLY'
	self:StartWalk()
	self:SetFalling( false )
end

------------------------------------------------------------
-- Destroying

function BalloonController:IsNull()
    return self.bNull
end

function BalloonController:Destroy()
    self.bNull = true

    if exist( self.hMod ) then
        self.hMod:Destroy()
    end

    if exist( self.hUnit ) then
        self.hUnit.Balloon = nil
    end
end

------------------------------------------------------------
-- Apply physics settings

function BalloonController:ApplySettings( t )
	self.CONST = table.overlay( PHYSICS.DEFAULT, t )
end

------------------------------------------------------------
-- Get current position

function BalloonController:GetPos()
    return self.vPos * 1
end

------------------------------------------------------------
-- Set current position

function BalloonController:SetPos( vPos )
	if not exist( self ) or not exist( self.hUnit ) then
        return
    end

    self.vPos = vPos * 1
    self.hUnit:SetAbsOrigin( vPos )
end

------------------------------------------------------------
-- Update horizontal postion

function BalloonController:UpdateHorizontal( nTimeDelta )
	if not exist( self ) or not exist( self.hUnit ) then
        return
    end

	print('upd',self.hUnit)

    local vPos = self:GetPos()
	local nMaxVel = self:GetMaxSpeedX()

    self:UpdateAccX()

	local nOldVelX = self.vVel.x
	self.vVel.x = self.vVel.x + self.vAcc.x * nTimeDelta

	if self.nDirX == 0 then
		if ( nOldVelX <= 0 and self.vVel.x > 0 )
		or ( nOldVelX >= 0 and self.vVel.x < 0 ) then
			self.vVel.x = 0
		end
	else
		local nAbsVelX = math.abs( self.vVel.x )
		local nAbsOldVelX = math.abs( nOldVelX )
		if nAbsVelX > 0 and self.nDirX == self.vVel.x / nAbsVelX then
			if ( nAbsOldVelX <= nMaxVel and nAbsVelX > nMaxVel )
			or ( nAbsOldVelX >= nMaxVel and nAbsVelX < nMaxVel ) then
				self.vVel.x = self.nDirX * nMaxVel
			end
		end
	end

	if self.vVel.x > 0 and self.nSolids[ Obstacle.COLLISION.LEFT ] > 0 then
		self.vVel.x = 0
	elseif self.vVel.x < 0 and self.nSolids[ Obstacle.COLLISION.RIGHT ] > 0 then
		self.vVel.x = 0
	end

    vPos.x = vPos.x + self.vVel.x * nTimeDelta
	vPos.y = self.CONST.FIXED_Y
    self:SetPos( vPos )
end

------------------------------------------------------------
-- Update vertical postion

function BalloonController:UpdateVertical( nTimeDelta )
	if not exist( self ) or not exist( self.hUnit ) then
        return
    end

    local vPos = self:GetPos()

    self:UpdateAccZ()

	local nOldVelZ = self.vVel.z
    self.vVel.z = self.vVel.z + self.vAcc.z * nTimeDelta

	if self.nDirZ == 1 then
		if self.sForm == 'WALK' then
			if self.nSolids[ Obstacle.COLLISION.TOP ] > 0 then
				self:Jump()
			end
		else
			if ( nOldVelZ <= self.CONST.MAX_VEL_RISE and self.vVel.z > self.CONST.MAX_VEL_RISE )
			or ( nOldVelZ >= self.CONST.MAX_VEL_RISE and self.vVel.z < self.CONST.MAX_VEL_RISE ) then
				self.vVel.z = self.CONST.MAX_VEL_RISE
			end
		end
	else
		if ( nOldVelZ <= self.CONST.MAX_VEL_FALL and self.vVel.z > self.CONST.MAX_VEL_FALL )
		or ( nOldVelZ >= self.CONST.MAX_VEL_FALL and self.vVel.z < self.CONST.MAX_VEL_FALL ) then
			self.vVel.z = self.CONST.MAX_VEL_FALL
		end
	end

	if self.vVel.z > 0 and self.nSolids[ Obstacle.COLLISION.BOT ] > 0 then
		self.vVel.z = 0
	elseif self.vVel.z < 0 and self.nSolids[ Obstacle.COLLISION.TOP ] > 0 then
		self.vVel.z = 0
	end

    vPos.z = vPos.z + self.vVel.z * nTimeDelta

    self:SetPos( vPos )

    self:UpdateCollision()
end

------------------------------------------------------------
-- Get const based on current form

function BalloonController:GetMaxSpeedX()
	if self.sForm == 'WALK' then
		return self.CONST.WALK_MAX_SPEED
	end
	return self.CONST.MAX_VEL_X
end

function BalloonController:GetAccX()
	if self.sForm == 'WALK' then
		return self.CONST.WALK_ACC
	end
	return self.CONST.ACC_X
end

function BalloonController:GetAccInterpX()
	if self.sForm == 'WALK' then
		return self.CONST.WALK_ACC_INTERP
	end
	return self.CONST.ACC_X_INTERP
end

function BalloonController:GetInterpMinSpeedX()
	if self.sForm == 'WALK' then
		return self.CONST.WALK_INTERP_MIN_SPEED
	end
	return self.CONST.MIN_VEL_X_INTERP
end

------------------------------------------------------------
-- Calculate x acceleration

function BalloonController:UpdateAccX()
	if self:IsBlockedControlX() then
		self.vAcc.x = 0
		return
	end

	if self.nDirX == 0 then
		if self.vVel.x == 0 then
			self.vAcc.x = 0
		elseif self.vVel.x > 0 then
			self.vAcc.x = -self:GetAccX()
		elseif self.vVel.x < 0 then
			self.vAcc.x = self:GetAccX()
		end
	else
		local nVelOrient = math.max( 0, self.vVel.x * self.nDirX )
		local nInterp = Interp( self:GetAccInterpX(), nVelOrient, self:GetInterpMinSpeedX(), self:GetMaxSpeedX() )
		self.vAcc.x = self.nDirX * self:GetAccX() * nInterp
	end
end

------------------------------------------------------------
-- Calculate z acceleration

function BalloonController:UpdateAccZ()
	if self.vVel.z < -self.CONST.MAX_VEL_FALL then
		self.vAcc.z = self.CONST.ACC_FALL
	elseif self.sForm == 'FLY' and not self:IsBlockedControlZ() and self.nDirZ == 1 then
		local nInterp = Interp( self.CONST.ACC_RISE_INTERP, self.vVel.z, self.CONST.MIN_VEL_RISE_INTERP, self.CONST.MAX_VEL_RISE )
		self.vAcc.z = self.CONST.ACC_RISE * nInterp
    else
        self.vAcc.z = -self.CONST.ACC_FALL
    end
end

------------------------------------------------------------
-- Process collisions between 2 consecutive position

function BalloonController:UpdateCollision()
    local vPos = self:GetPos()
    local vCenter = self:GetCenter( vPos )
    local tCollisions = Obstacles:FindCollisions( self:GetCenter( self.vOldPos ), vCenter, self.CONST.HITBOX_RADIUS )
	
	local fAddCollidng = function( t, hObstacle, fAdd )
		if not t[ hObstacle ] then
			t[ hObstacle ] = true
			fAdd()
		end
	end

	local fCheckCollidings = function( t, fRemove )
		for hObstacle in pairs( t ) do
			if not hObstacle:IsColliding( vCenter, self.CONST.HITBOX_RADIUS ) then
				t[ hObstacle ] = nil
				fRemove()
			end
		end
	end

    if tCollisions then
        --------------------------------------------------------
        -- Solid collision

        local q = tCollisions[ Obstacle.TYPE.SOLID ]
        if q then
            local t = q[1]
            local vColPos = self:CenterToPos( t.vPos )
            local tMat = t.hObstacle:GetMaterial()
			local sSide = ( t.nCollision == Obstacle.COLLISION.BOT and 'BOT' )
				or ( t.nCollision == Obstacle.COLLISION.TOP and 'TOP' ) or 'SIDE' 
			local sAx = ( t.nCollision == Obstacle.COLLISION.BOT or t.nCollision == Obstacle.COLLISION.TOP ) and 'z' or 'x'
			local nAcc = ( t.nCollision == Obstacle.COLLISION.BOT and self.CONST.ACC_RISE )
				or ( t.nCollision == Obstacle.COLLISION.TOP and self.CONST.ACC_FALL ) or self:GetAccX()
			local bPositive = ( t.nCollision == Obstacle.COLLISION.LEFT or t.nCollision == Obstacle.COLLISION.BOT ) 
			local nBounce = tMat[ sSide .. '_BOUNCE' ]
			local qEvents = tMat[ sSide .. '_EVENTS' ]
			local bImpact = false

			fAddCollidng( self.tSolids[ t.nCollision ], t.hObstacle, function()
				self.nSolids[ t.nCollision ] = self.nSolids[ t.nCollision ] + 1
			end )

			for _, sEvent in ipairs( qEvents ) do
				if sEvent == 'IMPACT' then
					if math.abs( self.vVel[ sAx ] ) >= self.CONST.IMPACT_SPEED then
						bImpact = true
						self:StartWalk()
					end
				end
				
				if sEvent == 'WALK' then
					if not bImpact then
						nBounce = 0
						self:StartWalk()
						self:SetFalling( false )
					end
				end
			end

			local nPositive = bPositive and -1 or 1
			local nVel = self.vVel[ sAx ] * nPositive
			local nPos = vPos[ sAx ]
			local nColPos = vColPos[ sAx ]
			nVel = math.max( 0, nVel, -nVel * nBounce )
			if nVel < nAcc * 0.04 then
				self.vVel[ sAx ] = 0
				vPos[ sAx ] = nColPos
			else
				self.vVel[ sAx ] = nVel * nPositive
				vPos[ sAx ] = nColPos + math.max( 0, ( nColPos - nPos ) * nPositive ) * nBounce * nPositive
			end

            self:SetPos( vPos )
            self.vOldPos = vColPos

			if not bImpact and t.nCollision == Obstacle.COLLISION.TOP and self.sForm == 'WALK' and self.nDirZ == 1 then
				self:Jump()
			end

            self:UpdateCollision()
            return
        end

        --------------------------------------------------------
        -- Space collision

        q = tCollisions[ Obstacle.TYPE.SPACE ]
        if q then
            for _, t in pairs( q ) do
                fAddCollidng( self.tSpaces, t.hObstacle, function()
                    self.nSpaces = self.nSpaces + 1
                    self:BlockControlZ( true )
                end )
            end
        end
    end

    ------------------------------------------------------
    -- Removing colliders

    fCheckCollidings( self.tSpaces, function()
		self.nSpaces = self.nSpaces - 1

		Timer( hObstacle.MATERIAL.DISABLE_TIME, function()
			self:BlockControlZ( false )
		end )
	end )

	for _, nCol in pairs( Obstacle.COLLISION ) do
		fCheckCollidings( self.tSolids[ nCol ], function()
			self.nSolids[ nCol ] = self.nSolids[ nCol ] - 1
		end )
	end

	if self.sForm == 'WALK' then
		self:SetFalling( self.nSolids[ Obstacle.COLLISION.TOP ] < 1 )
	end

    ------------------------------------------------------
    -- Players collision

    local qHeroes = FindAllHeroes()
    for _, hHero in pairs( qHeroes ) do
        local other = hHero.Balloon
        if hHero ~= self.hUnit and exist( other ) then
            local vPos1 = vCenter
            local vPos2 = other:GetCenter()
            local nColDistance = self.CONST.HITBOX_RADIUS + other.CONST.HITBOX_RADIUS
            local vDelta = vPos1 - vPos2; vDelta.y = 0
            local nDistance = #vDelta

            if nDistance <= nColDistance
			and ( ( self.vVel.x - other.vVel.x ) * ( other.vPos.x - self.vOldPos.x ) > 0
			or ( self.vVel.z - other.vVel.z ) * ( other.vPos.z - self.vOldPos.z ) > 0 ) then

                -------------------------------------------------
                -- Collision physics 1

                local m1 = self.CONST.MASS
                local m2 = other.CONST.MASS
                local m = m1 + m2

				local dvx = self.vVel.x - other.vVel.x
				local dvy = self.vVel.z - other.vVel.z
				local t = 0

				if dvx ~= 0 or dvy ~= 0 then
					local dsx = vPos1.x - vPos2.x
					local dsy = vPos1.z - vPos2.z
					local a = dvx^2 + dvy^2
					local b = 2 * ( dvx*dsx + dvy*dsy )
					local c = dsx^2 + dsy^2 - (nColDistance+1)^2
					t = -( b + math.sqrt( b^2 - 4*a*c ) ) / ( 2*a )
					t = tonumber( tostring( t ) )
					print(t)
					if t then
						vPos1 = vPos1 + self.vVel * t
						vPos2 = vPos2 + other.vVel * t
					end
				end

                for _, sAx in pairs{'x','z'} do
                    local s1 = self.vVel[ sAx ]
                    local s2 = other.vVel[ sAx ]
                    self.vVel[ sAx ] = ( 2 * m2 * s2 + s1 * ( m1 - m2 ) ) / m
                    other.vVel[ sAx ] = ( 2 * m1 * s1 + s2 * ( m2 - m1 ) ) / m
                end

				self:SetPos( self:CenterToPos( vPos1 - self.vVel * t ) )
				other:SetPos( other:CenterToPos( vPos2 - other.vVel * t ) )
            end
        end
    end
    
    self.vOldPos = vPos * 1
end

------------------------------------------------------------
-- Convert between hitbox center and unit position

function BalloonController:GetCenter( vPos )
    return ( vPos or self:GetPos() ) + Vector( 0, 0, self.CONST.HITBOX_RADIUS )
end

function BalloonController:SetByCenter( vPos )
    self:SetPos( self:CenterToPos( vPos ) )
end

function BalloonController:CenterToPos( vPos )
    return vPos - Vector( 0, 0, self.CONST.HITBOX_RADIUS )
end

------------------------------------------------------------
-- X axis movement controls

function BalloonController:MoveLeft( bEnabled )
    if bEnabled then
        self.bMoveLeft = true
        self:StartMoveLeft()
    else
        self.bMoveLeft = false
        if self.bMoveRight then
            self:StartMoveRight()
        else
            self:StopMove()
        end
    end
end

function BalloonController:MoveRight( bEnabled )
    if bEnabled then
        self.bMoveRight = true
        self:StartMoveRight()
    else
        self.bMoveRight = false
        if self.bMoveLeft then
            self:StartMoveLeft()
        else
            self:StopMove()
        end
    end
end

function BalloonController:StartMoveLeft()
    self.nDirX = -1
	if not self:IsBlockedControlX() then
		self:TurnLeft()
	end
end

function BalloonController:StartMoveRight()
    self.nDirX = 1
	if not self:IsBlockedControlX() then
		self:TurnRight()
	end
end

function BalloonController:StopMove()
    self.nDirX = 0
    self:UpdateAnimation()
end

------------------------------------------------------------
-- Z axis movement controls

function BalloonController:MoveUp( bEnabled )
    if bEnabled then
        self.nDirZ = 1
    else
        self.nDirZ = -1
    end
end

------------------------------------------------------------
-- Enter walking form

function BalloonController:StartWalk()
	self.nWalkEndTime = GameRules:GetGameTime() + self.CONST.WALK_TIME

	if self.sForm == 'WALK' then
		return
	end
	self.sForm = 'WALK' 

	if not exist( self.hUnit ) then
		return
	end

	if self.nWalkModelScale then
		self.hUnit:SetModelScale( self.nWalkModelScale )
	end

	if self.sWalkModel then
		self.hUnit:SetOriginalModel( self.sWalkModel )
		self.hUnit:SetModel( self.sWalkModel )

		self:UpdateAnimation()
	end
end

------------------------------------------------------------
-- Enter flying form

function BalloonController:Jump()
	if GameRules:GetGameTime() >= self.nWalkEndTime then
		self.vVel.z = self.CONST.JUMP_SPEED
		self:StartFly()
	end
end

function BalloonController:StartFly()
	if self.sForm == 'FLY' then
		return
	end
	self.sForm = 'FLY'

	if not exist( self.hUnit ) then
		return
	end

	if self.nFlyModelScale then
		self.hUnit:SetModelScale( self.nFlyModelScale )
	end

	if self.sFlyModel then
		self.hUnit:SetOriginalModel( self.sFlyModel )
		self.hUnit:SetModel( self.sFlyModel )

		self:UpdateAnimation()
	end
end

------------------------------------------------------------
-- Start falling anim

function BalloonController:SetFalling( bFalling )
	if self.bFalling == bFalling then
		return
	end
	self.bFalling = bFalling

	self:BlockControlX( bFalling )

	self:UpdateAnimation()
end

------------------------------------------------------------
-- Animation

function BalloonController:UpdateAnimation()
	local fSet = function( nActivity, nRate )
		if nActivity then
			self:SetGesture( nActivity, nRate)
		end
	end

	if self.sForm == 'WALK' then
		if self.bFalling then
			fSet( self.nWalkAnimFall, 1.6 )
		elseif self.nDirX == 0 or self:IsBlockedControlX() then
			fSet( self.nWalkAnimIdle, 1 )
		else
			fSet( self.nWalkAnimRun, 1 )
		end
	elseif self.sForm == 'FLY' then
		if self.nDirX == 0 or self:IsBlockedControlX() then
			fSet( self.nFlyAnimIdle, 1 )
		else
			fSet( self.nFlyAnimRun, 1.3 )
		end
	end
end

function BalloonController:SetGesture( nActivity, nRate )
    if self.nGesture then
        self.hUnit:FadeGesture( self.nGesture )
    end

    if nActivity then
        nRate = nRate or 1
        self.hUnit:StartGestureWithPlaybackRate( nActivity, nRate )
        self.nGesture = nActivity
    end
end

function BalloonController:TurnLeft()
    self.hUnit:FaceTowards( self.hUnit:GetOrigin() + Vector( -3000, 0, 0 ) )
	self:UpdateAnimation()
end

function BalloonController:TurnRight()
    self.hUnit:FaceTowards( self.hUnit:GetOrigin() + Vector( 3000, 0, 0 ) )
	self:UpdateAnimation()
end

function BalloonController:UpdateTurn()
	if not self:IsBlockedControlX() then
		if self.nDirX == 1 then
			self:TurnRight()
		elseif self.nDirX == -1 then
			self:TurnLeft()
		end
	end
end

------------------------------------------------------------
-- Blocking controls

function BalloonController:BlockControlX( bBlock )
    if bBlock then
        self.nBlockX = self.nBlockX + 1

		if self.nBlockX == 1 then
			self:UpdateAnimation()
		end

		if type( bBlock ) == 'number' then
			Timer( bBlock, function()
				self:BlockControlX( false )
			end )
		end
    else
        self.nBlockX = math.max( 0, self.nBlockX - 1 )

		if self.nBlockX == 0 then
			self:UpdateTurn()
		end
    end
end

function BalloonController:IsBlockedControlX()
    return self.nBlockX > 0
end

function BalloonController:BlockControlZ( bBlock )
    if bBlock then
        self.nBlockZ = self.nBlockZ + 1
    else
        self.nBlockZ = math.max( 0, self.nBlockZ - 1 )
    end
end

function BalloonController:IsBlockedControlZ()
    return self.nBlockZ > 0
end

------------------------------------------------------------
-- Calculate XZ speed

function BalloonController:GetSpeed()
	return #self.vVel
end