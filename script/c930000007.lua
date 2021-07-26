-- Hela the Nordic Death
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")
local s, id = GetID()

s.listed_series = {0x42}
s.material_setcode = {0x42}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMixN(c, true, true, s.fusfilter, 2)
    Fusion.AddContactProc(c, s.contactfilter, s.contactop, function(e)
        return not e:GetHandler():IsLocation(LOCATION_EXTRA)
    end)

    -- special summon (self)
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PHASE + PHASE_STANDBY)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon (effect gain)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    local e2grant = Effect.CreateEffect(c)
    e2grant:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
    e2grant:SetRange(LOCATION_MZONE)
    e2grant:SetTargetRange(LOCATION_GRAVE, 0)
    e2grant:SetTarget(s.e2granttg)
    e2grant:SetLabelObject(e2)
    c:RegisterEffect(e2grant)
end

function s.fusfilter(c, fc, sumtype, tp, sub, mg, sg)
    return (not sg or
               not sg:IsExists(Card.IsRace, 1, c, c:GetRace(), fc, sumtype, tp)) and
               c:IsSetCard(0x42, fc, sumtype, tp)
end

function s.contactfilter(tp)
    return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost, tp, LOCATION_ONFIELD,
                                 0, nil)
end

function s.contactop(g) Duel.SendtoGrave(g, REASON_COST + REASON_MATERIAL) end

function s.e1filter(c) return not c:IsCode(id) and c:IsFaceup() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
                   Duel.IsExistingTarget(s.e1filter, tp, LOCATION_MZONE, 0, 1,
                                         nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g =
        Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) then
        return
    end

    if Duel.Destroy(tc, REASON_EFFECT) > 0 then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
    end
end

function s.e2con(e, c)
    if c == nil then return true end
    local eff = {c:GetCardEffect(EFFECT_NECRO_VALLEY)}
    for _, te in ipairs(eff) do
        local op = te:GetOperation()
        if not op or op(e, c) then return false end
    end
    return true
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp, c)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD)
    c:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    c:RegisterEffect(ec1b)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetDescription(3302)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_CLIENT_HINT + EFFECT_FLAG_CANNOT_DISABLE)
    ec2:SetCode(EFFECT_CANNOT_TRIGGER)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD)
    c:RegisterEffect(ec2)
end

function s.e2granttg(e, c) return c:IsSetCard(0x42) and c:IsLevelBelow(10) end
