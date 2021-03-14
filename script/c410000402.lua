-- Spacian HERO Neu
local s, id = GetID()
Duel.LoadScript("util.lua")

s.listed_names = {42015635, CARD_NEOS}

function s.initial_effect(c)
    -- change name
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE +
                       EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetRange(LOCATION_MZONE + LOCATION_GRAVE)
    e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return Duel.IsEnvironment(42015635)
    end)
    e1:SetValue(CARD_NEOS)
    c:RegisterEffect(e1)

    -- add spell/trap
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2b)
end

function s.e2filter(c)
    return c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsAbleToHand() and
               aux.IsCodeListed(c, CARD_NEOS)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.e2filter, tp, LOCATION_DECK, 0, 1,
                                      1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
