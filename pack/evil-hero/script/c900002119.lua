-- Evil HERO Faustian Slayer
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_FUSION}
s.listed_series = {0x8, 0x6008}
s.material_setcode = {0x8, 0x6008}
s.dark_calling = true

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMixRep(c, true, true, aux.FilterBoolFunctionEx(Card.IsSummonLocation, LOCATION_EXTRA), 1, 99,
        aux.FilterBoolFunctionEx(Card.IsSetCard, 0x6008))

    -- lizard check
    local lizcheck = Effect.CreateEffect(c)
    lizcheck:SetType(EFFECT_TYPE_SINGLE)
    lizcheck:SetCode(CARD_CLOCK_LIZARD)
    lizcheck:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    lizcheck:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(), EFFECT_SUPREME_CASTLE)
    end)
    lizcheck:SetValue(1)
    c:RegisterEffect(lizcheck)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.EvilHeroLimit)
    c:RegisterEffect(splimit)

    -- atk up
    local e1reg = Effect.CreateEffect(c)
    e1reg:SetType(EFFECT_TYPE_SINGLE)
    e1reg:SetCode(EFFECT_MATERIAL_CHECK)
    e1reg:SetValue(s.e1regval)
    c:RegisterEffect(e1reg)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    e1:SetLabelObject(e1reg)
    c:RegisterEffect(e1)
end

function s.e1regval(e, c)
    local g = c:GetMaterial()
    e:SetLabel(#g)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local atk = e:GetLabelObject():GetLabel() * 200
    if atk > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(atk)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec1)
    end
end
