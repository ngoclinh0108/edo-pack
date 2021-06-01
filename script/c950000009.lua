-- Supreme King Dragon Rebelliwurm
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {13331639}
s.listed_series = {0x98, 0x99, 0x10f8, 0x20f8}

function s.initial_effect(c)
    -- pendulum summon
    Pendulum.AddProcedure(c)

    -- scale
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_SINGLE)
    pe1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    pe1:SetCode(EFFECT_CHANGE_LSCALE)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCondition(s.pe1con)
    pe1:SetValue(4)
    c:RegisterEffect(pe1)
    local pe1b = pe1:Clone()
    pe1b:SetCode(EFFECT_CHANGE_RSCALE)
    c:RegisterEffect(pe1b)

    -- rank
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 0))
    pe2:SetType(EFFECT_TYPE_IGNITION)
    pe2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- rank-up
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 1))
    me1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me1:SetType(EFFECT_TYPE_IGNITION)
    me1:SetRange(LOCATION_MZONE + LOCATION_HAND)
    me1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    me1:SetCountLimit(1, id + 1 * 1000000)
    me1:SetCost(s.me1cost)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- xyz limit
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_SINGLE)
    me2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    me2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    me2:SetValue(function(e, c)
        if not c then return false end
        return not c:IsRace(RACE_DRAGON)
    end)
    c:RegisterEffect(me2)

    -- special summon
    local me3 = Effect.CreateEffect(c)
    me3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me3:SetType(EFFECT_TYPE_IGNITION)
    me3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    me3:SetRange(LOCATION_HAND + LOCATION_GRAVE + LOCATION_EXTRA)
    me3:SetCountLimit(1, id + 2 * 1000000)
    me3:SetTarget(s.me3tg)
    me3:SetOperation(s.me3op)
    c:RegisterEffect(me3)

    -- xyz summon
    local me4 = Effect.CreateEffect(c)
    me4:SetDescription(1173)
    me4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me4:SetType(EFFECT_TYPE_IGNITION)
    me4:SetRange(LOCATION_MZONE)
    me4:SetCountLimit(1)
    me4:SetTarget(s.me4tg)
    me4:SetOperation(s.me4op)
    c:RegisterEffect(me4)
end

function s.pe1con(e)
    return not Duel.IsExistingMatchingCard(function(c)
        return c:IsCode(13331639) or c:IsSetCard(0x98) or c:IsSetCard(0x99) or
                   c:IsSetCard(0x10f8) or c:IsSetCard(0x20f8)
    end, e:GetHandlerPlayer(), LOCATION_PZONE, 0, 1, e:GetHandler())
end

function s.pe2filter1(c, tp)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and
               Duel.IsExistingTarget(s.pe2filter2, tp, LOCATION_MZONE, 0, 1, c)
end

function s.pe2filter2(c)
    return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:HasLevel()
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.pe2filter1, tp, LOCATION_MZONE, 0, 1,
                                     nil, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local tc1 = Duel.SelectTarget(tp, s.pe2filter1, tp, LOCATION_MZONE, 0, 1, 1,
                                  nil, tp):GetFirst()
    e:SetLabelObject(tc1)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.pe2filter2, tp, LOCATION_MZONE, 0, 1, 1, tc1)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    local tc1 = e:GetLabelObject()
    local tc2 = tg:GetFirst()
    if tc1 == tc2 then tc2 = tg:GetNext() end

    if not tc1:IsRelateToEffect(e) or tc1:IsFacedown() or
        not tc2:IsRelateToEffect(e) or tc2:IsFacedown() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_CHANGE_RANK)
    ec1:SetValue(tc2:GetLevel())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc1:RegisterEffect(ec1)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetCode(EFFECT_XYZ_LEVEL)
    ec2:SetValue(function(e, c) return c:GetRank() end)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc1:RegisterEffect(ec2)
end

function s.me1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(), REASON_COST)
end

function s.me1filter1(c, e, tp)
    local pg = aux.GetMustBeMaterialGroup(tp, Group.FromCards(c), tp, nil, nil,
                                          REASON_XYZ)
    return (#pg <= 0 or (#pg == 1 and pg:IsContains(c))) and c:IsFaceup() and
               c:IsRank(4) and c:IsAttribute(ATTRIBUTE_DARK) and
               c:IsRace(RACE_DRAGON) and
               Duel.IsExistingMatchingCard(s.me1filter2, tp, LOCATION_EXTRA, 0,
                                           1, nil, e, tp, c, pg)
end

function s.me1filter2(c, e, tp, mc, pg)
    if c.rum_limit and not c.rum_limit(mc, e) then return false end
    return mc:IsType(TYPE_XYZ, c, SUMMON_TYPE_XYZ, tp) and
               Duel.GetLocationCountFromEx(tp, tp, mc, c) > 0 and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_XYZ, tp, false, false) and
               c:IsRank(mc:GetRank() + 1) and c:IsAttribute(ATTRIBUTE_DARK) and
               c:IsRace(RACE_DRAGON)
