-- Palladium Sacred Oracle Mana
local s, id = GetID()

s.listed_names = {CARD_DARK_MAGICIAN_GIRL}
s.listed_series = {0x13a}

function s.initial_effect(c)
    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(CARD_DARK_MAGICIAN_GIRL)
    c:RegisterEffect(code)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- indes
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetTarget(function(e, c)
        return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER)
    end)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- atk up
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e3:SetRange(LOCATION_HAND + LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()

    local rg = Duel.GetMatchingGroup(Card.IsDiscardable, tp, LOCATION_HAND, 0,
                                     e:GetHandler())
    return aux.SelectUnselectGroup(rg, e, tp, 1, 1, aux.ChkfMMZ(1), 0, c)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, c)
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

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end
    Duel.SendtoGrave(g, REASON_DISCARD + REASON_COST)
    g:DeleteGroup()
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = Duel.GetAttackTarget()
    if not c then return false end

    if c:IsControler(1 - tp) then c = Duel.GetAttacker() end
    e:SetLabelObject(c)
    return c and c ~= e:GetHandler() and c:IsRelateToBattle() and
               c:IsSetCard(0x13a)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c, REASON_COST)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetLabelObject()
    if c:IsFacedown() or not c:IsRelateToBattle() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(2000)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_DAMAGE_CAL)
    c:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(ec1b)
end
