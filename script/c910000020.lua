-- The Palladium Oracles
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material = {71703785, 42006475}
s.material_setcode = {0x13a}
s.listed_names = {71703785, 42006475}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, false, false, {71703785, 42006475},
                      aux.FilterBoolFunctionEx(Card.IsRace, RACE_SPELLCASTER))

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return not e:GetHandler():IsLocation(LOCATION_EXTRA) or
                   aux.fuslimit(e, se, sp, st)
    end)
    c:RegisterEffect(splimit)

    -- indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- draw
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(1108)
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetType(EFFECT_TYPE_QUICK_O)
    e2b:SetCode(EVENT_CHAINING)
    e2b:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e2b:SetCondition(s.e2con)
    c:RegisterEffect(e2b)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.contactfilter(tp)
    return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost, tp, LOCATION_MZONE,
                                 0, nil)
end

function s.contactop(g) Duel.SendtoGrave(g, REASON_COST + REASON_MATERIAL) end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    if Duel.Draw(p, d, REASON_EFFECT) == 0 then return end
    local tc = Duel.GetOperatedGroup():GetFirst()
    if not tc:IsType(TYPE_SPELL + TYPE_TRAP) then return end

    local b1 = Utility.CheckActivateEffect(tc, e, tp, false, true, false)
    local b2 = tc:IsSSetable() and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0

    local opt = {}
    local sel = {}
    table.insert(opt, 666000)
    table.insert(sel, 1)
    if b1 then
        table.insert(opt, 1150)
        table.insert(sel, 2)
    end
    if b2 then
        table.insert(opt, 1153)
        table.insert(sel, 3)
    end
    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]

    if op == 2 then
        Utility.HintCard(tc)
        Duel.SendtoGrave(tc, REASON_RULE)
        Utility.ApplyActivateEffect(tc, e, tp, false, true, false)
    elseif op == 3 then
        Duel.SSet(tp, tc, tp, false)

        if tc:IsType(TYPE_QUICKPLAY + TYPE_TRAP) then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
            if tc:IsType(TYPE_QUICKPLAY) then
                ec1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
            elseif tc:IsType(TYPE_TRAP) then
                ec1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
            end
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec1)
        end
    end
end

function s.e3filter(c, e, tp, code)
    return c:IsCode(code) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToExtraAsCost() end
    Duel.SendtoDeck(e:GetHandler(), nil, 2, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    if chk == 0 then
        return not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) >= 2 and
                   Duel.IsExistingMatchingCard(s.e3filter, tp, loc, 0, 1, nil,
                                               e, tp, 71703785) and
                   Duel.IsExistingMatchingCard(s.e3filter, tp, loc, 0, 1, nil,
                                               e, tp, 42006475)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, loc)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) or
        Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 then return end

    local g1 = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e3filter), tp, loc,
                                     0, nil, e, tp, 71703785)
    local g2 = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e3filter), tp, loc,
                                     0, nil, e, tp, 42006475)
    if #g1 == 0 or #g2 == 0 then return end

    g1 = Utility.GroupSelect(g1, tp, 1, 1, nil)
    g2 = Utility.GroupSelect(g2, tp, 1, 1, nil)
    Duel.SpecialSummon(g1:Merge(g2), 0, tp, tp, true, false, POS_FACEUP)
end
