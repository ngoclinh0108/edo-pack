-- Assault Shooting Star Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

s.material = {CARD_STARDUST_DRAGON}
s.listed_names = {CARD_STARDUST_DRAGON}
s.synchro_tuner_required = 1
s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synhcro summon
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_SYNCHRO), 1, 1, function(c, sc, sumtype, tp)
        if c:IsSummonCode(sc, sumtype, tp, CARD_STARDUST_DRAGON) then
            return true
        end
        return not c:IsType(TYPE_TUNER, sc, sumtype, tp) and c:IsType(TYPE_SYNCHRO, sc, sumtype, tp)
    end, 1, 1)

    -- add code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(SignerDragon.CARD_SHOOTING_STAR_DRAGON)
    c:RegisterEffect(code)

    -- opponent's turn synchro
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(1172)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetHintTiming(0, TIMING_END_PHASE)
    e1:SetCountLimit(1)
    e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return Duel.GetTurnPlayer() ~= tp
    end)
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

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return e:GetHandler():IsSynchroSummonable(nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, tp, LOCATION_EXTRA)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then
        return
    end

    Duel.SynchroSummon(tp, c, nil)
end
