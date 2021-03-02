-- Red-Eyes Ultimate Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x3b}
s.listed_names = {CARD_REDEYES_B_DRAGON}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Fusion.AddProcMixN(c, false, false, CARD_REDEYES_B_DRAGON, 1,
                       aux.FilterBoolFunctionEx(Card.IsSetCard, 0x3b), 2)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1b:SetValue(function(e, re, tp) return tp ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e1b)

    -- act limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, 1)
    e2:SetValue(1)
    e2:SetCondition(function(e)
        local c = e:GetHandler()
        return Duel.GetAttacker() == c or Duel.GetAttackTarget() == c
    end)
    c:RegisterEffect(e2)

    -- down atk/def
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3b = Effect.CreateEffect(c)
    e3b:SetType(EFFECT_TYPE_SINGLE)
    e3b:SetCode(EFFECT_MATERIAL_CHECK)
    e3b:SetValue(s.e3matcheck)
    e3b:SetLabelObject(e3)
    c:RegisterEffect(e3b)

    -- damage
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DAMAGE + CATEGORY_TOHAND + CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_BATTLE_DAMAGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, id)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local ct = e:GetLabel()
    if chk == 0 then
        return Duel.IsExistingTarget(Card.IsFaceup, tp, 0, LOCATION_MZONE, 1,
                                     nil) and ct > 0
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, ct,
                                nil)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetTargetCards(e)
    if #g == 0 then return end

    for tc in aux.Next(g) do
        if tc:IsFaceup() and tc:IsRelateToEffect(e) then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
            ec1:SetValue(0)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec1)
            local ec1b = ec1:Clone()
            ec1b:SetCode(EFFECT_SET_DEFENSE_FINAL)
            tc:RegisterEffect(ec1b)
        end
    end
end

function s.e3matcheck(e, c)
    local mg = c:GetMaterial()
    local ct = mg:FilterCount(Card.IsCode, nil, CARD_REDEYES_B_DRAGON)
    e:GetLabelObject():SetLabel(ct)
end

function s.e4filter(c, e, tp)
    return (c:IsSetCard(0x3b) or c:IsRace(RACE_DRAGON)) and
               c:IsType(TYPE_MONSTER) and
               (s.e4check1(c) or s.e4check2(c, e, tp))
end

function s.e4check1(c) return c:IsAbleToHand() end

function s.e4check2(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp) return ep ~= tp end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e4filter, tp, LOCATION_GRAVE, 0, 1, nil,
                                     e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local tc = Duel.SelectTarget(tp, s.e4filter, tp, LOCATION_GRAVE, 0, 1, 1,
                                 nil, e, tp):GetFirst()

    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, tc:GetBaseAttack())
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    if Duel.Damage(1 - tp, tc:GetBaseAttack(), REASON_EFFECT) > 0 then
        local b1 = s.e4check1(tc)
        local b2 = s.e4check2(tc, e, tp)
        local op = 0
        if b1 and b2 then
            op = Duel.SelectOption(tp, 573, 2)
        elseif b1 then
            op = Duel.SelectOption(tp, 573)
        else
            op = Duel.SelectOption(tp, 2) + 1
        end

        Duel.BreakEffect()
        if op == 0 then
            Duel.SendtoHand(tc, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, tc)
        else
            Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end
