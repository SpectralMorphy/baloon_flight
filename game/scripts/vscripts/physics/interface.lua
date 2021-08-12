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
    self.tSpaces = {}
    self.nSpaces = 0

	self:ApplySettings({})

    self.hUnit = hUnit
    hUnit.Balloon = self

    self.hMod = hUnit:AddNewModifier( hUnit, nil, 'modifier_balloon', {} )

    if not exist( self.hMod ) then
        self:Destroy()
        error( 'BalloonController: Failed to apply balloon modifier to unit ' .. hUnit:GetUnitName() )
    end
	
	local vPos = self.hUnit:GetOrigin()
	vPos.y = self.CONST.FIXED_Y
    self.vOldPos = vPos
	self:SetPos( vPos )

    self:StopMove()
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
	if not exist( self ) or not exist( self.hUnit ) then
        return
    end

    return self.vPos
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

    local vPos = self:GetPos()

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
			if ( nAbsOldVelX <= self.CONST.MAX_VEL_X and nAbsVelX > self.CONST.MAX_VEL_X )
			or ( nAbsOldVelX >= self.CONST.MAX_VEL_X and nAbsVelX < self.CONST.MAX_VEL_X ) then
				self.vVel.x = self.nDirX * self.CONST.MAX_VEL_X
			end
		end
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

    self.vVel.z = self.vVel.z + self.vAcc.z * nTimeDelta

    if self.vVel.z > self.CONST.MAX_VEL_RISE then
        self.vVel.z = self.CONST.MAX_VEL_RISE
    elseif self.vVel.x < -self.CONST.MAX_VEL_FALL then
        self.vVel.x = -self.CONST.MAX_VEL_FALL
    end

    vPos.z = vPos.z + self.vVel.z * nTimeDelta

    self:SetPos( vPos )

    self:UpdateCollision()
end

------------------------------------------------------------
-- Process collisions between 2 consecutive position

