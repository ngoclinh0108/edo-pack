-- Supreme King Dragon Goldwurm
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- pendulum summon
    Pendulum.AddProcedure(c)

    -- cannot target
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD)
    pe1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    pe1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetTargetRange(LOCATION_MZONE, 0)
    pe1:SetTarget(aux.TargetBoolFunction(Card.IsRace, RACE_DRAGON))
    pe1:SetValue(function(e, re, rp)
        return re:IsActiveType(TYPE_TRAP) and rp ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(pe1)

    -- destroy
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 0))
    pe2:SetCategory(CATEGORY_DESTROY)
    pe2:SetType(EFFECT_TYPE_IGNITION)
    pe2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1)
    pe2:SetCondition(s.pe2con)
    pe2:SetCost(s.pe2cost)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)
end

function s.pe2filter1(c) return c:IsType(TYPE_PENDULUM) and c:IsDiscardable() end

function s.pe2filter2(c) return c:IsFaceup() end

function s.pe2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, LOCATION_PZONE, 0, 1,
                                       e:GetHandler())
end

function s.pe2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.pe2filter1, tp, LOCATION_HAND, 0,
                                           1, nil)
    end
    Duel.DiscardHand(tp, s.pe2filter1, 1, 1, REASON_COST + REASON_DISCARD)
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.pe2filter2, tp, LOCATION_MZONE,
                                     LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.pe2filter2, tp, LOCATION_MZONE,
                                LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end

    Duel.Destroy(tc, REASON_EFFECT)
end
