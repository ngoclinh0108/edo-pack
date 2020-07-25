-- Djeser!
local s, id = GetID()

s.listed_names = {410000011, 10000040}

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)

    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- summon protect
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x13a))
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_CANNOT_DISABLE_FLIP_SUMMON)
    c:RegisterEffect(e1b)
    local e1c = e1:Clone()
    e1c:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(e1c)

    -- effect protect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_INACTIVATE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetValue(s.e2val)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e2b)

    -- take card
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetHintTiming(0, TIMING_END_PHASE)
    e3:SetCountLimit(1)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- summon holactie
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 3))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- activate direct
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_GRAVE)
    e5:SetCountLimit(1, id)
    e5:SetCondition(s.e5con)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.e2val(e, ct)
    local c = e:GetHandler()
    local p = c:GetControler()
    local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT,
                                          CHAININFO_TRIGGERING_PLAYER,
                                          CHAININFO_TRIGGERING_LOCATION)
    return p == tp and te:GetHandler():IsSetCard(0x13a) and loc &
               LOCATION_ONFIELD ~= 0
end

function s.e3bool1(c)
    return c:IsLocation(LOCATION_DECK + LOCATION_GRAVE) and c:IsAbleToHand()
end

function s.e3bool2(c, e, tp)
    return c:IsLocation(LOCATION_HAND + LOCATION_GRAVE) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e3filter1(c)
    return c:IsAttribute(ATTRIBUTE_DIVINE) and not c:IsPublic()
end

function s.e3filter2(c, e, tp)
    return c:IsSetCard(0x13a) and (s.e3bool1(c) or s.e3bool2(c, e, tp))
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_HAND, 0, 1,
                                           nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.e3filter1, tp, LOCATION_HAND, 0, 1,
                                      1, nil)
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter2, tp, LOCATION_HAND +
                                               LOCATION_DECK + LOCATION_GRAVE,
                                           0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 0))
    local tc = Duel.SelectMatchingCard(tp, s.e3filter2, tp, LOCATION_HAND +
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                       1, nil, e, tp):GetFirst()
    if not tc then return end
    local b1 = s.e3bool1(tc)
    local b2 = s.e3bool2(tc, e, tp)

    local op = 0
    if b1 and b2 then
        op = Duel.SelectOption(tp, aux.Stringid(id, 1), aux.Stringid(id, 2))
    elseif b1 then
        op = Duel.SelectOption(tp, aux.Stringid(id, 1))
    else
        op = Duel.SelectOption(tp, aux.Stringid(id, 2)) + 1
    end

    if op == 0 then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, tc)
    else
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    end
end

function s.e4filter1(c, code)
    local code1, code2 = c:GetOriginalCodeRule()
    return code1 == code or code2 == code
end

function s.e4filter2(c, e, tp)
    return c:IsCode(10000040) and
               c:IsCanBeSpecialSummoned(e, 0, tp, true, false, POS_FACEUP_ATTACK)
end

function s.e4rescon(sg, e, tp, mg)
    return aux.ChkfMMZ(1)(sg, e, tp, mg) and
               sg:IsExists(s.e4check, 1, nil, sg, Group.CreateGroup(), 10000000,
                           10000020, CARD_RA)
end

function s.e4check(c, sg, g, code, ...)
    local code1, code2 = c:GetOriginalCodeRule()
    if code ~= code1 and code ~= code2 then return false end
    local res
    if ... then
        g:AddCard(c)
        res = sg:IsExists(s.e4check, 1, g, sg, g, ...)
        g:RemoveCard(c)
    else
        res = true
    end
    return res
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local rg = Duel.GetReleaseGroup(tp)
    local g1 = rg:Filter(s.e4filter1, nil, 10000000)
    local g2 = rg:Filter(s.e4filter1, nil, 10000020)
    local g3 = rg:Filter(s.e4filter1, nil, CARD_RA)
    local g = g1:Clone()
    g:Merge(g2)
    g:Merge(g3)

    if chk == 0 then
        return c:IsAbleToGraveAsCost() and #g1 > 0 and #g2 > 0 and #g3 > 0 and
                   aux.SelectUnselectGroup(g, e, tp, 3, 3, s.e4rescon, 0)
    end

    Duel.SendtoGrave(c, REASON_COST)

    local sg = aux.SelectUnselectGroup(g, e, tp, 3, 3, s.e4rescon, 1, tp,
                                       HINTMSG_RELEASE, s.e4rescon, nil, true)
    Duel.Release(sg, REASON_COST)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e4filter2, tp, LOCATION_HAND +
                                                   LOCATION_DECK +
                                                   LOCATION_GRAVE, 0, 1, nil, e,
                                               tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, 0)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc = Duel.SelectMatchingCard(tp, s.e4filter2, tp, LOCATION_HAND +
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                       1, nil, e, tp):GetFirst()
    if not tc then return end

    Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP_ATTACK)
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsEnvironment(410000011, tp)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetActivateEffect() and
                   c:GetActivateEffect():IsActivatable(tp, true)
    end
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.MoveToField(c, tp, tp, LOCATION_SZONE, POS_FACEUP, true)
    Duel.RaiseEvent(c, id, c:GetActivateEffect(), 0, tp, tp,
                    Duel.GetCurrentChain())
end