end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.me1filter1, tp, LOCATION_MZONE, 0, 1,
                                     nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.me1filter1, tp, LOCATION_MZONE, 0, 1, 1, nil, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    local pg = aux.GetMustBeMaterialGroup(tp, Group.FromCards(tc), tp, nil, nil,
                                          REASON_XYZ)
    if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or
        tc:IsControler(1 - tp) or tc:IsImmuneToEffect(e) or #pg > 1 or
        (#pg == 1 and not pg:IsContains(tc)) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.me1filter2, tp, LOCATION_EXTRA, 0,
                                      1, 1, nil, e, tp, tc, pg)
    local sc = g:GetFirst()
    if not sc then return end

    local mg = tc:GetOverlayGroup()
    if #mg ~= 0 then Duel.Overlay(sc, mg) end
    sc:SetMaterial(Group.FromCards(tc))
    Duel.Overlay(sc, Group.FromCards(tc))
    Duel.SpecialSummon(sc, SUMMON_TYPE_XYZ, tp, tp, false, false, POS_FACEUP)
    sc:CompleteProcedure()
end

function s.me3filter(c)
    if c:IsFacedown() or c:IsDisabled() or c:IsAttack(0) then return false end
    if not c:HasLevel() then return false end
    return (c:IsRace(RACE_DRAGON) and c:IsAttackAbove(2500)) or
               c:IsType(TYPE_PENDULUM)
end

function s.me3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        if (not c:IsLocation(LOCATION_EXTRA) and
            Duel.GetLocationCount(tp, LOCATION_MZONE) == 0) or
            (c:IsLocation(LOCATION_EXTRA) and
                Duel.GetLocationCountFromEx(tp, tp, nil, c) == 0) then
            return false
        end

        return
            Duel.IsExistingTarget(s.me3filter, tp, LOCATION_MZONE, 0, 1, nil) and
                c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.me3filter, tp, LOCATION_MZONE, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.me3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or
        tc:IsAttack(0) or tc:IsDisabled() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
    ec1:SetValue(0)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE)
    tc:RegisterEffect(ec1b)
    local ec1c = ec1:Clone()
    ec1c:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(ec1c)

    if tc:IsImmuneToEffect(ec1) or tc:IsImmuneToEffect(ec1b) or
        tc:IsImmuneToEffect(ec1c) or not c:IsRelateToEffect(e) then return end
    Duel.AdjustInstantly(tc)

    if (not c:IsLocation(LOCATION_EXTRA) and
        Duel.GetLocationCount(tp, LOCATION_MZONE) == 0) or
        (c:IsLocation(LOCATION_EXTRA) and
            Duel.GetLocationCountFromEx(tp, tp, nil, c) == 0) then
        return false
    end

    if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) > 0 and
        c:HasLevel() then
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetCode(EFFECT_CHANGE_LEVEL)
        ec2:SetValue(c:GetLevel())
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
    end
end

function s.me4filter1(c, e, tp, mc)
    local mg = Group.FromCards(c, mc)
    return c:IsCanBeXyzMaterial() and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               Duel.IsExistingMatchingCard(s.me4filter2, tp, LOCATION_EXTRA, 0,
                                           1, nil, tp, mg)
end

function s.me4filter2(c, tp, mg)
    return Duel.GetLocationCountFromEx(tp, tp, mg, c) > 0 and
               c:IsXyzSummonable(nil, mg)
end

function s.me4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsPlayerCanSpecialSummonCount(tp, 2) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.me4filter1, tp, LOCATION_PZONE,
                                               0, 1, nil, e, tp, c)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, 0)
end

function s.me4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc = Duel.SelectMatchingCard(tp, s.me4filter1, tp, LOCATION_PZONE, 0,
                                       1, 1, nil, e, tp, c):GetFirst()
    if not Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
        return
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(ec1b)
    Duel.SpecialSummonComplete()

    if not c:IsRelateToEffect(e) then return end

    local mg = Group.FromCards(c, tc)
    local g = Duel.GetMatchingGroup(s.me4filter2, tp, LOCATION_EXTRA, 0, nil,
                                    tp, mg)
    if #g > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        Duel.XyzSummon(tp, g:Select(tp, 1, 1, nil):GetFirst(), nil, mg)
    end
end
