-- Erupted Field of the Black Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_REDEYES_B_DRAGON}
s.listed_series = {0x3b}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- additional summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_HAND + LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c:IsType(TYPE_GEMINI) end)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- search
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1, id)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- special summon
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1, id)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e2filter(c, e, tp)
    return c:IsCode(CARD_REDEYES_B_DRAGON) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return rp == 1 - tp and c:IsReason(REASON_EFFECT) and
               c:IsPreviousLocation(LOCATION_FZONE) and
               c:IsPreviousControler(tp)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND +
                                                   LOCATION_DECK +
                                                   LOCATION_GRAVE, 0, 1, nil, e,
                                               tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0,
                          LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e3filter1(c)
    return c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER) and
               c:IsAbleToGraveAsCost()
end

function s.e3filter2(c)
    if not c:IsAbleToHand() or c:IsCode(id) then return false end
    return (aux.IsCodeListed(c, CARD_REDEYES_B_DRAGON) or c:IsSetCard(0x3b)) and
               c:IsType(TYPE_SPELL + TYPE_TRAP)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter1, tp,
                                           LOCATION_HAND + LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.e3filter1, tp,
                                      LOCATION_HAND + LOCATION_DECK, 0, 1, 1,
                                      nil)
    Duel.SendtoGrave(g, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter2, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.e3filter2, tp, LOCATION_DECK, 0, 1,
                                      1, nil)

    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e4filter1(c) return c:IsFaceup() and c:IsSetCard(0x3b) end

function s.e4filter2(c, e, tp)
    return c:IsType(TYPE_NORMAL) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.e4filter1, tp, LOCATION_MZONE, 0, 1,
                                       nil)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingTarget(s.e4filter2, tp, LOCATION_GRAVE, 0, 1,
                                         nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.e4filter2, tp, LOCATION_GRAVE, 0, 1, 1,
                                nil, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
end
