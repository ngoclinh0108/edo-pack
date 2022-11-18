-- The Chosen Pharaoh
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {39913299}

function s.initial_effect(c)
    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                                                    EFFECT_FLAG_CANNOT_INACTIVATE

    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetHintTiming(0, TIMING_END_PHASE)
    c:RegisterEffect(act)

    -- inactivatable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e1:SetCode(EFFECT_CANNOT_INACTIVATE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e1b)

    -- shuffle when leaving the field
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e2:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1val(e, ct)
    local p = e:GetHandler():GetControler()
    local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER,
        CHAININFO_TRIGGERING_LOCATION)
    local tc = te:GetHandler()
    return p == tp and tc:IsCode(39913299) and (loc & LOCATION_ONFIELD) ~= 0
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end

    local g = Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT + REASON_RULE)
end