function BalloonController:UpdateCollision()
    local vPos = self:GetPos()
    local vCenter = self:GetCenter( vPos )
    local tCollisions = Obstacles:FindCollisions( self:GetCenter( self.vOldPos ), vCenter, self.CONST.HITBOX_RADIUS )

    if tCollisions then
        --------------------------------------------------------
        -- Solid collision

        local q = tCollisions[ Obstacle.TYPE.SOLID ]
        if q then
            local t = q[1]
            local vColPos = self:CenterToPos( t.vPos )
            local tMat = t.hObstacle:GetMaterial()

            if t.nCollision == Obstacle.COLLISION.TOP then
                self.vVel.z = math.max( 0, self.vVel.z )
                vPos.z = vColPos.z
            end
            
            if t.nCollision == Obstacle.COLLISION.BOT then
                self.vVel.z = math.min( 0, self.vVel.z, -self.vVel.z * tMat.BOT_BOUNCE )
                vPos.z = vColPos.z - math.max( 0, vPos.z - vColPos.z ) * tMat.BOT_BOUNCE
            end

            if t.nCollision == Obstacle.COLLISION.RIGHT then
                self.vVel.x = math.max( 0, self.vVel.x, -self.vVel.x * tMat.SIDE_BOUNCE )
                vPos.x = vColPos.x + math.max( 0, vColPos.x - vPos.x ) * tMat.SIDE_BOUNCE
            end

            if t.nCollision == Obstacle.COLLISION.LEFT then
                self.vVel.x = math.min( 0, self.vVel.x, -self.vVel.x * tMat.SIDE_BOUNCE )
                vPos.x = vColPos.x - math.max( 0, vPos.x - vColPos.x ) * tMat.SIDE_BOUNCE
            end

            self:SetPos( vPos )
            self.vOldPos = vColPos

            self:UpdateCollision()
            return
        end

        --------------------------------------------------------
        -- Space collision

        q = tCollisions[ Obstacle.TYPE.SPACE ]
        if q then
            for _, t in pairs( q ) do
                if not self.tSpaces[ t.hObstacle ] then
                    self.tSpaces[ t.hObstacle ] = true
                    self.nSpaces = self.nSpaces + 1

                    self:BlockControlZ( true )
                end
            end
        end
    end

    if self.nSpaces > 0 then
        for hObstacle in pairs( self.tSpaces ) do
            if not hObstacle:IsColliding( vCenter, self.CONST.HITBOX_RADIUS ) then
                self.tSpaces[ hObstacle ] = nil
                self.nSpaces = self.nSpaces - 1

                Timer( hObstacle.MATERIAL.DISABLE_TIME, function()
                    self:BlockControlZ( false )
                end )
            end
        end
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

            if nDistance <= nColDistance then

                -------------------------------------------------
                -- Collision physics 1

                self.vOldPos = vPos * 1

                local m1 = self.CONST.MASS
                local m2 = other.CONST.MASS
                local m = m1 + m2

                local vVel = -self.vVel
                local nVel = #vVel
                local vNewDelta
                if nVel <= 1 then
                    vNewDelta = vDelta:Normalized() * nColDistance
                else
                    local cos = vVel.x / nVel
                    local sin = vVel.z / nVel
                    local b = 2 * ( vDelta.x * cos + vDelta.z * sin )
                    local c = nDistance^2 - nColDistance^2
                    local k = ( -b + math.sqrt( b^2 - 4*c ) ) / 2
                    vNewDelta = vDelta + k * Vector( cos, 0, sin )
                end
                vNewDelta = ( #vNewDelta + 1 ) * vNewDelta:Normalized() 
                vPos1 = vPos2 + vNewDelta

                for _, sAx in pairs{'x','z'} do
                    local s1 = self.vVel[ sAx ]
                    local s2 = other.vVel[ sAx ]
                    self.vVel[ sAx ] = ( 2 * m2 * s2 + s1 * ( m1 - m2 ) ) / m
                    other.vVel[ sAx ] = ( 2 * m1 * s1 + s2 * ( m2 - m1 ) ) / m
                end

                vPos = self:CenterToPos( vPos1 )
                self:SetPos( vPos )

                self:UpdateCollision()
                return
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
    self.hUnit:FaceTowards( self.hUnit:GetOrigin() + Vector( -3000, 0, 0 ) )
    self:SetGesture( self.CONST.ANIM_MOVE, 2 )
end

function BalloonController:StartMoveRight()
    self.nDirX = 1
    self.hUnit:FaceTowards( self.hUnit:GetOrigin() + Vector( 3000, 0, 0 ) )
    self:SetGesture( self.CONST.ANIM_MOVE, 2 )
end

function BalloonController:StopMove()
    self.nDirX = 0
    self:SetGesture( self.CONST.ANIM_IDLE, 1 )
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
-- Animation

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

------------------------------------------------------------
-- Calculate x acceleration

function BalloonController:UpdateAccX()
    if self.nDirX == 0 then
        if self.vVel.x == 0 then
            self.vAcc.x = 0
        elseif self.vVel.x > 0 then
            self.vAcc.x = -self.CONST.ACC_X
        elseif self.vVel.x < 0 then
            self.vAcc.x = self.CONST.ACC_X
        end
    else
		local nVelOrient = math.max( 0, self.vVel.x * self.nDirX )
		local nInterp = Interp( self.CONST.ACC_X_INTERP, nVelOrient, self.CONST.MIN_VEL_X_INTERP, self.CONST.MAX_VEL_X )
		self.vAcc.x = self.nDirX * self.CONST.ACC_X * nInterp
    end
end

------------------------------------------------------------
-- Calculate z acceleration

function BalloonController:UpdateAccZ()
	if self.vVel.z < -self.CONST.MAX_VEL_FALL then
		self.vAcc.z = self.CONST.ACC_FALL
	elseif not self:IsBlockedControlZ() and self.nDirZ == 1 then
		local nInterp = Interp( self.CONST.ACC_RISE_INTERP, self.vVel.z, self.CONST.MIN_VEL_RISE_INTERP, self.CONST.MAX_VEL_RISE )
		self.vAcc.z = self.CONST.ACC_RISE * nInterp
    else
        self.vAcc.z = -self.CONST.ACC_FALL
    end
end

------------------------------------------------------------
-- Blocking controls

function BalloonController:BlockControlZ( bBlock )
    if bBlock then
        self.nBlockZ = self.nBlockZ + 1
    else
        self.nBlockZ = self.nBlockZ - 1
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