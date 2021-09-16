-- Blue-Eyes Holy Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0xdd}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTunerEx(Card.IsSetCard, 0xdd),
                         1, 1)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE +
                            EFFECT_FLAG_SINGLE_RANGE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetRange(LOCATION_EXTRA)
    splimit:SetValue(aux.synlimit)
    c:RegisterEffect(splimit)

    -- disable
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(1117)
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e2filter(c, tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and
               c:IsSetCard(0xdd)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    if rp == tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
        return false
    end

    local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    return tg and tg:IsExists(s.e2filter, 1, nil, tp) and
               Duel.IsChainDisablable(ev)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp, chk) Duel.NegateEffect(ev) end
