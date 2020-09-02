-- Palladium Sacred Oracle Mana
local s, id = GetID()

s.listed_names = {CARD_DARK_MAGICIAN_GIRL}

function s.initial_effect(c)
    -- code
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetValue(CARD_DARK_MAGICIAN_GIRL)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetRange(LOCATION_HAND)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- indes
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE, 0)
    e3:SetTarget(s.e3tg)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- atk up
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e4:SetRange(LOCATION_HAND + LOCATION_MZONE)
    e4:SetCountLimit(1, id)
    e4:SetCondition(s.e4con)
    e4:SetCost(s.e4cost)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e2con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()

    local rg = Duel.GetMatchingGroup(Card.IsDiscardable, tp, LOCATION_HAND, 0,
                                     e:GetHandler())
    return aux.SelectUnselectGroup(rg, e, tp, 1, 1, aux.ChkfMMZ(1), 0, c)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, c)
    local rg = Duel.GetMatchingGroup(Card.IsDiscardable, tp, LOCATION_HAND, 0,
                                     e:GetHandler())
    local g = aux.SelectUnselectGroup(rg, e, tp, 1, 1, aux.ChkfMMZ(1), 1, tp,
                                      HINTMSG_DISCARD, nil, nil, true)

    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end
    Duel.SendtoGrave(g, REASON_DISCARD + REASON_COST)
    g:DeleteGroup()
end

function s.e3tg(e, c) return c:IsSetCard(0x13a) end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local c = Duel.GetAttackTarget()
    if not c then return false end

    if c:IsControler(1 - tp) then c = Duel.GetAttacker() end
    e:SetLabelObject(c)
    return c and c ~= e:GetHandler() and c:IsSetCard(0x13a) and
               c:IsRelateToBattle()
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c, REASON_COST)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetLabelObject()
    if c:IsFacedown() or not c:IsRelateToBattle() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(2000)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_DAMAGE_CAL)
    c:RegisterEffect(ec1)
    local e1b = ec1:Clone()
    e1b:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e1b)

end
