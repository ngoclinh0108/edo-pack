-- Sif, Lady of the Aesir
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")
local s, id = GetID()

s.listed_series = {0x42}

function s.initial_effect(c)
    c:EnableReviveLimit()
    UtilNordic.AesirGodEffect(c)

    -- synchro summon
    Synchro.AddProcedure(c, function(c, sc, sumtype, tp)
        return c:IsAttribute(ATTRIBUTE_LIGHT, sc, sumtype, tp) and
                   c:IsSetCard(0x42, sc, sumtype, tp)
    end, 1, 1, Synchro.NonTuner(nil), 2, 99)

    -- recover
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(UtilNordic.RebornCondition)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e2filter(c) return c:IsFaceup() and c:IsSetCard(0x4b) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local ct =
        Duel.GetMatchingGroupCount(s.e2filter, tp, LOCATION_MZONE, 0, nil)
    if chk == 0 then return ct > 0 end
    Duel.SetTargetPlayer(1 - tp)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, ct * 1000)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
    local ct =
        Duel.GetMatchingGroupCount(s.e2filter, tp, LOCATION_MZONE, 0, nil)
    Duel.Recover(p, ct * 1000, REASON_EFFECT)
end
