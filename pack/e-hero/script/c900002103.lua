-- Evil HERO Blaster Minx
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x6008}

function s.initial_effect(c)
    -- add name
    local addname = Effect.CreateEffect(c)
    addname:SetType(EFFECT_TYPE_SINGLE)
    addname:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    addname:SetCode(EFFECT_ADD_CODE)
    addname:SetValue(58932615)
    c:RegisterEffect(addname)

    -- to grave
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1b)
end

function s.e1filter(c)
    return c:IsSetCard(0x6008) and c:IsMonster() and c:IsAbleToGrave()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_HAND + LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1,
        nil)
    if #g > 0 then
        Duel.SendtoGrave(g, REASON_EFFECT)
    end
end
