-- Serect Palladium Oracle Hassan
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(2)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- no effect damage
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CHANGE_DAMAGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(1, 0)
    e2:SetValue(function(e, re, val, r, rp, rc)
        if (r & REASON_EFFECT) ~= 0 then
            return 0
        end
        return val
    end)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    c:RegisterEffect(e2b)

    -- check deck
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCountLimit(1, {id, 3})
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttackTarget() == nil and Duel.GetAttacker():IsControler(1 - tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then
        return
    end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
end

function s.e3filter(c)
    return c:IsSetCard(0x13a) and c:IsAbleToHand()
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return (r & REASON_EFFECT + REASON_BATTLE) ~= 0
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return e:GetHandler():IsAbleToDeckAsCost()
    end
    
    Duel.SendtoDeck(e:GetHandler(), nil, SEQ_DECKBOTTOM, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 3
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) < 3 then
        return
    end

    local g = Duel.GetDecktopGroup(tp, 3)
    Duel.ConfirmCards(tp, g)
    if g:IsExists(s.e3filter, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        local sg = Utility.GroupSelect(nil, g, tp, 1, 1, nil, s.e3filter)
        Duel.DisableShuffleCheck()
        Duel.SendtoHand(sg, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sg)
        Duel.ShuffleHand(tp)
        Duel.SortDecktop(tp, tp, 2)
    else
        Duel.SortDecktop(tp, tp, 3)
    end
end
