-- Goshenite of Dracodeity
local s, id = GetID()

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, nil, 3, 3)

    -- attribute
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE +
                       EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_REMOVE_ATTRIBUTE)
    e1:SetValue(ATTRIBUTE_LIGHT)
    c:RegisterEffect(e1)

    -- extra material
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_SET_AVAILABLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_EXTRA_MATERIAL)
    e2:SetTargetRange(1, 0)
    e2:SetValue(s.e2val)
    c:RegisterEffect(e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_FIELD)
    e2b:SetRange(LOCATION_MZONE)
    e2b:SetCode(EFFECT_ADD_RACE)
    e2b:SetTargetRange(0, LOCATION_MZONE)
    e2b:SetCondition(function(e)
        return Duel.GetFlagEffect(e:GetHandlerPlayer(), id) > 0
    end)
    e2b:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
    e2b:SetValue(RACE_DRAGON)
    c:RegisterEffect(e2b)
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

function s.e2val(chk, summon_type, e, ...)
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
