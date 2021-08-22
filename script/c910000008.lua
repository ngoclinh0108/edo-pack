-- Palladium Illusion Oracle Mana
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_MAGICIAN, CARD_DARK_MAGICIAN_GIRL}

function s.initial_effect(c)
    -- code & attribute
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(CARD_DARK_MAGICIAN_GIRL)
    c:RegisterEffect(code)
    local attribute = code:Clone()
    attribute:SetCode(EFFECT_ADD_ATTRIBUTE)
    attribute:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(attribute)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, id + 1000000)
    e1:SetCondition(s.e1con1)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1b:SetCondition(s.e1con2)
    c:RegisterEffect(e1b)

    -- search
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, id + 2000000)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2b)

    -- atk up
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e3:SetRange(LOCATION_HAND + LOCATION_MZONE)
    e3:SetCountLimit(1, id + 3000000)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c, tp)
    return c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_SPELLCASTER) and
               c:IsFaceup() and c:IsControler(tp)
end

function s.e1con1(e, tp, eg, ep, ev, re, r, rp)
    if rp == tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
        return false
    end
    local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if not tg then return false end

    return tg:IsExists(s.e1filter, 1, nil, tp)
end

function s.e1con2(e, tp, eg, ep, ev, re, r, rp)
    if Duel.IsTurnPlayer(tp) or not Duel.GetAttackTarget() then return false end
    return s.e1filter(Duel.GetAttackTarget(), tp)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if g then
        g = g:Filter(Card.IsAbleToHandAsCost, nil)
    else
        g = Group.FromCards(Duel.GetAttackTarget()):Filter(
                Card.IsAbleToHandAsCost, nil)
    end
    if chk == 0 then return #g >= 1 end

    g = Utility.GroupSelect(g, tp, 1, 1, HINTMSG_RTOHAND)
    Duel.SendtoHand(g, nil, 1, REASON_COST)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e2filter(c)
    return aux.IsCodeListed(c, CARD_DARK_MAGICIAN, CARD_DARK_MAGICIAN_GIRL) and
               c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsAbleToHand()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.e2filter, tp, LOCATION_DECK, 0, 1,
                                      1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetAttackTarget()
    if tc and tc:IsControler(1 - tp) then tc = Duel.GetAttacker() end
    if not tc then return false end

    e:SetLabelObject(tc)
    return tc ~= e:GetHandler() and tc:IsRelateToBattle() and
               tc:IsRace(RACE_SPELLCASTER) and
               tc:IsAttribute(ATTRIBUTE_LIGHT + ATTRIBUTE_DARK)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c, REASON_COST)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local tc = e:GetLabelObject()
    if tc:IsFacedown() or not tc:IsRelateToBattle() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(c:GetBaseAttack())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_DAMAGE_CAL)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_UPDATE_DEFENSE)
    tc:RegisterEffect(ec1b)
end
