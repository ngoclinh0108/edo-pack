-- Temple of the White Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0xdd}

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
    e1:SetTarget(function(e, c)
        return c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_LIGHT) and
                   c:GetLevel() == 1
    end)
    c:RegisterEffect(e1)

    -- search
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- atk up
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1, id)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2filter(c)
    if not c:IsAbleToHand() then return false end
    return ((c:IsSetCard(0xdd) and c:IsType(TYPE_MONSTER))) or
               ((aux.IsCodeListed(c, CARD_BLUEEYES_W_DRAGON) or
                   aux.IsCodeListed(c, 23995346)) and
                   c:IsType(TYPE_SPELL + TYPE_TRAP))
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, LOCATION_DECK)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.e2filter, tp, LOCATION_DECK,
                                      LOCATION_DECK, 1, 1)
    if #g == 0 then return end

    Duel.SendtoHand(g, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, g)
end

function s.e3filter(c)
    return c:IsSetCard(0xdd) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_MZONE, 0, 1,
                                     nil) and
                   Duel.IsExistingMatchingCard(s.e3filter, tp,
                                               LOCATION_HAND + LOCATION_DECK, 0,
                                               1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local tc = Duel.GetFirstTarget()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local sc = Duel.SelectMatchingCard(tp, s.e3filter, tp,
                                       LOCATION_HAND + LOCATION_DECK, 0, 1, 1,
                                       nil):GetFirst()
    if not sc then return end

    if Duel.SendtoGrave(gc, REASON_EFFECT) ~= 0 and
        sc:IsLocation(LOCATION_GRAVE) and tc:IsRelateToEffect(e) and
        tc:IsFaceup() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(sc:GetLevel() * 100)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_UPDATE_DEFENSE)
        tc:RegisterEffect(ec1b)
    end
end
