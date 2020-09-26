-- Millennium Ascension
local s, id = GetID()

s.listed_names = {10000040}
s.listed_series={0x13a}

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
	e2:SetValue(1)
    c:RegisterEffect(e2)
    
    -- summon protect
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x13a))
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_CANNOT_DISABLE_FLIP_SUMMON)
    c:RegisterEffect(e3b)
    local e3c = e3:Clone()
    e3c:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(e3c)

    -- spell/trap protect
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CANNOT_INACTIVATE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetValue(s.e4val)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e4b)

    -- extra summon
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e5:SetRange(LOCATION_FZONE)
    e5:SetTargetRange(LOCATION_HAND + LOCATION_MZONE, 0)
    e5:SetTarget(aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_DIVINE))
    c:RegisterEffect(e5)

    -- shuffle deck
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 1))
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_FZONE)
    e6:SetCountLimit(1)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
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

function s.e4val(e, ct)
    local p = e:GetHandler():GetControler()
    local te, tp = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT,
                                     CHAININFO_TRIGGERING_PLAYER)
    return p == tp and te:IsActiveType(TYPE_SPELL + TYPE_TRAP) and
               te:GetHandler():IsSetCard(0x13a)
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 end
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.ShuffleDeck(tp)
    Duel.SortDecktop(tp, tp, 5)
end