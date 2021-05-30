-- Supreme King Dragon Venowurm
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x10f8, 0x20f8}

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

    -- special summon back your destroyed monster
    local pe2 = Effect.CreateEffect(c)
    pe2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    pe2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    pe2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    pe2:SetCode(EVENT_TO_GRAVE)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1, id)
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

    -- fusion summon (monster zone)
    local me3params = {
        nil, Fusion.CheckWithHandler(Fusion.OnFieldMat), function(e, tp, mg)
            return Duel.GetMatchingGroup(Card.IsAbleToGrave, tp, LOCATION_PZONE,
                                         0, nil)
        end, nil, Fusion.ForcedHandler
    }
    local me3 = Effect.CreateEffect(c)
    me3:SetDescription(1170)
    me3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    me3:SetType(EFFECT_TYPE_IGNITION)
    me3:SetRange(LOCATION_MZONE)
    me3:SetCountLimit(1)
    me3:SetTarget(Fusion.SummonEffTG(table.unpack(me3params)))
    me3:SetOperation(Fusion.SummonEffOP(table.unpack(me3params)))
    c:RegisterEffect(me3)
end

function s.pe1con(e)
    return not Duel.IsExistingMatchingCard(function(c)
        return c:IsSetCard(0x98) or c:IsSetCard(0x10f8) or c:IsSetCard(0x20f8)
    end, e:GetHandlerPlayer(), LOCATION_PZONE, 0, 1, e:GetHandler())
end

function s.pe2filter(c, e, tp)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_FUSION) and
               c:GetPreviousControler() == tp and c:IsReason(REASON_DESTROY) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.pe2con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.pe2filter, 1, nil, e, tp)
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = eg:Filter(s.pe2filter, nil, e, tp)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_MZONE) <=
        0 then return end

    local tc
    local g = eg:Filter(s.pe2filter, nil, e, tp)
    if #g > 1 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        tc = g:Select(tp, 1, 1, nil):GetFirst()
    else
        tc = g:GetFirst()
    end

    if Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3001)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetValue(1)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)
    end
end
