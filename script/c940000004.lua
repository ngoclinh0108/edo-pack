-- Number C37: Hope Invented Dragon Abyss Shark
Duel.LoadScript("util.lua")
local s, id = GetID()

s.xyz_number = 37

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute,
                                                 ATTRIBUTE_WATER), 5, 3,
                     s.xyzovfilter, aux.Stringid(id, 0))

    -- chain attack
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_BATTLE_DESTROYING)
    e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return aux.bdocon(e, tp, eg, ep, ev, re, r, rp) and
                   e:GetHandler():CanChainAttack()
    end)
    e1:SetOperation(
        function(e, tp, eg, ep, ev, re, r, rp) Duel.ChainAttack() end)
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

    -- atk down
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetHintTiming(TIMING_DAMAGE_STEP,
                     TIMING_DAMAGE_STEP + TIMINGS_CHECK_MONSTER)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3, false, REGISTER_FLAG_DETACH_XMAT)
end

function s.xyzovfilter(c, tp, xyzc)
    return c:IsFaceup() and c:GetRank() == 4 and
               c:IsAttribute(ATTRIBUTE_WATER, xyzc, SUMMON_TYPE_XYZ, tp)
end

function s.e2filter(c, e, tp)
    return not c:IsCode(id) and c:GetFlagEffect(id) ~= 0 and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
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
                   Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_GRAVE,
                                               0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local g = Duel.GetMatchingGroup(s.e2filter, tp, LOCATION_GRAVE, 0, nil, e,
                                    tp)
    if ft <= 0 or #g == 0 then return end

    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then ft = 1 end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sg = g:Select(tp, ft, ft, nil)

    Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetOverlayGroup():IsExists(function(c)
        return c:IsRace(RACE_SEASERPENT) and c:IsType(TYPE_XYZ)
    end, 1, nil)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST)
    end
    e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, 0, LOCATION_MZONE,
                                           1, nil)
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
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
