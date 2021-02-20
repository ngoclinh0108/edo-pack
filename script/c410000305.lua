-- Red-Eyes Armored Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x3b}
s.listed_series = {0x3b}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, s.lnkfilter, 2, 2, s.lnkcheck)

    -- destroy replace
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_DESTROY_REPLACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- pierce
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_PIERCE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetTarget(function(e, c) return c:IsSetCard(0x3b) end)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.lnkfilter(c) return c:IsAttribute(ATTRIBUTE_DARK) end

function s.lnkcheck(g, lnkc)
    return g:IsExists(function(c)
        return c:IsLevelAbove(5) and c:IsSetCard(0x3b)
    end, 1, nil)
end

function s.e1filter(c, e)
    return c:IsFaceup() and c:IsDestructable(e) and
               not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return not c:IsReason(REASON_REPLACE) and
                   Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_ONFIELD,
                                               0, 1, c, e)
    end

    if Duel.SelectEffectYesNo(tp, c, 96) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESREPLACE)
        local tc = Duel.SelectMatchingCard(tp, s.e1filter, tp, LOCATION_ONFIELD,
                                           0, 1, 1, c, e):GetFirst()
        e:SetLabelObject(tc)
        tc:SetStatus(STATUS_DESTROY_CONFIRMED, true)
        return true
    else
        return false
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    tc:SetStatus(STATUS_DESTROY_CONFIRMED, false)
    Duel.Destroy(tc, REASON_EFFECT + REASON_REPLACE)
end

function s.e3filter(c, e, tp)
    if c:IsCode(id) or not c:IsCanBeSpecialSummoned(e, 0, tp, false, false) then
        return false
    end

    return c:IsSetCard(0x3b) or c:IsRace(RACE_DRAGON)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetAttackAnnouncedCount() == 0 end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_OATH +
                        EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e3filter, tp,
                                               LOCATION_HAND + LOCATION_GRAVE,
                                               0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_HAND + LOCATION_GRAVE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e3filter), tp,
                                      LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1,
                                      nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end
