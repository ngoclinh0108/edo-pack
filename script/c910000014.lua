-- Palladium Knight Gaia
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, {id, 1}, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- extra material
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
    e3:SetCondition(function(e)
        return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(), 69832741)
    end)
    e3:SetValue(function(e, c) return c:IsSetCard(0x13a) end)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3b:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
    e3b:SetRange(LOCATION_GRAVE)
    e3b:SetOperation(Fusion.BanishMaterial)
    c:RegisterEffect(e3b)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return false end
    return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0 or
               Duel.IsExistingMatchingCard(
                   aux.FilterFaceupFunction(Card.IsAttackAbove, 2000), tp, 0,
                   LOCATION_MZONE, 1, nil)
end

function s.e2filter(c)
    return c:IsSetCard(0x13a) and c:IsMonster() and not c:IsCode(id) and
               c:IsAbleToHand()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE, 0, 1,
                                         nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
    local g =
        Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    Duel.SendtoHand(tc, nil, REASON_EFFECT)
end
