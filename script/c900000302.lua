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

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(function(e, c)
        return c:GetCounter(COUNTER_FEATHER) * 200
    end)
    c:RegisterEffect(e2)

    -- negate
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e3filter(c)
    return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsDisabled()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e3filter, tp, 0, LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    local tc = Duel.SelectTarget(tp, s.e3filter, tp, 0, LOCATION_MZONE, 1, 1, nil):GetFirst()

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, tc, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, tc:GetAttack())
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() or tc:IsDisabled() then
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

    if tc:IsImmuneToEffect(ec1) or tc:IsImmuneToEffect(ec1b) then
        return
    end
    Duel.AdjustInstantly(tc)
    Duel.Damage(1 - tp, tc:GetAttack(), REASON_EFFECT)
end
