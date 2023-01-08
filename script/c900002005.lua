-- Successor of Phantasmal Lord
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {6007213, 32491822, 69890967}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, {6007213, 32491822, 69890967}, aux.FilterBoolFunctionEx(Card.IsType, TYPE_EFFECT))
    Fusion.AddContactProc(c, s.fusfilter, s.fusop, s.splimit)

    -- indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
end

function s.splimit(e, se, sp, st)
    return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

function s.fusfilter(tp)
    return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_ONFIELD, 0, nil)
end

function s.fusop(g, tp)
    Duel.ConfirmCards(1 - tp, g)
    Duel.Remove(g, POS_FACEUP, REASON_COST + REASON_MATERIAL)
end
