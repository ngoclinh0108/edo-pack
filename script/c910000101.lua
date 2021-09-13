-- Palladium De-Fusion
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:AddSetcodesRule(0x13a)

    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_CANNOT_DISABLE +
                       EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter1(c)
    return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end

function s.e1filter2(c, e, tp, fc, mg)
    return c:IsControler(tp) and (c:GetReason() & 0x40008) == 0x40008 and
               c:GetReasonCard() == fc and
               fc:CheckFusionMaterial(mg, c, PLAYER_NONE | FUSPROC_NOTFUSION) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               c:IsLocation(
                   LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE +
                       LOCATION_REMOVED)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e1filter1, tp, LOCATION_MZONE,
                                     LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.e1filter1, tp, LOCATION_MZONE,
                                LOCATION_MZONE, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end

    local sumtype = tc:GetSummonType()
    local mg = tc:GetMaterial()
    if Duel.SendtoDeck(tc, nil, 0, REASON_EFFECT) == 0 then return end

    mg = mg:Filter(aux.NecroValleyFilter(s.e1filter2), nil, e, tp, tc, mg)
    if #mg == 0 then return end

    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if ft == 0 then return end
    if ft > #mg then ft = #mg end
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then ft = 1 end

    if (sumtype & SUMMON_TYPE_FUSION) == SUMMON_TYPE_FUSION and
        Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        Duel.BreakEffect()

        local g = Utility.GroupSelect(mg, tp, 1, ft, nil)
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end
