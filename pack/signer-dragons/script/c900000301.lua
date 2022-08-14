-- Ultimaya Cosmic Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(splimit)

    -- special summon procedure
    local spr = Effect.CreateEffect(c)
    spr:SetType(EFFECT_TYPE_FIELD)
    spr:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    spr:SetCode(EFFECT_SPSUMMON_PROC)
    spr:SetRange(LOCATION_EXTRA)
    spr:SetCondition(s.sprcon)
    spr:SetTarget(s.sprtg)
    spr:SetOperation(s.sprop)
    c:RegisterEffect(spr)

    -- summon cannot be negated
    local spsafe = Effect.CreateEffect(c)
    spsafe:SetType(EFFECT_TYPE_SINGLE)
    spsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(spsafe)

    -- immune
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(function(e, te)
        return te:GetOwner() ~= e:GetOwner()
    end)
    c:RegisterEffect(e3)

    -- cannot be target
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(function(e)
        return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsType, TYPE_SYNCHRO), e:GetHandlerPlayer(),
            LOCATION_MZONE, 0, 1, e:GetHandler())
    end)
    e4:SetValue(aux.imval2)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e4b:SetValue(aux.tgoval)
    c:RegisterEffect(e4b)
end

function s.deck_edit(tp)
    Utility.DeckEditAddCardToDeck(tp, 7841112, CARD_STARDUST_DRAGON, true)
    Utility.DeckEditAddCardToDeck(tp, 67030233, SignerDragon.CARD_RED_DRAGON_ARCHFIEND, true)
    Utility.DeckEditAddCardToDeck(tp, 900000302, CARD_BLACK_WINGED_DRAGON, true)
    Utility.DeckEditAddCardToDeck(tp, 900000303, CARD_BLACK_ROSE_DRAGON, true)
    Utility.DeckEditAddCardToDeck(tp, 900000304, SignerDragon.CARD_ANCIENT_FAIRY_DRAGON, true)
    Utility.DeckEditAddCardToDeck(tp, 900000305, SignerDragon.CARD_LIFE_STREAM_DRAGON, true)
    Utility.DeckEditAddCardToDeck(tp, 40939228, SignerDragon.CARD_SHOOTING_STAR_DRAGON, true)
end

function s.sprfilter(c)
    return c:IsFaceup() and c:IsLevelAbove(7) and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and
               c:IsAbleToGraveAsCost()
end

function s.sprfilter1(c, tp, g, sc)
    local lv = c:GetLevel()
    local g = Duel.GetMatchingGroup(s.sprfilter, tp, LOCATION_MZONE, 0, nil)
    return c:IsType(TYPE_TUNER) and g:IsExists(s.sprfilter2, 1, c, tp, c, sc, lv)
end

function s.sprfilter2(c, tp, mc, sc, lv)
    local sg = Group.FromCards(c, mc)
    return c:GetLevel() == lv and not c:IsType(TYPE_TUNER) and Duel.GetLocationCountFromEx(tp, tp, sg, sc) > 0
end

function s.sprcon(e, c)
    if c == nil then
        return true
    end
    local tp = c:GetControler()

    local g = Duel.GetMatchingGroup(s.sprfilter, tp, LOCATION_MZONE, 0, nil)
    return g:IsExists(s.sprfilter1, 1, nil, tp, g, c)
end

function s.sprtg(e, tp, eg, ep, ev, re, r, rp, c)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.sprfilter, tp, LOCATION_MZONE, 0, nil)
    local mg1 = aux.SelectUnselectGroup(g:Filter(s.sprfilter1, nil, tp, g, c), e, tp, 1, 1, nil, 1, tp, HINTMSG_TOGRAVE,
        nil, nil, true)

    if #mg1 > 0 then
        local mc = mg1:GetFirst()
        local mg2 = aux.SelectUnselectGroup(g:Filter(s.sprfilter2, mc, tp, mc, c, mc:GetLevel()), e, tp, 1, 1, nil, 1,
            tp, HINTMSG_TOGRAVE, nil, nil, true)
        mg1:Merge(mg2)
    end

    if #mg1 == 2 then
        mg1:KeepAlive()
        e:SetLabelObject(mg1)
        return true
    end

    return false
end

function s.sprop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then
        return
    end

    Duel.SendtoGrave(g, REASON_COST)
    g:DeleteGroup()
end
