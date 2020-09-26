-- Millennium Ascension
local s, id = GetID()

s.listed_names = {10000040}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetCategory(CATEGORY_TOGRAVE)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- startup
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetCode(EVENT_STARTUP)
    e0:SetRange(LOCATION_ALL)
    e0:SetOperation(s.e0op)
    c:RegisterEffect(e0)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_FZONE)
    e1:SetValue(function(e, te)
        return te:GetHandler() ~= e:GetHandler()
    end)
    c:RegisterEffect(e1)

    -- cannot be target
	local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end

function s.e0op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local sc = Duel.GetFirstMatchingCard(Card.IsCode, tp, LOCATION_DECK, 0, nil,
                                         10000040)
    if not sc then return end

    Duel.Hint(HINT_CARD, tp, id)
    Duel.ConfirmCards(1 - tp, sc)

    aux.PlayFieldSpell(c, e, tp, eg, ep, ev, re, r, rp)
end
