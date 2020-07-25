-- Djeser!
local s, id = GetID()

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- summon protect
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x13a))
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_CANNOT_DISABLE_FLIP_SUMMON)
    c:RegisterEffect(e1b)
    local e1c = e1:Clone()
    e1c:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(e1c)

    -- effect protect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_INACTIVATE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetValue(s.e2val)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e2b)
end

function s.e2val(e, ct)
    local c = e:GetHandler()
    local p = c:GetControler()
    local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT,
                                          CHAININFO_TRIGGERING_PLAYER,
                                          CHAININFO_TRIGGERING_LOCATION)
    return p == tp and te:GetHandler():IsSetCard(0x13a) and loc &
               LOCATION_ONFIELD ~= 0
end
