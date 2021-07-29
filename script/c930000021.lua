-- Narfi of the Nordic Alfar
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x42}

function s.initial_effect(c)
    -- set itself as a spell
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_MONSTER_SSET)
    e1:SetValue(TYPE_SPELL)
    c:RegisterEffect(e1)

    -- to deck & draw
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1, id + 1000000)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- search
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_HAND)
    e3:SetCountLimit(1, id + 2000000)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2filter(c)
    return not c:IsCode(id) and c:IsSetCard(0x42) and c:IsAbleToHand()
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD) and
               c:IsPreviousPosition(POS_FACEDOWN) and c:IsReason(REASON_DESTROY) and
               not c:IsReason(REASON_BATTLE) and re
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK, 0, 1,
                                           nil) and c:IsAbleToDeck()
    end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e2filter, tp, LOCATION_DECK, 0, nil)
    if not c:IsRelateToEffect(e) or #g == 0 then return end

    if Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) > 0 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local sg = g:Select(tp, 1, 1, nil)
        Duel.SendtoHand(sg, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sg)
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return r & REASON_EFFECT > 0 and re:GetHandler():IsSetCard(0x42) and
               e:GetHandler():GetPreviousControler() == tp
end

function s.e3filter(c)
    return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local tc = Duel.SelectMatchingCard(tp, s.e3filter, tp,
                                       LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                       nil):GetFirst()
    if not tc then return end

    if Duel.SendtoHand(tc, nil, REASON_EFFECT) > 0 and
        tc:IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1 - tp, tc)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ec1:SetCode(EFFECT_CANNOT_SUMMON)
        ec1:SetTargetRange(1, 0)
        ec1:SetLabel(tc:GetCode())
        ec1:SetTarget(s.e3sumlimit)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
        local e3b = ec1:Clone()
        e3b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        Duel.RegisterEffect(e3b, tp)
        local e3c = ec1:Clone()
        e3c:SetCode(EFFECT_CANNOT_MSET)
        Duel.RegisterEffect(e3c, tp)
    end
end

function s.e3sumlimit(e, c) return c:IsCode(e:GetLabel()) end
