modifier_balloon = class{}

------------------------------------------------------------
-- States

function modifier_balloon:CheckState()
    return {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    }
end

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
    end
end

------------------------------------------------------------
-- Modifier destroying

function modifier_balloon:OnDestroy()
	if IsServer() then
		local hUnit = self:GetParent()
		hUnit:RemoveHorizontalMotionController( self )
		hUnit:RemoveVerticalMotionController( self )
	end
end

------------------------------------------------------------
-- Horizontal motion update

function modifier_balloon:UpdateHorizontalMotion( hUnit, nTimeDelta )
    if not exist( hUnit ) or not exist( hUnit.Balloon ) then
        return
    end

    hUnit.Balloon:UpdateHorizontal( nTimeDelta )
end

------------------------------------------------------------
-- Vertical motion update

function modifier_balloon:UpdateVerticalMotion( hUnit, nTimeDelta )
    if not exist( hUnit ) or not exist( hUnit.Balloon ) then
        return
    end

    hUnit.Balloon:UpdateVertical( nTimeDelta )
end