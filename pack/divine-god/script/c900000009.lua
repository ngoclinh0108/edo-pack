-- The Chosen Pharaoh
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {39913299, 10000000, 10000020, CARD_RA, 10000040}

function s.initial_effect(c)
    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                                                    EFFECT_FLAG_CANNOT_INACTIVATE

    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetHintTiming(0, TIMING_END_PHASE)
    c:RegisterEffect(act)

    -- inactivatable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e1:SetCode(EFFECT_CANNOT_INACTIVATE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e1b)

    -- leaving the field
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e2:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- search "the true name"
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetHintTiming(0, TIMING_END_PHASE)
    e3:SetCountLimit(1, {id, 1})
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- special summon a Divine-Beast
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_SZONE)
    e4:SetHintTiming(0, TIMING_END_PHASE)
    e4:SetCountLimit(1, {id, 1})
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- add or set spell/trap that mentions Divine-Beast
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_SZONE)
    e5:SetHintTiming(0, TIMING_END_PHASE)
    e5:SetCountLimit(1, {id, 1})
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- call holactie
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 3))
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e6:SetCode(EVENT_FREE_CHAIN)
    e6:SetRange(LOCATION_SZONE + LOCATION_GRAVE)
    e6:SetHintTiming(0, TIMING_END_PHASE)
    e6:SetCountLimit(1, id, EFFECT_COUNT_CODE_DUEL)
    e6:SetCondition(s.e6con)
    e6:SetCost(s.e6cost)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
end

function s.e1val(e, ct)
    local p = e:GetHandler():GetControler()
    local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER,
        CHAININFO_TRIGGERING_LOCATION)
    local tc = te:GetHandler()
    return p == tp and tc:IsCode(39913299) and (loc & LOCATION_ONFIELD) ~= 0
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local g = Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
    Duel.Destroy(g, REASON_EFFECT)
end

function s.e3filter(c) return c:IsCode(39913299) and c:IsAbleToHand() end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, aux.NecroValleyFilter(s.e3filter), tp,
        LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e4filter(c, e, tp) return c:IsOriginalRace(RACE_DIVINE) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil, e, tp)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_GRAVE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.e4filter), tp,
        LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.e5filter1(c, tp)
    return c:IsFaceup() and c:IsOriginalRace(RACE_DIVINE) and
               Duel.IsExistingMatchingCard(s.e5filter2, tp, LOCATION_DECK, 0, 1, nil, tp, c)
end

function s.e5filter2(c, tp, sc)
    return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, c:GetCode()), tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0,
        1, nil) and c:ListsCode(sc:GetCode()) and c:IsSpellTrap() and (c:IsSSetable() or c:IsAbleToHand())
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e5filter1, tp, LOCATION_MZONE, 0, 1, nil, tp) end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local sc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e5filter1, tp, LOCATION_MZONE, 0, 1, 1, nil, tp):GetFirst()
    if not sc then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e5filter2, tp, LOCATION_DECK, 0, 1, 1, nil, tp, sc):GetFirst()
    aux.ToHandOrElse(tc, tp, function(c) return tc:IsSSetable() end, function(c) Duel.SSet(tp, tc) end, 1159)
end

function s.e6filter1(c) return c:IsCode(39913299) and c:IsDiscardable() end

function s.e6filter2(c, code)
    local code1, code2 = c:GetOriginalCodeRule()
    return code1 == code or code2 == code
end

function s.e6rescon(sg, e, tp, mg)
    return aux.ChkfMMZ(1)(sg, e, tp, mg) and sg:IsExists(s.e6chk, 1, nil, sg, Group.CreateGroup(), 10000000, 10000020, CARD_RA)
end

function s.e6chk(c, sg, g, code, ...)
    local code1, code2 = c:GetOriginalCodeRule()
    if code ~= code1 and code ~= code2 then return false end
    local res
    if ... then
        g:AddCard(c)
        res = sg:IsExists(s.e6chk, 1, g, sg, g, ...)
        g:RemoveCard(c)
    else
        res = true
    end
    return res
end

function s.e6con(e, tp, eg, ep, ev, re, r, rp) return Duel.IsTurnPlayer(tp) end

function s.e6cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local rg = Duel.GetReleaseGroup(tp)
    local g1 = rg:Filter(s.e6filter2, nil, 10000000)
    local g2 = rg:Filter(s.e6filter2, nil, 10000020)
    local g3 = rg:Filter(s.e6filter2, nil, CARD_RA)
    local mg = Group.CreateGroup()
    mg:Merge(g1)
    mg:Merge(g2)
    mg:Merge(g3)

    if chk == 0 then
        return c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.e6filter1, tp, LOCATION_HAND, 0, 1, nil) and
                   Duel.CheckReleaseGroupCost(tp, nil, 2, false, nil, c) and Duel.GetLocationCount(tp, LOCATION_MZONE) > -3 and
                   #g1 > 0 and #g2 > 0 and #g3 > 0 and aux.SelectUnselectGroup(mg, e, tp, 3, 3, s.e6rescon, 0)
    end

    Duel.Remove(c, POS_FACEUP, REASON_COST)
    Duel.DiscardHand(tp, s.e6filter1, 1, 1, REASON_COST + REASON_DISCARD)
    local sg = aux.SelectUnselectGroup(mg, e, tp, 3, 3, s.e6rescon, 1, tp, HINTMSG_RELEASE, s.e6rescon, nil, true)
    Duel.Release(sg, REASON_COST)
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsPlayerCanSpecialSummonMonster(tp, 10000040, 0, TYPE_MONSTER + TYPE_EFFECT, 0, 0, 12, RACE_CREATORGOD,
            ATTRIBUTE_DIVINE)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, 0)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.CreateToken(tp, 10000040)
    Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP_ATTACK)
end
