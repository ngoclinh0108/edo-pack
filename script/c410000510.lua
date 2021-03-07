-- Stardust Moose
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetTargetRange(POS_FACEUP_DEFENSE, 0)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- synchro level
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e2:SetCode(EFFECT_SYNCHRO_LEVEL)
    e2:SetValue(function(e, c) return 1 * 65536 + e:GetHandler():GetLevel() end)
    c:RegisterEffect(e2)

    -- draw
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c) return c:IsFaceup() and c:IsType(TYPE_TUNER) end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsLocation(LOCATION_GRAVE) and r == REASON_SYNCHRO
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end
