-- Goshenite of Dracodeity
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.NOT(
        aux.FilterBoolFunctionEx(Card.IsType, TYPE_TOKEN)), 3,
        3)

    -- summon cannot be negated
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e1:SetCondition(function(e)
        return e:GetHandler():GetSummonType() == SUMMON_TYPE_LINK
    end)
    c:RegisterEffect(e1)

    -- attribute
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- link summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(1174)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- extra material
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_EXTRA_MATERIAL)
    e4:SetTargetRange(0, 1)
    e4:SetOperation(s.e4con)
    e4:SetValue(s.e4val)
    local e4grant = Effect.CreateEffect(c)
    e4grant:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
    e4grant:SetRange(LOCATION_MZONE)
    e4grant:SetTargetRange(0, LOCATION_MZONE)
    e4grant:SetTarget(s.e4tg)
    e4grant:SetLabelObject(e4)
    c:RegisterEffect(e4grant)
    local e4b = Effect.CreateEffect(c)
    e4b:SetType(EFFECT_TYPE_FIELD)
    e4b:SetRange(LOCATION_MZONE)
    e4b:SetCode(EFFECT_ADD_RACE)
    e4b:SetTargetRange(0, LOCATION_MZONE)
    e4b:SetTarget(function(e, c)
        return c:IsFaceup() and c:GetFlagEffect(id) > 0
    end)
    e4b:SetValue(RACE_DRAGON)
    c:RegisterEffect(e4b)
    aux.GlobalCheck(s, function() s.flagmap = {} end)

    -- banish & special summon
    local e5 = Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_REMOVE + CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetRange(LOCATION_GRAVE)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetHintTiming(0, TIMING_MAIN_END)
    e5:SetCountLimit(1, id)
    e5:SetCondition(s.e5con)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.deck_edit(tp)
    Utility.DeckEditAddCardToDeck(tp, 990000001)
    Utility.DeckEditAddCardToDeck(tp, 990000002)
    Utility.DeckEditAddCardToDeck(tp, 990000003)
    Utility.DeckEditAddCardToDeck(tp, 990000004)
    Utility.DeckEditAddCardToDeck(tp, 990000005)
    Utility.DeckEditAddCardToDeck(tp, 990000006)
    Utility.DeckEditAddCardToDeck(tp, 990000007)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local att = c:AnnounceAnotherAttribute(tp)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    ec1:SetValue(att)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
    c:RegisterEffect(ec1)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == 1 - tp and Duel.IsMainPhase()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsLinkSummonable, tp, LOCATION_EXTRA, 0, 1, nil, c) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsControler(1 - tp) then return end

    local g = Duel.GetMatchingGroup(Card.IsLinkSummonable, tp, LOCATION_EXTRA, 0, nil, c)
    if #g > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sg = g:Select(tp, 1, 1, nil)
        Duel.LinkSummon(tp, sg:GetFirst(), c)
    end
end

function s.e4filter(c) return c:GetFlagEffect(id) > 0 end

function s.e4tg(e, c)
    return c:IsFaceup() and c:IsCanBeLinkMaterial()
        and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end

function s.e4con(c, e, tp, sg, mg, sc, og, chk)
    return (sg + mg):IsExists(Card.IsCode, 1, og, id) and
        sg:FilterCount(s.e4filter, nil) < 3
end

function s.e4val(chk, summon_type, e, ...)
    local c = e:GetHandler()
    if chk == 0 then
        local tp, sc = ...
        if summon_type ~= SUMMON_TYPE_LINK or not sc:IsRace(RACE_DIVINE) or
            Duel.GetFlagEffect(tp, id) > 0 then
            return Group.CreateGroup()
        else
            s.flagmap[c] = c:RegisterFlagEffect(id, 0, 0, 1)
            return Group.FromCards(c)
        end
    elseif chk == 1 then
        local sg, sc, tp = ...
        if summon_type & SUMMON_TYPE_LINK == SUMMON_TYPE_LINK and #sg > 0 and
            Duel.GetFlagEffect(tp, id) == 0 then
            Duel.Hint(HINT_CARD, tp, id)
            Duel.RegisterFlagEffect(tp, id, RESET_PHASE + PHASE_END, 0, 1)
        end
    elseif chk == 2 then
        if s.flagmap[c] then
            s.flagmap[c]:Reset()
            s.flagmap[c] = nil
        end
    end
end

function s.e5filter(c)
    return c:IsLinkAbove(5) and c:IsAbleToRemove()
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp)
    return aux.exccon(e, tp, eg, ep, ev, re, r, rp) and not Duel.IsBattlePhase()
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingTarget(s.e5filter, tp, LOCATION_MZONE, 0, 1, nil)
            and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectTarget(tp, s.e5filter, tp, LOCATION_MZONE, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()

    aux.RegisterClientHint(c, EFFECT_FLAG_OATH, 1 - tp, 1, 0,
        aux.Stringid(id, 0), nil)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_CHANGE_DAMAGE)
    ec1:SetTargetRange(0, 1)
    ec1:SetValue(0)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    Duel.RegisterEffect(ec1b, tp)

    if tc:IsRelateToEffect(e) and Duel.Remove(tc, POS_FACEUP, REASON_COST + REASON_TEMPORARY) ~= 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_PHASE + PHASE_END)
        ec1:SetLabelObject(tc)
        ec1:SetCountLimit(1)
        ec1:SetOperation(function(e) Duel.ReturnToField(e:GetLabelObject()) end)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)

        if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
            Duel.SpecialSummon(c, 0, tp, tp, true, false, POS_FACEUP)
        end
    end
end
