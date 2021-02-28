-- Palladium Magician's Arcane
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- lv change
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_LVCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- union
    aux.AddUnionProcedure(c, function(c)
        return c:IsSetCard(0x13a) and c:IsRace(RACE_SPELLCASTER)
    end, false)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(1068)
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- change attribute
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- material
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_GRAVE + LOCATION_HAND)
    e4:SetCountLimit(1, id)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1filter(c, lv)
    return c:IsFaceup() and c:HasLevel() and c:IsSetCard(0x13a) and
               c:IsRace(RACE_SPELLCASTER) and c:GetLevel() ~= lv
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()

    if chk == 0 then
        return Duel.IsExistingTarget(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil,
                                     c:GetLevel()) and c:HasLevel()
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1, nil,
                      c:GetLevel())
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()

    if not c:IsRelateToEffect(e) or c:IsFacedown() or not tc:IsRelateToEffect(e) or
        tc:IsFacedown() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_CHANGE_LEVEL)
    ec1:SetValue(tc:GetLevel())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)
end

function s.e2filter(c, ec)
    return ec:CheckUnionTarget(c) and aux.CheckUnionEquip(ec, c) and
               c:IsFaceup() and c:IsSetCard(0x13a) and
               c:IsRace(RACE_SPELLCASTER)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_MZONE, 0, 1, nil,
                                     c)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_MZONE, 0, 1, 1, nil, c)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() or
        not tc:IsControler(tp) or not c:IsRelateToEffect(e) then return end

    aux.CheckUnionEquip(c, tc)
    Duel.Equip(tp, c, tc)
    aux.SetUnionState(c)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetRange(LOCATION_SZONE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local ec = e:GetHandler():GetEquipTarget()
    local bc = ec:GetBattleTarget()
    return bc and bc:IsFaceup()
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec = e:GetHandler():GetEquipTarget()
    local bc = ec:GetBattleTarget()

    if not c:IsRelateToEffect(e) or not bc:IsRelateToBattle() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    ec1:SetValue(ATTRIBUTE_DARK)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_DAMAGE_CAL)
    bc:RegisterEffect(ec1)
end

function s.e4filter(c)
    return c:IsFaceup() and c:IsSetCard(0x13a) and c:IsType(TYPE_XYZ)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return not c:IsLocation(LOCATION_ONFIELD) or c:IsFaceup()
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e4filter, tp, LOCATION_MZONE, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.e4filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or
        tc:IsImmuneToEffect(e) then return end

    Duel.Overlay(tc, Group.FromCards(c))
end
