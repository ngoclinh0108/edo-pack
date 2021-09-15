-- Illusory Palladium Oracle Mana
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785}

function s.initial_effect(c)
    -- atk/def up
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.e1con)
    e1:SetCost(s.e1cost)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon (target)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon (summon)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(1075)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e3:SetCountLimit(1, {id, 2})
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3b)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetAttackTarget()
    if tc and tc:IsControler(1 - tp) then tc = Duel.GetAttacker() end
    if not tc then return false end

    e:SetLabelObject(tc)
    return tc ~= e:GetHandler() and tc:IsRelateToBattle() and c:IsFaceup() and
               c:GetAttack() > 0 and tc:IsRace(RACE_SPELLCASTER)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetAttackAnnouncedCount() == 0 end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT + EFFECT_FLAG_OATH)
    ec1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local tc = e:GetLabelObject()
    if c:IsFacedown() or tc:IsFacedown() or not tc:IsRelateToBattle() then
        return
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(c:GetAttack())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_DAMAGE_CAL)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_UPDATE_DEFENSE)
    tc:RegisterEffect(ec1b)
end

function s.e2filter(c, tp)
    return not c:IsOriginalCode(id) and c:IsLocation(LOCATION_MZONE) and
               c:IsFaceup() and c:IsControler(tp)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    if rp == tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
        return false
    end
    local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if not tg then return false end

    return tg:IsExists(s.e2filter, 1, nil, tp)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if g then
        g = g:Filter(Card.IsAbleToHand, nil)
    else
        g = Group.FromCards(Duel.GetAttackTarget()):Filter(Card.IsAbleToHand,
                                                           nil)
    end
    if chk == 0 then
        return #g >= 1 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if g then
        g = g:Filter(Card.IsAbleToHand, nil)
    else
        g = Group.FromCards(Duel.GetAttackTarget()):Filter(Card.IsAbleToHand,
                                                           nil)
    end
    g = Utility.GroupSelect(HINTMSG_RTOHAND, g, tp, 1, 1, nil)
    if #g == 0 then return end
    if Duel.SendtoHand(g, nil, REASON_EFFECT) == 0 then return end
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e3filter(c, tp)
    return c:IsFaceup() and c:IsCode(71703785) and c:IsSummonPlayer(tp) and
               c:IsLocation(LOCATION_MZONE)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e3filter, 1, nil, tp)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_MZONE) ==
        0 then return end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end
