-- Spacian HERO Neos
local s, id = GetID()
Duel.LoadScript("util.lua")

s.listed_names = {CARD_NEOS}
s.listed_series = {0x8}

function s.initial_effect(c)
    -- summon with 1 tribute
    local e1 = aux.AddNormalSummonProcedure(c, true, true, 1, 1,
                                            SUMMON_TYPE_TRIBUTE,
                                            aux.Stringid(id, 0), s.e1filter)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
    e2:SetCountLimit(id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_LEAVE_FIELD)
    c:RegisterEffect(e2b)
end

function s.e1filter(c, tp)
    return (c:IsControler(tp) or c:IsFaceup()) and
               (c:IsSetCard(0x8) or c:IsSetCard(0x9))
end

function s.e2filter(c, tp)
    return
        c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and
            c:IsPreviousPosition(POS_FACEUP) and c:IsType(TYPE_FUSION) and
            aux.IsMaterialListCode(c, CARD_NEOS)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e2filter, 1, nil, tp) and
               (r & REASON_BATTLE + REASON_EFFECT) ~= 0
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, tp, c:GetLocation())
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP)
end
