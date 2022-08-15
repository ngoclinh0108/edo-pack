-- Majestic Black Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()
s.counter_list = {COUNTER_FEATHER}

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:EnableCounterPermit(COUNTER_FEATHER)

    -- synchro summon
    SignerDragon.AddMajesticProcedure(c, s, CARD_BLACK_WINGED_DRAGON)
    SignerDragon.AddMajesticReturn(c, CARD_BLACK_WINGED_DRAGON)

    -- place counter
    local e1reg = Effect.CreateEffect(c)
    e1reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1reg:SetCode(EVENT_CHAINING)
    e1reg:SetRange(LOCATION_MZONE)
    e1reg:SetOperation(aux.chainreg)
    c:RegisterEffect(e1reg)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAIN_SOLVED)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return re:IsActiveType(TYPE_MONSTER) and re:GetHandler() ~= c and c:GetFlagEffect(1) ~= 0
    end)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        e:GetHandler():AddCounter(COUNTER_FEATHER, 1)
    end)
    c:RegisterEffect(e1)

    -- negate
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e2filter(c)
    return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsDisabled()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e2filter, tp, 0, LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, 0, LOCATION_MZONE, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then
        return
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(ec1b)
end
