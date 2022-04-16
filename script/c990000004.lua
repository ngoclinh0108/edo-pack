-- Lapis, Dracodeity of the Abyss
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_WATER)
    UtilityDracodeity.RegisterEffect(c, id)

    -- cannot be returned
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EVENT_CHAIN_SOLVING)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if rp == tp then return end
        local g = Duel.GetMatchingGroup(function(tc)
            return tc:GetMutualLinkedGroupCount() > 0
        end, tp, LOCATION_MZONE, 0, nil)
        if #g == 0 then return end

        g:AddCard(c)
        for tc in aux.Next(g) do
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_CANNOT_TO_HAND)
            ec1:SetRange(LOCATION_MZONE)
            ec1:SetLabelObject(re)
            ec1:SetTarget(function(e, c, tp, r, re)
                return re == e:GetLabelObject()
            end)
            ec1:SetReset(RESET_CHAIN)
            tc:RegisterEffect(ec1)
            local ec2 = ec1:Clone()
            ec2:SetCode(EFFECT_CANNOT_TO_DECK)
            tc:RegisterEffect(ec2)
        end
    end)
    c:RegisterEffect(e1)

    -- multi attack
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_PHASE + PHASE_BATTLE_START)
    e2:SetCountLimit(1)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- recover
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_PHASE + PHASE_BATTLE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    aux.GlobalCheck(s, function()
        local e3reg = Effect.CreateEffect(c)
        e3reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e3reg:SetCode(EVENT_DESTROYED)
        e3reg:SetOperation(s.e3regop)
        Duel.RegisterEffect(e3reg, 0)
    end)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():GetLinkedGroupCount() > 0 end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local ct = c:GetLinkedGroupCount()
    if ct > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_EXTRA_ATTACK)
        ec1:SetValue(ct)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_BATTLE)
        c:RegisterEffect(ec1)
    end
end

function s.e3filter(c, rc)
    return c:IsReason(REASON_BATTLE) and c:GetReasonCard() == rc
end

function s.e3regop(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(s.e3filter, nil, e:GetHandler())
    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(function(c) return c:GetFlagEffect(id) > 0 end, tp, LOCATION_ALL, LOCATION_ALL, 1, nil)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(function(c) return c:GetFlagEffect(id) > 0 end, tp, LOCATION_ALL, LOCATION_ALL, nil, c)

    local lp = 0
    for tc in aux.Next(g) do
        if tc:GetTextAttack() > 0 then
            lp = lp + tc:GetTextAttack()
        end
    end

    if lp == 0 or not Duel.SelectEffectYesNo(tp, c) then return end
    Utility.HintCard(c)
    Duel.Recover(tp, lp, REASON_EFFECT)
end
