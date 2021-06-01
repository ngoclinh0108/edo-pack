-- Supreme King Dragon Venowurm
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

    -- summon dragon
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 0))
    pe2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    pe2:SetType(EFFECT_TYPE_IGNITION)
    pe2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    pe2:SetCountLimit(1, id + 1 * 1000000)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCondition(s.pe2con)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- fusion summon (pendulum zone)
    local pe3params = {aux.FilterBoolFunction(Card.IsRace, RACE_DRAGON)}
    local pe3 = Effect.CreateEffect(c)
    pe3:SetDescription(1170)
    pe3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    pe3:SetType(EFFECT_TYPE_IGNITION)
    pe3:SetRange(LOCATION_PZONE)
    pe3:SetCountLimit(1)
    pe3:SetTarget(Fusion.SummonEffTG(table.unpack(pe3params)))
    pe3:SetOperation(Fusion.SummonEffOP(table.unpack(pe3params)))
    c:RegisterEffect(pe3)

    -- fusion substitute
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetCode(EFFECT_FUSION_SUBSTITUTE)
    me1:SetCondition(function(e)
        return e:GetHandler():IsLocation(
                   LOCATION_HAND + LOCATION_ONFIELD + LOCATION_GRAVE)
    end)
    c:RegisterEffect(me1)

    -- fusion limit
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_SINGLE)
    me2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    me2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
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

    -- fusion summon (monster zone)
    local me4params = {
        nil, Fusion.CheckWithHandler(Fusion.OnFieldMat), function(e, tp, mg)
            return Duel.GetMatchingGroup(Card.IsAbleToGrave, tp, LOCATION_PZONE,
                                         0, nil)
        end, nil, Fusion.ForcedHandler
    }
    local me4 = Effect.CreateEffect(c)
    me4:SetDescription(1170)
    me4:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    me4:SetType(EFFECT_TYPE_IGNITION)
    me4:SetRange(LOCATION_MZONE)
    me4:SetCountLimit(1)
    me4:SetTarget(Fusion.SummonEffTG(table.unpack(me4params)))
    me4:SetOperation(Fusion.SummonEffOP(table.unpack(me4params)))
    c:RegisterEffect(me4)
end

function s.pe1con(e)
    return not Duel.IsExistingMatchingCard(function(c)
        return c:IsCode(13331639) or c:IsSetCard(0x98) or c:IsSetCard(0x99) or
                   c:IsSetCard(0x10f8) or c:IsSetCard(0x20f8)
    end, e:GetHandlerPlayer(), LOCATION_PZONE, 0, 1, e:GetHandler())
end

function s.pe2filter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and
               c:IsRace(RACE_DRAGON) and c:IsType(TYPE_FUSION)
end

function s.pe2con(e)
    return Duel.IsExistingMatchingCard(function(c)
        return c:IsFaceup() and c:IsCode(13331639)
    end, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingTarget(s.pe2filter, tp, LOCATION_GRAVE, 0, 1,
                                         nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    Duel.SelectTarget(tp, s.pe2filter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, tp, LOCATION_GRAVE)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) then
        return
    end

    Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP)
end

function s.me3filter(c)
    if c:IsFacedown() or c:IsDisabled() or c:IsAttack(0) then return false end
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

    if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) > 0 then
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        ec2:SetValue(ATTRIBUTE_DARK)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
    end
end
