-- Evil HERO Vicious Scraper
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_FUSION, 75524092}
s.listed_series = {0x8, 0x6008}
s.material_setcode = {0x8, 0x6008}
s.dark_calling = true

function s.initial_effect(c)
    c:EnableReviveLimit()
    
    -- fusion summon
    Fusion.AddProcMix(c, true, true, aux.FilterBoolFunctionEx(Card.IsSetCard, 0x6008),
        aux.FilterBoolFunctionEx(Card.IsLevelBelow, 4))

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

    -- equip vicious claw
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- pierce
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e2)

    -- handes
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_HANDES)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_BATTLE_DAMAGE)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c, ec) return c:IsCode(75524092) and c:CheckEquipTarget(ec) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, loc, 0, 1, nil, c) and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
    end

    Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, tp, loc)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_EQUIP, tp, aux.NecroValleyFilter(s.e1filter), tp,
        LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, c):GetFirst()
    if tc then Duel.Equip(tp, tc, c) end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return ep ~= tp end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_HANDES, 0, 0, 1 - tp, 1)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetFieldGroup(ep, LOCATION_HAND, 0, nil)
    if #g == 0 then return end

    local sg = g:RandomSelect(1 - tp, 1)
    Duel.SendtoGrave(sg, REASON_DISCARD + REASON_EFFECT)
end
