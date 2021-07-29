-- Narfi of the Nordic Alfar
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x42}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetCountLimit(1, id + 1000000)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return r & REASON_EFFECT > 0 and re:GetHandler():IsSetCard(0x42) and
               e:GetHandler():GetPreviousControler() == tp
end

function s.e1filter(c)
    return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local tc = Duel.SelectMatchingCard(tp, s.e1filter, tp,
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
        ec1:SetTarget(s.e1sumlimit)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
        local e1b = ec1:Clone()
        e1b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        Duel.RegisterEffect(e1b, tp)
        local e1c = ec1:Clone()
        e1c:SetCode(EFFECT_CANNOT_MSET)
        Duel.RegisterEffect(e1c, tp)
    end
end

function s.e1sumlimit(e, c) return c:IsCode(e:GetLabel()) end
