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

    -- synchro limit
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    me1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    me1:SetValue(function(e, c)
        if not c then return false end
        return not c:IsRace(RACE_DRAGON)
    end)
    c:RegisterEffect(me1)

    -- xyz summon
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(1173)
    me2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me2:SetType(EFFECT_TYPE_IGNITION)
    me2:SetRange(LOCATION_MZONE)
    me2:SetCountLimit(1)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)
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

function s.me2filter1(c, e, tp, mc)
    local mg = Group.FromCards(c, mc)
    return c:IsCanBeXyzMaterial() and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               Duel.IsExistingMatchingCard(s.me2filter2, tp, LOCATION_EXTRA, 0,
                                           1, nil, tp, mg)
end

function s.me2filter2(c, tp, mg)
    return Duel.GetLocationCountFromEx(tp, tp, mg, c) > 0 and
               c:IsXyzSummonable(nil, mg)
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsPlayerCanSpecialSummonCount(tp, 2) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.me2filter1, tp, LOCATION_PZONE,
                                               0, 1, nil, e, tp, c)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, 0)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc = Duel.SelectMatchingCard(tp, s.me2filter1, tp, LOCATION_PZONE, 0,
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
    local g = Duel.GetMatchingGroup(s.me2filter2, tp, LOCATION_EXTRA, 0, nil,
                                    tp, mg)
    if #g > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        Duel.XyzSummon(tp, g:Select(tp, 1, 1, nil):GetFirst(), nil, mg)
    end
end
