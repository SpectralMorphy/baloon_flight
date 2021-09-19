modifier_balloon = class{}

------------------------------------------------------------
-- properties

function modifier_balloon:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_balloon:IsPermanent()
	return true
end

------------------------------------------------------------
-- States

function modifier_balloon:CheckState()
    return {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    }
end