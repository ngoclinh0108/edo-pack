--Sky God's Descendant
local root,id=GetID()

function root.initial_effect(c)
	--cannot be tribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(aux.TargetBoolFunction(aux.NOT(Card.IsRace),RACE_DIVINE))
	c:RegisterEffect(e1)
end
