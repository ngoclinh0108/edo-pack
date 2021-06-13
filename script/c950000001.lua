-- Supreme Soul
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {13331639}
s.listed_series = {0x98, 0x10f8, 0x20f8, 0x10f2, 0x2073, 0x2017, 0x1046}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_DISABLE +
                       EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- protect other spell/trap
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_SZONE, 0)
    e2:SetTarget(function(e, tc) return tc:IsFaceup() end)
    e2:SetValue(aux.indoval)
    c:RegisterEffect(e2)

    -- cannot be target
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e3:SetTarget(function(e, c)
        return e:GetHandler():GetLinkedGroup():IsContains(c)
    end)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)

    -- summon Z-ARC
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_DISABLE +
                       EFFECT_FLAG_CANNOT_NEGATE)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- special summon from pendulum zone
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_CANNOT_INACTIVATE +
                       EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_SZONE)
    e5:SetHintTiming(0, TIMING_END_PHASE)
    e5:SetCountLimit(2, id)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- place in pendulum zone
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 3))
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_CANNOT_INACTIVATE +
                       EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e6:SetCode(EVENT_FREE_CHAIN)
    e6:SetRange(LOCATION_SZONE)
    e6:SetHintTiming(0, TIMING_END_PHASE)
    e6:SetCountLimit(2, id)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
end

function s.deck_edit(tp)
    -- Supreme King Dragon Odd-Eyes
    if Duel.IsExistingMatchingCard(Card.IsCode, tp,
                                   LOCATION_DECK + LOCATION_EXTRA, 0, 1, nil,
                                   16178681) and
        not Duel.IsExistingMatchingCard(Card.IsCode, tp,
                                        LOCATION_DECK + LOCATION_EXTRA, 0, 1,
                                        nil, 96733134) then
        Duel.SendtoExtraP(Duel.CreateToken(tp, 96733134), tp, REASON_RULE)
    end

    -- Supreme King Dragon Dark Rebellion
    if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_EXTRA, 0, 1, nil,
                                   16195942) and
        not Duel.IsExistingMatchingCard(Card.IsCode, tp,
                                        LOCATION_DECK + LOCATION_EXTRA, 0, 1,
                                        nil, 42160203) then
        Duel.SendtoDeck(Duel.CreateToken(tp, 42160203), tp, 2, REASON_RULE)
    end

    -- Supreme King Dragon Clear Wing
    if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_EXTRA, 0, 1, nil,
                                   82044279) and
        not Duel.IsExistingMatchingCard(Card.IsCode, tp,
                                        LOCATION_DECK + LOCATION_EXTRA, 0, 1,
                                        nil, 70771599) then
        Duel.SendtoDeck(Duel.CreateToken(tp, 70771599), tp, 2, REASON_RULE)
    end

    -- Supreme King Dragon Starving Venom
    if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_EXTRA, 0, 1, nil,
                                   41209827) and
        not Duel.IsExistingMatchingCard(Card.IsCode, tp,
                                        LOCATION_DECK + LOCATION_EXTRA, 0, 1,
                                        nil, 43387895) then
        Duel.SendtoDeck(Duel.CreateToken(tp, 43387895), tp, 2, REASON_RULE)
    end

    -- Supreme King Z-Arc - Overlord
    if not Duel.IsExistingMatchingCard(Card.IsCode, tp,
                                       LOCATION_DECK + LOCATION_EXTRA, 0, 1,
                                       nil, 950000005) then
        Duel.SendtoDeck(Duel.CreateToken(tp, 950000005), tp, 2, REASON_RULE)
    end
end

function s.e1filter1(c)
    if not c:IsType(TYPE_PENDULUM) or c:IsForbidden() then return false end
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsSetCard(0x98) or c:IsSetCard(0x10f8)
end

function s.e1filter2(c, lsc, rsc)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    if not c:IsAbleToHand() and
        not c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP) then
        return false
    end
    return lsc < c:GetLevel() and c:GetLevel() < rsc and c:IsSetCard(0x20f8)
end

