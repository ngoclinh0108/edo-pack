-- Palladium Magic
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- ritual
    local e1 = Ritual.CreateProc({
        handler = c,
        filter = aux.FilterBoolFunction(Card.IsSetCard, 0x13a),
        lvtype = RITPROC_GREATER,
        location = LOCATION_HAND + LOCATION_GRAVE,
        stage2 = s.e1sumop,
        desc = aux.Stringid(id, 1)
    })
    c:RegisterEffect(e1)

    -- search fusion spell
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 2))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- search ritual monster
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 3))
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_ACTIVATE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- special summon spellcaster
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 4))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_ACTIVATE)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1sumop(mat, e, tp, eg, ep, ev, re, r, rp, tc)
    local c = e:GetHandler()
    tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD,
                          EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 0))

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    ec1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetValue(function(e, re, rp) return rp == 1 - e:GetHandlerPlayer() end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec2 = ec1:Clone()
    ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
    ec2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    ec2:SetValue(aux.tgoval)
    tc:RegisterEffect(ec2)
end

function s.e2filter(c)
    return c:IsAbleToHand() and c:IsType(TYPE_SPELL) and c:IsSetCard(0x46)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.e2filter, tp,
                                      LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                      nil)

    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e3filter(c)
    return c:IsAbleToHand() and c:IsSetCard(0x13a) and c:IsType(TYPE_RITUAL) and
               c:IsType(TYPE_MONSTER)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.e3filter, tp, LOCATION_DECK, 0, 1,
                                      1, nil)

    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e4filter1(c)
    return c:IsFaceup() and c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT) and
               c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_NORMAL) and
               c:IsSetCard(0x13a)
end

function s.e4filter2(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and c:IsLevel(6) and
               c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER) and
               c:IsSetCard(0x13a)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.e4filter1, tp, LOCATION_ONFIELD, 0, 1,
                                       nil)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e4filter2, tp, LOCATION_HAND +
                                                   LOCATION_DECK +
                                                   LOCATION_GRAVE, 0, 1, nil, e,
                                               tp)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) < 1 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e4filter2),
                                      tp, LOCATION_HAND + LOCATION_DECK +
                                          LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end
