-- Frey of the Nordic Champions
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x5042, 0x42}

function s.initial_effect(c)
    -- summon without tribute
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- cannot disable summon
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    c:RegisterEffect(e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_FIELD)
    e2b:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e2b:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    e2b:SetRange(LOCATION_MZONE)
    e2b:SetTargetRange(1, 0)
    e2b:SetTarget(function(e, c) return c:IsSetCard(0x42) end)
    c:RegisterEffect(e2b)

    -- act limit
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op1)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3b)
    local e3c = Effect.CreateEffect(c)
    e3c:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3c:SetRange(LOCATION_MZONE)
    e3c:SetCode(EVENT_CHAIN_END)
    e3c:SetOperation(s.e3op2)
    c:RegisterEffect(e3c)

    -- search
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_SUMMON_SUCCESS)
    e4:SetCountLimit(1, id)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e4b)
    local e4c = e4:Clone()
    e4c:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4c)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0 and
               Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
end

function s.e3filter(c, tp) return c:IsSummonPlayer(tp) and c:IsSetCard(0x42) end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e3filter, 1, nil, tp)
end

function s.e3op1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetCurrentChain() == 0 then
        Duel.SetChainLimitTillChainEnd(s.e3chainlm)
    elseif Duel.GetCurrentChain() == 1 then
        c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                 PHASE_END, 0, 1)
    end
end

function s.e3op2(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:GetFlagEffect(id) ~= 0 then
        Duel.SetChainLimitTillChainEnd(s.e3chainlm)
    end
    c:ResetFlagEffect(id)
end

function s.e3chainlm(e, rp, tp) return tp == rp end

function s.e4filter(c)
    return c:IsSetCard(0x42) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.e4filter, tp, LOCATION_DECK, 0, 1,
                                      1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
