-- Palladium Beast Chimera
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {910000018, 910000019}
s.material_setcode = {0x13a}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, false, false, 910000018, 910000019)

    -- gain effect
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local g = c:GetMaterial()
        for mc in aux.Next(g) do c:CopyEffect(mc:GetOriginalCode(), RESET_EVENT + RESETS_STANDARD, 1) end
    end)
    c:RegisterEffect(e1)

    -- chain attack
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return aux.bdocon(e, tp, eg, ep, ev, re, r, rp) and e:GetHandler():CanChainAttack()
    end)
    e2:SetOperation(function() Duel.ChainAttack() end)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e3filter(c, e, tp)
    if c:IsLocation(LOCATION_REMOVED) and c:IsFacedown() then return false end
    return c:IsCode(910000018, 910000019) and (c:IsCanBeSpecialSummoned(e, 0, tp, false, false) or c:IsAbleToHand())
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_DECK + LOCATION_GRAVE + LOCATION_REMOVED
    if chk == 0 then
        return
            Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(s.e3filter, tp, loc, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, loc)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, aux.NecroValleyFilter(s.e3filter), tp,
        LOCATION_DECK + LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil, e, tp)
    if #g == 0 then return end

    aux.ToHandOrElse(g, tp, function(tc)
        return tc:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    end, function(g) Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end, 2)
end
