modifier_balloon = class{}

------------------------------------------------------------

function modifier_balloon:DeclareFunctions()
    return {
        -- MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
end

------------------------------------------------------------
-- Modifier creation

function modifier_balloon:OnCreated()
    if IsServer() then
        local hUnit = self:GetParent()

        if not exist( hUnit.Balloon ) then
            self:Destroy()
            return
        end

        if not self:ApplyHorizontalMotionController() then
            print('Failed to apply horizontal motion controller')
            self:Destroy()
            return
        end

        if not self:ApplyVerticalMotionController() then
            print('Failed to apply vertical motion controller')
            self:Destroy()
            return
        end

        local vPos = hUnit:GetOrigin()
        vPos.y = hUnit.Balloon.CONST.FIXED_Y
        hUnit:SetAbsOrigin( vPos )
    end
end

------------------------------------------------------------
-- Modifier destroying

function modifier_balloon:OnDestroy()
    local hUnit = self:GetParent()
    hUnit:RemoveHorizontalMotionController( self )
    hUnit:RemoveVerticalMotionController( self )
end

------------------------------------------------------------
-- Horizontal motion update

function modifier_balloon:UpdateHorizontalMotion( hUnit, nTimeDelta )
    if not exist( hUnit ) or not exist( hUnit.Balloon ) then
        return
    end

    local hBal = hUnit.Balloon
    local vPos = hUnit:GetOrigin()

    hBal:UpdateAccX()

    local nOldVelX = hBal.vVel.x
    hBal.vVel.x = hBal.vVel.x + hBal.vAcc.x * nTimeDelta

    if hBal.nDirX == 0 then
        if ( nOldVelX < 0 and hBal.vVel.x > 0 )
        or ( nOldVelX > 0 and hBal.vVel.x < 0 ) then
            hBal.vVel.x = 0
        end
    else
        if hBal.vVel.x > hBal.CONST.MAX_VEL_X then
            hBal.vVel.x = hBal.CONST.MAX_VEL_X
        elseif hBal.vVel.x < -hBal.CONST.MAX_VEL_X then
            hBal.vVel.x = -hBal.CONST.MAX_VEL_X
        end
    end

    vPos.x = vPos.x + hBal.vVel.x * nTimeDelta

    -----------------------------------
    -- hardcoded edges
    if vPos.x < -1500 then
        vPos.x = -3000 - vPos.x
        hBal.vVel.x = -hBal.vVel.x
    end
    if vPos.x > 1500 then
        vPos.x = 3000 - vPos.x
        hBal.vVel.x = -hBal.vVel.x
    end
    -----------------------------------

    hUnit:SetAbsOrigin( vPos )
end

------------------------------------------------------------
-- Vertical motion update

function modifier_balloon:UpdateVerticalMotion( hUnit, nTimeDelta )
    if not exist( hUnit ) or not exist( hUnit.Balloon ) then
        return
    end

    local hBal = hUnit.Balloon
    local vPos = hUnit:GetOrigin()

    hBal:UpdateAccZ()

    hBal.vVel.z = hBal.vVel.z + hBal.vAcc.z * nTimeDelta

    if hBal.vVel.z > hBal.CONST.MAX_VEL_RISE then
        hBal.vVel.z = hBal.CONST.MAX_VEL_RISE
    elseif hBal.vVel.x < -hBal.CONST.MAX_VEL_FALL then
        hBal.vVel.x = -hBal.CONST.MAX_VEL_FALL
    end

    vPos.z = vPos.z + hBal.vVel.z * nTimeDelta

    -----------------------------------
    -- hardcoded bottom
    if vPos.z <= 128 then
        vPos.z = 128
        hBal.vVel.z = 0
    end
    -----------------------------------

    -----------------------------------
    -- hardcoded top
    if vPos.z > 1600 then
        if not self.bTop then
            self.bTop = true
            hBal:BlockControlZ( true )
        end
    else
        if self.bTop then
            self.bTop = false
            Timer( 0.5, function()
                hBal:BlockControlZ( false )
            end )
        end
    end
    -----------------------------------

    hUnit:SetAbsOrigin( vPos )
end