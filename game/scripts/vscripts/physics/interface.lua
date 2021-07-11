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
    self.CONST = table.deepcopy( CONST )
    self.hUnit = hUnit

    hUnit.Balloon = self

    self.hMod = hUnit:AddNewModifier( hUnit, nil, 'modifier_balloon', {} )

    if not exist( self.hMod ) then
        self:Destroy()
        error( 'BalloonController: Failed to apply balloon modifier to unit ' .. hUnit:GetUnitName() )
    end

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
        local nVelPct = nVelOrient / self.CONST.MAX_VEL_X
        self.vAcc.x = self.nDirX * self.CONST.ACC_X * self.CONST.ACC_X_INTERP( nVelPct )
    end
end

------------------------------------------------------------
-- Calculate z acceleration

function BalloonController:UpdateAccZ()
    if not self:IsBlockedControlZ() and self.nDirZ == 1 then
        self.vAcc.z = self.CONST.ACC_RISE
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