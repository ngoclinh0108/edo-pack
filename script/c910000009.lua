-- Palladium Chaos Oracle Aknamkanon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {59514116}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- code & attribute
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(30208479)
    c:RegisterEffect(code)
    local attribute = code:Clone()
    attribute:SetCode(EFFECT_ADD_ATTRIBUTE)
    attribute:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(attribute)

    -- no activate
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1, id + 2000000)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- to hand
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetCountLimit(1, id + 3000000)
    e3:SetCondition(aux.bdocon)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetChainLimit(function(e, rp, tp) return tp == rp end)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 1))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ACTIVATE)
    ec1:SetTargetRange(0, 1)
    ec1:SetValue(function(e, re)
        return re:GetHandler():IsOnField() or re:IsHasType(EFFECT_TYPE_ACTIVATE)
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.e3filter(c)
    return c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsAbleToHand()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e3filter, tp, LOCATION_GRAVE, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g =
        Duel.SelectTarget(tp, s.e3filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end
    Duel.SendtoHand(tc, nil, REASON_EFFECT)
end
