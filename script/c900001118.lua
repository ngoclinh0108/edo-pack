-- Palladium Beast Gazelle
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a, 0x46}

function s.initial_effect(c)
    -- search
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1b)

    -- piercing damage
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e2)

    -- draw
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter1(c) return c:IsSetCard(0x13a) and c:IsLevelAbove(5) and c:IsAbleToGraveAsCost() end

function s.e1filter2(c) return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToHand() end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_DECK, 0, 1, nil) end

    local g = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e1filter1, tp, LOCATION_DECK, 0, 1, 1, nil)
    Duel.SendtoGrave(g, REASON_COST)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, aux.NecroValleyFilter(s.e1filter2), tp,
        LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return (r & REASON_FUSION) ~= 0 end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end
