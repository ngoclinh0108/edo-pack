-- Hildisvini of the Nordic Beasts
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x42}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetRange(LOCATION_HAND + LOCATION_DECK)
    e1:SetCountLimit(1, id + 1000000)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_CHANGE_POS)
    e2:SetCountLimit(1, id + 2000000)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, tp)
    return c:IsReason(REASON_BATTLE + REASON_EFFECT) and
               c:IsPreviousControler(tp) and
               c:IsPreviousLocation(LOCATION_MZONE) and c:IsSetCard(0x42)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e1filter, 1, nil, tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3000)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetValue(1)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    end
end

function s.e2filter(c)
    return not c:IsCode(id) and c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and
               c:IsAbleToHand()
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetPosition() == POS_FACEUP_ATTACK and
               e:GetHandler():GetPreviousPosition() > 0x3
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e2filter), tp,
                                      LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                      nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
