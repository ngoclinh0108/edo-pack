-- Neos Contact
local s, id = GetID()
Duel.LoadScript("util.lua")

s.listed_names = {CARD_NEOS, 42015635}

function s.initial_effect(c)
    -- contact fusion
    local e1 = Fusion.CreateSummonEff({
        handler = c,
        fusfilter = aux.FilterBoolFunction(aux.IsMaterialListCode, CARD_NEOS),
        matfilter = Card.IsAbleToDeck,
        extrafil = s.e1extramat,
        extratg = s.e1extratg,
        extraop = Fusion.ShuffleMaterial,
        chkf = FUSPROC_NOTFUSION
    })
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCondition(function() return Duel.IsMainPhase() end)
    c:RegisterEffect(e1)

    -- contact out
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1extramat(e, tp, mg)
    return Duel.GetMatchingGroup(aux.NecroValleyFilter(
                                     Fusion.IsMonsterFilter(Card.IsAbleToDeck)),
                                 tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, nil)
end

function s.e1extratg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    if Duel.IsEnvironment(42015635) then
        e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                          EFFECT_FLAG_CANNOT_INACTIVATE)
    else
        e:SetProperty(0)
    end
end

function s.e2filter1(c)
    return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c, CARD_NEOS) and
               c:IsFaceup() and c:IsAbleToExtra()
end

function s.e2filter2(c, e, tp, fc)
    return fc.material and c:IsCode(table.unpack(fc.material)) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e2filter1, tp, LOCATION_MZONE, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.e2filter1, tp, LOCATION_MZONE, 0, 1, 1,
                                nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

    local mg = Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_DECK, 0, nil, e,
                                     tp, tc)
    if (#mg >= 2 and Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT)) or
        #mg == 0 then return end

    if Duel.SendtoDeck(tc, nil, 0, REASON_EFFECT) ~= 0 and
        tc:IsLocation(LOCATION_EXTRA) and
        Duel.GetLocationCount(tp, LOCATION_MZONE) >= #mg and
        Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
        Duel.BreakEffect()
        Duel.SpecialSummon(mg, 0, tp, tp, false, false, POS_FACEUP)
    end
end
