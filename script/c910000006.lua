-- Palladium Ankuriboh
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {83764718}

function s.initial_effect(c)
    -- no damage
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e1:SetRange(LOCATION_HAND + LOCATION_MZONE)
    e1:SetCondition(function(e, tp) return Duel.GetBattleDamage(tp) > 0 end)
    e1:SetCost(s.e1cost)
    e1:SetOperation(s.e1op1)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e1b:SetCode(EVENT_CHAINING)
    e1b:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return (aux.damcon1(e, tp, eg, ep, ev, re, r, rp) or
                   aux.damcon1(e, 1 - tp, eg, ep, ev, re, r, rp))
    end)
    e1b:SetOperation(s.e1op2)
    c:RegisterEffect(e1b)

    -- add to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- ritual material
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
    e3:SetCondition(function(e)
        return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(), 69832741)
    end)
    e3:SetValue(1)
    c:RegisterEffect(e3)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c, REASON_COST)
end

function s.e1op1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    ec1:SetTargetRange(1, 0)
    ec1:SetReset(RESET_PHASE + PHASE_DAMAGE)
    Duel.RegisterEffect(ec1, tp)
end

function s.e1op2(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local cid = Duel.GetChainInfo(ev, CHAININFO_CHAIN_ID)

    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CHANGE_DAMAGE)
    e1:SetTargetRange(1, 0)
    e1:SetLabel(cid)
    e1:SetValue(function(e, re, val, r, rp, rc)
        local cc = Duel.GetCurrentChain()
        if cc == 0 or r & REASON_EFFECT == 0 then return end
        local cid = Duel.GetChainInfo(0, CHAININFO_CHAIN_ID)
        if cid == e:GetLabel() then
            e:SetLabel(val)
            return 0
        else
            return val
        end
    end)
    e1:SetReset(RESET_CHAIN)
    Duel.RegisterEffect(e1, tp)
end

function s.e2filter(c)
    return c:IsCode(83764718) and (c:IsAbleToHand() or c:IsSSetable())
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec1:SetCode(EVENT_PHASE + PHASE_END)
    ec1:SetCountLimit(1)
    ec1:SetCondition(s.e2thcon)
    ec1:SetOperation(s.e2thop)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.e2thcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.e2filter, tp,
                                       LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
end

function s.e2thop(e, tp, eg, ep, ev, re, r, rp)
    Utility.HintCard(id)

    local g = Utility.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e2filter),
                                         tp, LOCATION_DECK + LOCATION_GRAVE, 0,
                                         1, 1, nil, HINTMSG_ATOHAND)
    if #g == 0 then return end
    aux.ToHandOrElse(g, tp, function(c)
        return c:IsSSetable() and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
    end, function(g) Duel.SSet(tp, g) end, HINTMSG_SET)
end
