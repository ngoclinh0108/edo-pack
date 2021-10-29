-- Palladium Oracle Hassan
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(2)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- reduce damage
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_HAND)
    e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(function(e, tp) return Duel.GetBattleDamage(tp) > 0 end)
    e2:SetCost(s.e2cost)
    e2:SetOperation(s.e2op1)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e2b:SetCode(EVENT_CHAINING)
    e2b:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return ep ~= tp and aux.damcon1(e, tp, eg, ep, ev, re, r, rp)
    end)
    e2b:SetOperation(s.e2op2)
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
    return Duel.GetAttackTarget() == nil and
               Duel.GetAttacker():IsControler(1 - tp)
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
    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(), REASON_COST + REASON_DISCARD)
end

function s.e2op1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    ec1:SetTargetRange(1, 0)
    ec1:SetReset(RESET_PHASE + PHASE_DAMAGE)
    Duel.RegisterEffect(ec1, tp)
end

function s.e2op2(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_CHANGE_DAMAGE)
    ec1:SetTargetRange(1, 0)
    ec1:SetLabel(Duel.GetChainInfo(ev, CHAININFO_CHAIN_ID))
    ec1:SetValue(function(e, re, val, r)
        if Duel.GetCurrentChain() == 0 or (r & REASON_EFFECT) == 0 then
            return
        end
        local cid = Duel.GetChainInfo(0, CHAININFO_CHAIN_ID)
        return cid == e:GetLabel() and 0 or val
    end)
    ec1:SetReset(RESET_CHAIN)
    Duel.RegisterEffect(ec1, tp)
end

function s.e3filter(c) return c:IsSetCard(0x13a) and c:IsAbleToHand() end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return (r & REASON_EFFECT + REASON_BATTLE) ~= 0
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToDeckAsCost() end
    Duel.SendtoDeck(e:GetHandler(), nil, SEQ_DECKSHUFFLE, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 3
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) < 3 then return end

    local g = Duel.GetDecktopGroup(tp, 3)
    Duel.ConfirmCards(tp, g)
    if g:IsExists(s.e3filter, 1, nil) and
        Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        local sg = Utility.GroupSelect(HINT_SELECTMSG, g, tp, 1, 1, nil,
                                       s.e3filter)
        Duel.DisableShuffleCheck()
        Duel.SendtoHand(sg, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sg)
        Duel.ShuffleHand(tp)
        Duel.SortDecktop(tp, tp, 2)
    else
        Duel.SortDecktop(tp, tp, 3)
    end
end
