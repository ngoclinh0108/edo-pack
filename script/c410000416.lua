-- Neos Contact
local s, id = GetID()
Duel.LoadScript("util.lua")

s.listed_names = {CARD_NEOS, 42015635}

function s.initial_effect(c)
    -- salvage
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1b)

    -- contact fusion
    local e2 = Fusion.CreateSummonEff({
        handler = c,
        fusfilter = aux.FilterBoolFunction(aux.IsMaterialListCode, CARD_NEOS),
        matfilter = Card.IsAbleToDeck,
        extrafil = s.e2extramat,
        extraop = Fusion.ShuffleMaterial,
        chkf = FUSPROC_NOTFUSION
    })
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCondition(function() return Duel.IsMainPhase() end)
    c:RegisterEffect(e2)

    -- contact out
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_ACTIVATE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c, tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsCode(CARD_NEOS)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsEnvironment(42015635) and eg:IsExists(s.e1filter, 1, nil, tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.SendtoHand(c, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, c)
end

function s.e2extramat(e, tp, mg)
    return Duel.GetMatchingGroup(aux.NecroValleyFilter(
                                     Fusion.IsMonsterFilter(Card.IsAbleToDeck)),
                                 tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, nil)
end

function s.e3filter1(c)
    return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c, CARD_NEOS) and
               c:IsFaceup() and c:IsAbleToExtra()
end

function s.e3filter2(c, e, tp, fc, mg)
    return c:IsControler(tp) and c:GetReasonCard() == fc and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               fc:CheckFusionMaterial(mg, c, PLAYER_NONE | FUSPROC_NOTFUSION)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e3filter1, tp, LOCATION_MZONE, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.e3filter1, tp, LOCATION_MZONE, 0, 1, 1,
                                nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

    local mg = tc:GetMaterial()
    mg = mg:Filter(s.e3filter2, nil, e, tp, tc, mg)
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
