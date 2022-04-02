-- Goshenite of Dracodeity
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    UtilityDracodeity.RegisterEffect(c, id)

    -- link summon
    Link.AddProcedure(c, nil, 3, 3)

    -- extra material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_SET_AVAILABLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_EXTRA_MATERIAL)
    e1:SetTargetRange(1, 0)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetCode(EFFECT_ADD_RACE)
    e1b:SetTargetRange(0, LOCATION_MZONE)
    e1b:SetCondition(function(e)
        return Duel.GetFlagEffect(e:GetHandlerPlayer(), id) > 0
    end)
    e1b:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
    e1b:SetValue(RACE_DRAGON)
    c:RegisterEffect(e1b)
end

function s.deck_edit(tp)
    Utility.DeckEditAddCardToDeck(tp, 990000001)
    Utility.DeckEditAddCardToDeck(tp, 990000002)
    Utility.DeckEditAddCardToDeck(tp, 990000003)
    Utility.DeckEditAddCardToDeck(tp, 990000004)
    Utility.DeckEditAddCardToDeck(tp, 990000005)
    Utility.DeckEditAddCardToDeck(tp, 990000006)
    Utility.DeckEditAddCardToDeck(tp, 990000007)
end

function s.e1val(chk, summon_type, e, ...)
    if chk == 0 then
        local tp, sc = ...
        if summon_type ~= SUMMON_TYPE_LINK or
            not (sc and sc:IsRace(RACE_HIGHDRAGON)) then
            return Group.CreateGroup()
        else
            Duel.RegisterFlagEffect(tp, id, 0, 0, 1)
            return Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE,
                                         nil)
        end
    elseif chk == 2 then
        Duel.ResetFlagEffect(e:GetHandlerPlayer(), id)
    end
end