function s.e1check(sg, e, tp) return sg:GetClassCount(Card.GetCode) == 2 end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA
    local g = Duel.GetMatchingGroup(s.e1filter1, tp, loc, 0, nil)
    if chk == 0 then
        return Utility.CountFreePendulumZones(tp) >= 2 and
                   (Duel.GetLocationCount(tp, LOCATION_SZONE) >= 2 or
                       c:IsLocation(LOCATION_SZONE)) and
                   aux.SelectUnselectGroup(g, e, tp, 2, 2, s.e1check, 0)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 2, tp, loc)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    if Utility.CountFreePendulumZones(tp) < 2 then return end
    local g1 = aux.SelectUnselectGroup(Duel.GetMatchingGroup(
                                           aux.NecroValleyFilter(s.e1filter1),
                                           tp, LOCATION_HAND + LOCATION_DECK +
                                               LOCATION_GRAVE + LOCATION_EXTRA,
                                           0, nil), e, tp, 2, 2, s.e1check, 1,
                                       tp, HINTMSG_ATOHAND)
    if #g1 < 2 then return end
    for tc in aux.Next(g1) do
        Duel.MoveToField(tc, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
    end

    if Duel.GetFieldCard(tp, LOCATION_PZONE, 0) and
        Duel.GetFieldCard(tp, LOCATION_PZONE, 1) then
        local lsc = Duel.GetFieldCard(tp, LOCATION_PZONE, 0):GetLeftScale()
        local rsc = Duel.GetFieldCard(tp, LOCATION_PZONE, 1):GetRightScale()
        if lsc > rsc then lsc, rsc = rsc, lsc end
        local g2 = Duel.GetMatchingGroup(s.e1filter2, tp, LOCATION_DECK +
                                             LOCATION_GRAVE + LOCATION_EXTRA, 0,
                                         nil, lsc, rsc)
        if #g2 > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            local sc = g2:Select(tp, 1, 1, nil):GetFirst()
            aux.ToHandOrElse(sc, tp, function(tc)
                local ft = tc:IsLocation(LOCATION_EXTRA) and
                               Duel.GetLocationCountFromEx(tp, rp, nil) or
                               Duel.GetLocationCount(tp, LOCATION_MZONE)
                return tc:IsCanBeSpecialSummoned(e, 0, tp, false, false,
                                                 POS_FACEUP) and ft > 0
            end, function(tc)
                Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
            end, 2)
        end
    end
end

function s.e4filter1(c, e, tp, sg)
    return c:IsCode(13331639) and
               c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and
               Duel.GetLocationCountFromEx(tp, tp, sg or nil, c) > 0
end

function s.e4filter2(c)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return (c:IsSetCard(0x10f2) or c:IsSetCard(0x2073) or c:IsSetCard(0x2017) or
               c:IsSetCard(0x1046)) and c:IsType(TYPE_MONSTER) and
               c:IsAbleToRemoveAsCost() and
               (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup()) and
               (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c, true, true))
end

function s.e4rescon(checkfunc)
    return function(sg, e, tp, mg)
        if not sg:CheckDifferentProperty(checkfunc) then
            return false, true
        end

        return Duel.IsExistingMatchingCard(s.e4filter1, tp, LOCATION_EXTRA, 0,
                                           1, nil, e, tp, sg)
    end
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local mg = Duel.GetMatchingGroup(s.e4filter2, tp, LOCATION_HAND +
                                         LOCATION_MZONE + LOCATION_GRAVE +
                                         LOCATION_EXTRA, 0, c)
    local checkfunc = aux.PropertyTableFilter(Card.GetSetCard, 0x10f2, 0x2073,
                                              0x2017, 0x1046)

    if chk == 0 then
        return
            aux.SelectUnselectGroup(mg, e, tp, 4, 4, s.e4rescon(checkfunc), 0)
    end

    local sg = aux.SelectUnselectGroup(mg, e, tp, 4, 4, s.e4rescon(checkfunc),
                                       1, tp, HINTMSG_REMOVE,
                                       s.e4rescon(checkfunc))
    Duel.Remove(sg, POS_FACEUP, REASON_COST)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetChainLimit(aux.FALSE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc = Duel.SelectMatchingCard(tp, s.e4filter1, tp, LOCATION_EXTRA, 0,
                                       1, 1, nil, e, tp):GetFirst()
    if not tc then return end

    if Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP) > 0 then
        tc:CompleteProcedure()
    end
end

function s.e5filter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingTarget(s.e5filter, tp, LOCATION_PZONE, 0, 1,
                                         nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.e5filter, tp, LOCATION_PZONE, 0, 1, 1,
                                nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) then return end
    if not tc:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP)
end

function s.e6filter(c) return c:IsFaceup() and c:IsType(TYPE_PENDULUM) end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return (Duel.CheckLocation(tp, LOCATION_PZONE, 0) or
                   Duel.CheckLocation(tp, LOCATION_PZONE, 1)) and
                   Duel.IsExistingTarget(s.e6filter, tp, LOCATION_MZONE, 0, 1,
                                         nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 2))
    Duel.SelectTarget(tp, s.e6filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or
        not (Duel.CheckLocation(tp, LOCATION_PZONE, 0) or
            Duel.CheckLocation(tp, LOCATION_PZONE, 1)) then return end

    local tc = Duel.GetFirstTarget()
    if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end

    Duel.MoveToField(tc, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
end
