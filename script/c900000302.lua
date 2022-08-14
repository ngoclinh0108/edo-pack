-- Majestic Black Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")

local s, id = GetID()
s.material = {SignerDragon.CARD_MAJESTIC_DRAGON, CARD_BLACK_WINGED_DRAGON}
s.listed_names = {SignerDragon.CARD_MAJESTIC_DRAGON, CARD_BLACK_WINGED_DRAGON}
s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddMajesticProcedure(c, aux.FilterBoolFunction(Card.IsCode, SignerDragon.CARD_MAJESTIC_DRAGON), true,
        aux.FilterBoolFunction(Card.IsCode, CARD_BLACK_WINGED_DRAGON), true, Synchro.NonTuner(nil), false)
end
FFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--double tuner check
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetValue(s.valcheck)
	c:RegisterEffect(e5)
end
