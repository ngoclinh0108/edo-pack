-- Palladium Magician's Robe
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
end

function s.e1filter(c, lv)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and
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
