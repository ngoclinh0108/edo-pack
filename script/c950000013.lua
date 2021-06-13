-- Clear Wing Magician
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTunerEx(
                             aux.FilterBoolFunctionEx(Card.IsType, TYPE_PENDULUM)),
                         1, 99)

    -- pendulum
    Pendulum.AddProcedure(c, false)
    Utility.PlaceToPZoneWhenDestroyed(c)

    -- synchro summon
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(1172)
    pe1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1)
    pe1:SetTarget(s.pe1tg)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- synchro level
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    me1:SetCode(EFFECT_SYNCHRO_LEVEL)
    me1:SetValue(function(e, sync)
        return 3 * 65536 + e:GetHandler():GetLevel()
    end)
    c:RegisterEffect(me1)
end

function s.pe1filter1(c, tp, mc)
    local mg = Group.FromCards(c, mc)
    return c:IsCanBeSynchroMaterial() and
               Duel.IsExistingMatchingCard(s.pe1filter2, tp, LOCATION_EXTRA, 0,
                                           1, nil, tp, mg) and
               c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end

function s.pe1filter2(c, tp, mg)
    return Duel.GetLocationCountFromEx(tp, tp, mg, c) > 0 and
               c:IsSynchroSummonable(nil, mg)
end

function s.pe1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsPlayerCanSpecialSummonCount(tp, 2) and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.pe1filter1, tp, LOCATION_MZONE,
                                               0, 1, nil, tp, c)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SMATERIAL)
    Duel.SelectTarget(tp, s.pe1filter1, tp, LOCATION_MZONE, 0, 1, 1, c, tp, c)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, 0)
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 or
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) == 0 then
        return
    end
    if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

    local mg = Group.FromCards(c, tc)
    local g = Duel.GetMatchingGroup(s.pe1filter2, tp, LOCATION_EXTRA, 0, nil,
                                    tp, mg)
    if #g > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        Duel.SynchroSummon(tp, g:Select(tp, 1, 1, nil):GetFirst(), nil, mg)
    end
end
