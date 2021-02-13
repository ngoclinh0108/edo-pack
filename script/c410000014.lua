-- Palladium Magician's Soul
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- union
    aux.AddUnionProcedure(c, function(c)
        return c:IsSetCard(0x13a) and c:IsRace(RACE_SPELLCASTER)
    end, false)

    -- equip
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(1068)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- lv change
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_LVCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
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
end

function s.e1filter(c, ec)
    return c:IsFaceup() and c:IsLevel(7) and c:IsSetCard(0x13a) and
               c:IsRace(RACE_SPELLCASTER) and ec:CheckUnionTarget(c) and
               aux.CheckUnionEquip(ec, c)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingTarget(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil,
                                     c)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1, nil, c)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
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

function s.e2filter(c, lv)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and
               c:IsRace(RACE_SPELLCASTER) and c:GetLevel() ~= lv
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()

    if chk == 0 then
        return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_MZONE, 0, 1, nil,
                                     c:GetLevel()) and c:HasLevel()
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_MZONE, 0, 1, 1, nil,
                      c:GetLevel())
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
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
