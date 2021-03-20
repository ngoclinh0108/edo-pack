-- Elemental HERO Space Neos
local s, id = GetID()
Duel.LoadScript("util.lua")

s.listed_names = {CARD_NEOS}
s.material_setcode = {0x8, 0x3008, 0x9}
s.listed_series = {0x1f, 0x8}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Fusion.AddProcMix(c, true, true, CARD_NEOS,
                      aux.FilterBoolFunctionEx(Card.IsType, TYPE_EFFECT))

    -- special summon condition
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        if e:GetHandler():IsLocation(LOCATION_EXTRA) then
            return (st & SUMMON_TYPE_FUSION) == SUMMON_TYPE_FUSION
        end
        return true
    end)
    c:RegisterEffect(splimit)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)

    -- make a second attack in a row
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and
               (c:IsSetCard(0x1f) or c:IsSetCard(0x8))
end

function s.e1val(e, c)
    return Duel.GetMatchingGroupCount(s.e1filter, c:GetControler(),
                                      LOCATION_GRAVE, 0, nil) * 100
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return
        Duel.GetAttacker() == c and aux.bdocon(e, tp, eg, ep, ev, re, r, rp) and
            c:CanChainAttack()
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp) Duel.ChainAttack() end
