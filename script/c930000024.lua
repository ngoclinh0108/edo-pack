-- Idun the Nordic Young
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_DAMAGE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    aux.GlobalCheck(s, function()
        s[0] = 0
        s[1] = 0
        local e1dmgreg = Effect.CreateEffect(c)
        e1dmgreg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e1dmgreg:SetCode(EVENT_DAMAGE)
        e1dmgreg:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            s[ep] = s[ep] + ev
        end)
        Duel.RegisterEffect(e1dmgreg, 0)
        local e1dmgclear = Effect.CreateEffect(c)
        e1dmgclear:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e1dmgclear:SetCode(EVENT_ADJUST)
        e1dmgclear:SetCountLimit(1)
        e1dmgclear:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            s[0] = 0
            s[1] = 0
        end)
        Duel.RegisterEffect(e1dmgclear, 0)
    end)
end

function s.e1filter(c) return not c:IsStatus(STATUS_LEAVE_CONFIRMED) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return ep == tp and tp ~= rp and
               not Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE,
                                               0, 1, nil)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, s[tp])
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rec = Duel.Recover(tp, s[tp], REASON_EFFECT)

    if c:IsRelateToEffect(e) then
        if Duel.SpecialSummonStep(c, 0, tp, tp, true, false, POS_FACEUP_DEFENSE) then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_SET_BASE_DEFENSE)
            ec1:SetValue(rec)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            c:RegisterEffect(ec1, true)
        end
        Duel.SpecialSummonComplete()
    end
end
