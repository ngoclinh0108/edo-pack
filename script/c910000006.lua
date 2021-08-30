-- Palladium Ankuriboh
Duel.LoadScript("util.lua")
local s, id = GetID()

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
