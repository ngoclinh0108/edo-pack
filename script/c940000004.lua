-- Number C37: Hope Invented Dragon Abyss Shark
Duel.LoadScript("util.lua")
local s, id = GetID()

s.xyz_number = 37
s.listed_names = {37279508}
s.listed_series = {0x95}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se)
        local loc = e:GetHandler():GetLocation()
        if loc ~= LOCATION_EXTRA then return true end
        return se:GetHandler():IsSetCard(0x95) and
                   se:GetHandler():IsType(TYPE_SPELL)
    end)
    c:RegisterEffect(splimit)

    -- attach
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_BATTLED)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon
    local e2desreg = Effect.CreateEffect(c)
    e2desreg:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2desreg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2desreg:SetCode(EVENT_TO_GRAVE)
    e2desreg:SetOperation(s.e2desregop)
    c:RegisterEffect(e2desreg)
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE + PHASE_END)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id) ~= 0 end)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    aux.GlobalCheck(s, function()
        local e2globalreg = Effect.CreateEffect(c)
        e2globalreg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e2globalreg:SetCode(EVENT_TO_GRAVE)
        e2globalreg:SetOperation(s.e2globalregop)
        Duel.RegisterEffect(e2globalreg, 0)
    end)

    -- extra attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
    e3:SetCondition(s.effcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)

    -- atk down
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetHintTiming(TIMING_DAMAGE_STEP,
                     TIMING_DAMAGE_STEP + TIMINGS_CHECK_MONSTER)
    e4:SetCountLimit(1)
    e4:SetCondition(s.effcon)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4, false, REGISTER_FLAG_DETACH_XMAT)
end

s.rum_limit = function(c, e) return c:IsCode(37279508) end
s.rum_xyzsummon = function(c)
    local filter = aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_WATER)
    local xyz = Effect.CreateEffect(c)
    xyz:SetDescription(1073)
    xyz:SetType(EFFECT_TYPE_FIELD)
    xyz:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    xyz:SetCode(EFFECT_SPSUMMON_PROC)
    xyz:SetRange(c:GetLocation())
    xyz:SetCondition(Xyz.Condition(filter, 5, 3, 3, false))
    xyz:SetTarget(Xyz.Target(filter, 5, 3, 3, false))
    xyz:SetOperation(Xyz.Operation(filter, 5, 3, 3, false))
    xyz:SetValue(SUMMON_TYPE_XYZ)
    xyz:SetReset(RESET_CHAIN)
    c:RegisterEffect(xyz)
    return xyz
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    return not c:IsStatus(STATUS_BATTLE_DESTROYED) and bc and
               bc:IsStatus(STATUS_BATTLE_DESTROYED)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if not bc:IsRelateToBattle() or c:IsFacedown() or not c:IsRelateToEffect(e) then
        return
    end

    Duel.Overlay(c, Group.FromCards(bc))
end

function s.e2filter1(c, e, tp)
    return not c:IsCode(id) and c:GetFlagEffect(id) ~= 0 and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2filter2(c)
    return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_WATER)
end

function s.e2desregop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE + REASON_EFFECT) then
        c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                 PHASE_END, 0, 1)
    end
end

function s.e2globalregop(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(function(c) return not c:IsCode(id) end, nil)
    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                  PHASE_END, 0, 0)
    end
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_GRAVE,
                                               0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local tg = Duel.GetMatchingGroup(s.e2filter1, tp, LOCATION_GRAVE, 0, nil, e,
                                     tp)
    if ft <= 0 or #tg == 0 then return end

    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then ft = 1 end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    tg = tg:Select(tp, ft, ft, nil)
    Duel.SpecialSummon(tg, 0, tp, tp, false, false, POS_FACEUP)

    local sg = Duel.GetOperatedGroup():Filter(s.e2filter2, nil)
    if #sg == 0 or not Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then return end
    if #sg > 1 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
        sg = sg:Select(tp, 1, 1, nil)
    end
    Duel.Overlay(sg:GetFirst(), Group.FromCards(c))
end

function s.effcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetOverlayGroup():IsExists(function(c)
        return c:IsRace(RACE_SEASERPENT) and c:IsType(TYPE_XYZ)
    end, 1, nil)
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST)
    end
    e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, 0, LOCATION_MZONE,
                                           1, nil)
    end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    for tc in aux.Next(g) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        ec1:SetValue(math.ceil(tc:GetAttack() / 2))
        tc:RegisterEffect(ec1)
    end
end
