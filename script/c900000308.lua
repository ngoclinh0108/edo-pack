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
    spr:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
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

    -- cannot be release, or be material
    local matlimit = Effect.CreateEffect(c)
    matlimit:SetType(EFFECT_TYPE_SINGLE)
    matlimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    matlimit:SetCode(EFFECT_UNRELEASABLE_SUM)
    matlimit:SetValue(1)
    c:RegisterEffect(matlimit)
    local matlimit2 = matlimit:Clone()
    matlimit2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(matlimit2)
    local matlimit3 = matlimit:Clone()
    matlimit3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    c:RegisterEffect(matlimit3)
    local matlimit4 = matlimit:Clone()
    matlimit4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    c:RegisterEffect(matlimit4)
    local matlimit5 = matlimit:Clone()
    matlimit5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    c:RegisterEffect(matlimit5)
    local matlimit6 = matlimit:Clone()
    matlimit6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    c:RegisterEffect(matlimit6)

    -- immune
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    me1:SetCode(EFFECT_IMMUNE_EFFECT)
    me1:SetRange(LOCATION_MZONE)
    me1:SetValue(function(e, te)
        return te:GetOwner() ~= e:GetOwner()
    end)
    c:RegisterEffect(me1)

    -- cannot be target
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_SINGLE)
    me2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    me2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    me2:SetRange(LOCATION_MZONE)
    me2:SetCondition(function(e)
        return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsType, TYPE_SYNCHRO), e:GetHandlerPlayer(),
            LOCATION_MZONE, 0, 1, e:GetHandler())
    end)
    me2:SetValue(aux.imval2)
    c:RegisterEffect(me2)
    local me2b = me2:Clone()
    me2b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    me2b:SetValue(aux.tgoval)
    c:RegisterEffect(me2b)

    -- place to pendulum zone
    local me3 = Effect.CreateEffect(c)
    me3:SetDescription(aux.Stringid(id, 0))
    me3:SetType(EFFECT_TYPE_IGNITION)
    me3:SetRange(LOCATION_MZONE)
    me3:SetTarget(s.me3tg)
    me3:SetOperation(s.me3op)
    c:RegisterEffect(me3)

    -- immune
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_SINGLE)
    pe1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    pe1:SetCode(EFFECT_IMMUNE_EFFECT)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetValue(function(e, te)
        return te:GetOwner() ~= e:GetOwner()
    end)
    c:RegisterEffect(pe1)
end

function s.deck_edit(tp)
    Utility.DeckEditAddCardToDeck(tp, 900000302)
    Utility.DeckEditAddCardToDeck(tp, 900000303)
    Utility.DeckEditAddCardToDeck(tp, 900000304)
    Utility.DeckEditAddCardToDeck(tp, 900000305)
    Utility.DeckEditAddCardToDeck(tp, 900000306)
    Utility.DeckEditAddCardToDeck(tp, 900000307)
    Utility.DeckEditAddCardToDeck(tp, 7841112, CARD_STARDUST_DRAGON, true)
    Utility.DeckEditAddCardToDeck(tp, 67030233, SignerDragon.CARD_RED_DRAGON_ARCHFIEND, true)
    Utility.DeckEditAddCardToDeck(tp, 900000311, CARD_BLACK_WINGED_DRAGON, true)
    Utility.DeckEditAddCardToDeck(tp, 900000312, CARD_BLACK_ROSE_DRAGON, true)
    Utility.DeckEditAddCardToDeck(tp, 900000313, SignerDragon.CARD_ANCIENT_FAIRY_DRAGON, true)
    Utility.DeckEditAddCardToDeck(tp, 900000314, SignerDragon.CARD_LIFE_STREAM_DRAGON, true)
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

function s.me3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.CheckLocation(tp, LOCATION_PZONE, 0) or Duel.CheckLocation(tp, LOCATION_PZONE, 1)
    end
end

function s.me3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or not Duel.CheckLocation(tp, LOCATION_PZONE, 0) and
        not Duel.CheckLocation(tp, LOCATION_PZONE, 1) then
        return
    end

    Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
end
