-- Djeser!
local s, id = GetID()

s.listed_names = {10000000, 10000020, CARD_RA, 10000040}

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)

    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- set
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- summon protect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x13a))
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_CANNOT_DISABLE_FLIP_SUMMON)
    c:RegisterEffect(e2b)
    local e2c = e2:Clone()
    e2c:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(e2c)

    -- effect protect
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_INACTIVATE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetValue(s.e3val)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e3b)

    -- search card
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_SZONE)
    e4:SetHintTiming(0, TIMING_END_PHASE)
    e4:SetCountLimit(1)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- summon holactie
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 3))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_SZONE)
    e5:SetCountLimit(1)
    e5:SetCost(s.e5cost)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsSSetable() end
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsSSetable() then return end

    Duel.SSet(tp, c)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    ec1:SetValue(LOCATION_REMOVED)
    ec1:SetReset(RESET_EVENT + RESETS_REDIRECT)
    c:RegisterEffect(ec1)
end

function s.e3val(e, ct)
    local c = e:GetHandler()
    local p = c:GetControler()
    local te, tp = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT,
                                     CHAININFO_TRIGGERING_PLAYER)
    return p == tp and te:GetHandler():IsSetCard(0x13a)
end

function s.e4filter1(c)
    return c:IsAttribute(ATTRIBUTE_DIVINE) and not c:IsPublic()
end

function s.e4filter2(c)
    return c:IsSetCard(0x13a) and not c:IsCode(id) and
               c:IsLocation(LOCATION_DECK + LOCATION_GRAVE) and c:IsAbleToHand()
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter1, tp, LOCATION_HAND, 0, 1,
                                           nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.e4filter1, tp, LOCATION_HAND, 0, 1,
                                      1, nil)
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter2, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 0))
    local tc = Duel.SelectMatchingCard(tp, s.e4filter2, tp,
                                       LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                       nil):GetFirst()
    if not tc then return end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, tc)
end

function s.e5filter1(c, code)
    local code2, code3 = c:GetOriginalCodeRule()
    return code2 == code or code3 == code
end

function s.e5filter2(c, e, tp)
    return c:IsCode(10000040) and
               c:IsCanBeSpecialSummoned(e, 0, tp, true, false, POS_FACEUP_ATTACK)
end

function s.e5rescon(sg, e, tp, mg)
    return aux.ChkfMMZ(1)(sg, e, tp, mg) and
               sg:IsExists(s.e5check, 1, nil, sg, Group.CreateGroup(), 10000000,
                           10000020, CARD_RA)
end

function s.e5check(c, sg, g, code, ...)
    local code2, code3 = c:GetOriginalCodeRule()
    if code ~= code2 and code ~= code3 then return false end
    local res
    if ... then
        g:AddCard(c)
        res = sg:IsExists(s.e5check, 1, g, sg, g, ...)
        g:RemoveCard(c)
    else
        res = true
    end
    return res
end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local rg = Duel.GetReleaseGroup(tp)
    local g1 = rg:Filter(s.e5filter1, nil, 10000000)
    local g2 = rg:Filter(s.e5filter1, nil, 10000020)
    local g3 = rg:Filter(s.e5filter1, nil, CARD_RA)
    local g = g1:Clone()
    g:Merge(g2)
    g:Merge(g3)

    if chk == 0 then
        return c:IsAbleToGraveAsCost() and #g1 > 0 and #g2 > 0 and #g3 > 0 and
                   aux.SelectUnselectGroup(g, e, tp, 3, 3, s.e5rescon, 0)
    end

    Duel.SendtoGrave(c, REASON_COST)

    local sg = aux.SelectUnselectGroup(g, e, tp, 3, 3, s.e5rescon, 1, tp,
                                       HINTMSG_RELEASE, s.e5rescon, nil, true)
    Duel.Release(sg, REASON_COST)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e5filter2, tp, LOCATION_HAND +
                                                   LOCATION_DECK +
                                                   LOCATION_GRAVE, 0, 1, nil, e,
                                               tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, 0)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc = Duel.SelectMatchingCard(tp, s.e5filter2, tp, LOCATION_HAND +
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                       1, nil, e, tp):GetFirst()
    if not tc then return end

    Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP_ATTACK)
end
