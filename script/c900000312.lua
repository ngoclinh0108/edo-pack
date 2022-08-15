-- Assault Shooting Star Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

s.listed_names = {CARD_STARDUST_DRAGON}
s.synchro_tuner_required = 1
s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synhcro summon
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_SYNCHRO), 1, 1,
        Synchro.NonTunerEx(function(c, val, sc, sumtype, tp)
            return c:IsRace(RACE_DRAGON, sc, sumtype, tp) and c:IsType(TYPE_SYNCHRO, sc, sumtype, tp)
        end), 1, 1)

    -- add code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(SignerDragon.CARD_SHOOTING_STAR_DRAGON)
    c:RegisterEffect(code)

    -- quick synchro
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(1172)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetHintTiming(0, TIMING_MAIN_END)
    e1:SetCountLimit(1)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- indes
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_ONFIELD, 0)
    e2:SetValue(function(e, re, r, rp)
        if (r & REASON_BATTLE + REASON_EFFECT) ~= 0 then
            return 1
        else
            return 0
        end
    end)
    c:RegisterEffect(e2)
end

function s.e1filter(c, tp)
    return c:IsFaceup() and c:IsCode(CARD_STARDUST_DRAGON) and
               Duel.IsExistingMatchingCard(Card.IsSynchroSummonable, tp, LOCATION_EXTRA, 0, 1, nil, c)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() == PHASE_MAIN1 or Duel.GetCurrentPhase() == PHASE_MAIN2
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, tp, LOCATION_EXTRA)
    Duel.SetChainLimit(function(e, rp, tp)
        return tp == rp
    end)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then
        return
    end

    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_MZONE, 0, nil, tp)
    local mc = Utility.GroupSelect(HINTMSG_SMATERIAL, g, tp):GetFirst()
    if not mc then
        return
    end

    Duel.SynchroSummon(tp, c, mc)
end
