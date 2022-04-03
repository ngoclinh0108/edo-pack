-- Goshenite of Dracodeity
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetUniqueOnField(1, 0, id)

    -- link summon
    Link.AddProcedure(c, nil, 3, 3)

    -- summon cannot be negated
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e1:SetCondition(function(e)
        return e:GetHandler():GetSummonType() == SUMMON_TYPE_LINK
    end)
    c:RegisterEffect(e1)

    -- link limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    e2:SetValue(function(e, c)
        if not c then return false end
        return not c:IsRace(RACE_HIGHDRAGON)
    end)
    c:RegisterEffect(e2)

    -- extra material
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_EXTRA_MATERIAL)
    e3:SetTargetRange(0, 1)
    e3:SetOperation(s.e3con)
    e3:SetValue(s.e3val)
    local e3grant = Effect.CreateEffect(c)
    e3grant:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
    e3grant:SetRange(LOCATION_MZONE)
    e3grant:SetTargetRange(0, LOCATION_MZONE)
    e3grant:SetTarget(s.e3tg)
    e3grant:SetLabelObject(e3)
    c:RegisterEffect(e3grant)
    local e3b = Effect.CreateEffect(c)
    e3b:SetType(EFFECT_TYPE_FIELD)
    e3b:SetRange(LOCATION_MZONE)
    e3b:SetCode(EFFECT_ADD_RACE)
    e3b:SetTargetRange(0, LOCATION_MZONE)
    e3b:SetTarget(function(e, c)
        return c:IsFaceup() and c:GetFlagEffect(id) > 0
    end)
    e3b:SetValue(RACE_DRAGON)
    c:RegisterEffect(e3b)
    aux.GlobalCheck(s, function() s.flagmap = {} end)

    -- banish & special summon
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_REMOVE + CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetCountLimit(1, id)
    e4:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
    e4:SetCondition(aux.exccon)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
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

function s.e3filter(c) return c:GetFlagEffect(id) > 0 end

function s.e3tg(e, c) return c:IsFaceup() and c:IsCanBeLinkMaterial() end

function s.e3con(c, e, tp, sg, mg, sc, og, chk)
    return (sg + mg):IsExists(Card.IsCode, 1, og, id) and
               sg:FilterCount(s.e3filter, nil) < 3
end

function s.e3val(chk, summon_type, e, ...)
    local c = e:GetHandler()
    if chk == 0 then
        local tp, sc = ...
        if summon_type ~= SUMMON_TYPE_LINK or not sc:IsRace(RACE_HIGHDRAGON) or
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

function s.e4filter(c)
    return c:IsFaceup() and c:IsLinkMonster() and c:IsAbleToRemove()
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and
                   Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_MZONE,
                                               0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 0, LOCATION_MZONE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

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

    local tc = Utility.SelectMatchingCard(HINTMSG_REMOVE, tp, s.e4filter, tp,
                                          LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
    if tc and Duel.Remove(tc, POS_FACEUP, REASON_EFFECT + REASON_TEMPORARY) ~= 0 then
        local ec2 = Effect.CreateEffect(c)
        ec2:SetDescription(aux.Stringid(id, 1))
        ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec2:SetCode(EVENT_PHASE + PHASE_END)
        ec2:SetLabelObject(tc)
        ec2:SetCountLimit(1)
        ec2:SetOperation(function(e)
            Duel.ReturnToField(e:GetLabelObject())
        end)
        ec2:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec2, tp)

        if c:IsRelateToEffect(e) and
            Duel.SpecialSummon(c, 0, tp, tp, true, false, POS_FACEUP) > 0 then

            c:RegisterFlagEffect(id + 100, RESET_EVENT + RESETS_STANDARD +
                                     RESET_PHASE + PHASE_END, 0, 1)
            local ec3 = Effect.CreateEffect(c)
            ec3:SetDescription(aux.Stringid(id, 2))
            ec3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            ec3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
            ec3:SetCode(EVENT_PHASE + PHASE_END)
            ec3:SetLabelObject(c)
            ec3:SetCountLimit(1)
            ec3:SetCondition(function(e)
                return e:GetLabelObject():GetFlagEffect(id + 100) ~= 0
            end)
            ec3:SetOperation(function(e)
                Duel.SendtoGrave(e:GetLabelObject(), REASON_EFFECT)
            end)
            ec3:SetReset(RESET_PHASE + PHASE_END)
            Duel.RegisterEffect(ec3, tp)
        end
    end
end
