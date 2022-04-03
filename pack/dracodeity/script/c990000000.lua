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
    e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCondition(function(e)
        return e:GetHandler():GetSummonType() == SUMMON_TYPE_LINK
    end)
    c:RegisterEffect(e1)

    -- extra material
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_SET_AVAILABLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_EXTRA_MATERIAL)
    e2:SetTargetRange(1, 0)
    e2:SetValue(s.e2val)
    c:RegisterEffect(e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_FIELD)
    e2b:SetRange(LOCATION_MZONE)
    e2b:SetCode(EFFECT_ADD_RACE)
    e2b:SetTargetRange(0, LOCATION_MZONE)
    e2b:SetCondition(function(e)
        return Duel.GetFlagEffect(e:GetHandlerPlayer(), id) > 0
    end)
    e2b:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
    e2b:SetValue(RACE_DRAGON)
    c:RegisterEffect(e2b)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCountLimit(1, id)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
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

function s.e2val(chk, summon_type, e, ...)
    if chk == 0 then
        local tp, sc = ...
        if summon_type ~= SUMMON_TYPE_LINK or
            not (sc and sc:IsRace(RACE_HIGHDRAGON)) then
            return Group.CreateGroup()
        else
            Duel.RegisterFlagEffect(tp, id, 0, 0, 1)
            return Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE,
                                         nil)
        end
    elseif chk == 2 then
        Duel.ResetFlagEffect(e:GetHandlerPlayer(), id)
    end
end

function s.e3filter(c)
    return c:IsFaceup() and c:IsLinkMonster() and c:IsAbleToRemoveAsCost()
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_MZONE, 0, 1,
                                           nil)
    end

    local tc = Utility.SelectMatchingCard(HINTMSG_REMOVE, tp, s.e3filter, tp,
                                          LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
    if Duel.Remove(tc, POS_FACEUP, REASON_COST + REASON_TEMPORARY) ~= 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(aux.Stringid(id, 0))
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_PHASE + PHASE_END)
        ec1:SetLabelObject(tc)
        ec1:SetCountLimit(1)
        ec1:SetOperation(function(e)
            Duel.ReturnToField(e:GetLabelObject())
        end)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
    end
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and
        Duel.SpecialSummon(c, 0, tp, tp, true, false, POS_FACEUP) > 0 then
        c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                 PHASE_END, 0, 1)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(aux.Stringid(id, 1))
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec1:SetCode(EVENT_PHASE + PHASE_END)
        ec1:SetLabelObject(c)
        ec1:SetCountLimit(1)
        ec1:SetCondition(function(e)
            return e:GetLabelObject():GetFlagEffect(id) ~= 0
        end)
        ec1:SetOperation(function(e)
            Duel.SendtoGrave(e:GetLabelObject(), REASON_EFFECT)
        end)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
    end

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec2:SetCode(EFFECT_CHANGE_DAMAGE)
    ec2:SetTargetRange(0, 1)
    ec2:SetValue(0)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)
    local ec2b = ec2:Clone()
    ec2b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    Duel.RegisterEffect(ec2b, tp)
end
