-- Shooting Star Synchron
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 1)

    -- non-tuner for a synchro summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCode(EFFECT_NONTUNER)
    e1:SetRange(LOCATION_MZONE)
    c:RegisterEffect(e1)

    -- draw
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return Duel.IsPlayerCanDraw(tp, 1)
        end

        Duel.SetTargetPlayer(tp)
        Duel.SetTargetParam(1)
        Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
    end)
    e2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
        Duel.Draw(p, d, REASON_EFFECT)
    end)
    c:RegisterEffect(e2)

    -- gain effect
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return r == REASON_SYNCHRO
    end)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3110)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_IMMUNE_EFFECT)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetValue(function(e, te)
        return te:GetOwnerPlayer() ~= e:GetHandlerPlayer() and te:IsActivated()
    end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD + RESET_PHASE + PHASE_END)
    rc:RegisterEffect(ec1)
end
