-- Lapis, Dracodeity of the Abyss
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_WATER)
    UtilityDracodeity.RegisterEffect(c, id)

    -- cannot be returned
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_CANNOT_TO_DECK)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, tc) return tc == e:GetHandler() or tc:GetMutualLinkedGroupCount() > 0 end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_CANNOT_TO_HAND)
    c:RegisterEffect(e1b)

    -- multiple attack
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_PHASE + PHASE_BATTLE_START)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- lower ATK
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- recover
    local e4 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EVENT_PHASE + PHASE_BATTLE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
    aux.GlobalCheck(s, function()
        local e4reg = Effect.CreateEffect(c)
        e4reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e4reg:SetCode(EVENT_DESTROYED)
        e4reg:SetOperation(s.e4regop)
        Duel.RegisterEffect(e4reg, 0)
    end)
end

function s.e2filter(c)
    return c:IsFaceup() and c:GetMutualLinkedGroupCount() > 0
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_MZONE, 0, 1, nil) end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_FACEUP, tp, s.e2filter, tp, LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
    local ct = tc:GetMutualLinkedGroupCount()

    if not tc or ct == 0 then return end
    Duel.HintSelection(Group.FromCards(tc))

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_EXTRA_ATTACK)
    ec1:SetValue(ct)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_BATTLE)
    tc:RegisterEffect(ec1)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(1000)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e4filter(c, rc)
    return c:IsReason(REASON_BATTLE) and c:GetReasonCard() == rc
end

function s.e4regop(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(s.e4filter, nil, e:GetHandler())
    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
    end
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(function(c) return c:GetFlagEffect(id) > 0 end, tp, LOCATION_ALL, LOCATION_ALL, 1, nil) end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(function(c) return c:GetFlagEffect(id) > 0 end, tp, LOCATION_ALL, LOCATION_ALL, nil, c)

    local lp = 0
    for tc in aux.Next(g) do
        if tc:GetTextAttack() > 0 then
            lp = lp + tc:GetTextAttack()
        end
    end

    Duel.Recover(tp, lp, REASON_EFFECT)
end
