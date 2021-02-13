-- The Palladium Oracles
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x13a}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, s.lnkfilter, 2, 2, s.lnkcheck)

    -- attribute
    local attribute = Effect.CreateEffect(c)
    attribute:SetType(EFFECT_TYPE_SINGLE)
    attribute:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    attribute:SetCode(EFFECT_ADD_ATTRIBUTE)
    attribute:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(attribute)

    -- gain effect
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- draw
    local e2reg = Effect.CreateEffect(c)
    e2reg:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    e2reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2reg:SetCode(EVENT_CHAINING)
    e2reg:SetRange(LOCATION_MZONE)
    e2reg:SetOperation(aux.chainreg)
    c:RegisterEffect(e2reg)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_CHAIN_SOLVING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.lnkfilter(c)
    return (c:IsLevelAbove(6) or c:IsRankAbove(6)) and
               c:IsRace(RACE_SPELLCASTER)
end

function s.lnkcheck(g, lnkc) return g:IsExists(Card.IsSetCard, 1, nil, 0x13a) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetMaterial()
    for tc in aux.Next(g) do
        c:CopyEffect(tc:GetOriginalCode(), RESET_EVENT + RESETS_STANDARD, 1)
    end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return re:IsActiveType(TYPE_SPELL + TYPE_TRAP) and c:GetFlagEffect(1) > 0
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
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
    local b1 = tc:IsType(TYPE_MONSTER) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   tc:IsCanBeSpecialSummoned(e, tp, tp, false, false)
    local b2 = tc:IsType(TYPE_SPELL + TYPE_TRAP) and tc:IsSSetable()

    if b1 and Duel.SelectYesNo(tp, 5) then
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    elseif b2 and Duel.SelectYesNo(tp, 1153) then
        Duel.SSet(tp, tc, tp, false)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        if tc:IsType(TYPE_QUICKPLAY) then
            ec1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
        elseif tc:IsType(TYPE_TRAP) then
            ec1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
        end
        ec1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
    end
end

function s.e3filter(c, e, tp)
    return c:IsControler(tp) and
               c:IsLocation(LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and
               c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local mg = c:GetMaterial():Filter(s.e3filter, nil, e, tp)
    local ct = #mg

    if chk == 0 then
        if ct > 1 and Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then
            return false
        end

        return ct > 0 and ct <= Duel.GetLocationCount(tp, LOCATION_MZONE) and
                   (c:GetSummonType() & SUMMON_TYPE_LINK) == SUMMON_TYPE_LINK
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, ct, tp,
                          LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local mg = c:GetMaterial():Filter(s.e3filter, nil, e, tp)
    local ct = #mg

    if Duel.GetLocationCount(tp, LOCATION_MZONE) < ct or
        (ct > 1 and Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT)) then
        return
    end

    if Duel.SpecialSummon(mg, 0, tp, tp, true, false, POS_FACEUP) ~= 0 then
        Duel.SendtoDeck(c, tp, 2, REASON_EFFECT)
    end
end
