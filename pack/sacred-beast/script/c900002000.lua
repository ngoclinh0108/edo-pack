-- The Eye of Phantasms
Duel.LoadScript("util.lua")
local s, id = GetID()
s.listed_names = {6007213, 32491822, 69890967, 43378048}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetCategory(CATEGORY_TODECK)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- effects cannot be negated
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetRange(LOCATION_FZONE)
    e1b:SetCode(EFFECT_CANNOT_INACTIVATE)
    e1b:SetTargetRange(1, 0)
    e1b:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(e1b)
    local e1c = e1b:Clone()
    e1c:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e1c)

    -- protect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetTarget(s.e2tg)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2b:SetValue(s.e2val)
    c:RegisterEffect(e2b)

    -- draw
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1, {id, 1})
    e3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return s.sbcount(e:GetHandlerPlayer()) >= 1
    end)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- return spell/trap to hand
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1, {id, 2})
    e4:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return s.sbcount(e:GetHandlerPlayer()) >= 2
    end)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- untargetable & indes
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e5:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return s.sbcount(e:GetHandlerPlayer()) >= 3
    end)
    e5:SetValue(aux.tgoval)
    c:RegisterEffect(e5)
    local e5b = e5:Clone()
    e5b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e5b:SetValue(function(e, re, rp)
        return rp ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e5b)

    -- attach spell/trap
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 2))
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_FZONE)
    e6:SetCountLimit(1)
    e6:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return s.sbcount(e:GetHandlerPlayer()) >= 4
    end)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
end

function s.e2tg(e, c)
    return c:IsCode(6007213, 32491822, 69890967, 43378048)
end

function s.e2val(e, re, rp)
    return rp == 1 - e:GetHandlerPlayer()
end

function s.sbfilter(c)
    return c:IsFaceup() and c:IsCode(6007213, 32491822, 69890967, 43378048)
end

function s.sbcount(tp)
    return Duel.GetMatchingGroup(s.sbfilter, tp, LOCATION_ONFIELD, 0, nil):GetClassCount(Card.GetCode)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsPlayerCanDraw(tp, 2)
    end

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(2)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 2)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then
        return
    end

    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end

function s.e4filter(c)
    return c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsAbleToHand()
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_GRAVE, 0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then
        return
    end

    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e4filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e6filter(c, og)
    return c:IsFaceup() and c:IsType(TYPE_CONTINUOUS) and c:ListsCode(6007213, 32491822, 69890967, 43378048) and
               not og:IsExists(Card.IsCode, 1, nil, c:GetCode()) and not c:IsCode(id)
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e6filter, tp, LOCATION_ONFIELD, 0, 1, c, og)
    end
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then
        return
    end

    local og = c:GetOverlayGroup()
    local tc =
        Utility.SelectMatchingCard(HINTMSG_FACEUP, tp, s.e6filter, tp, LOCATION_ONFIELD, 0, 1, 1, c, og):GetFirst()
    if tc then
        Duel.Overlay(c, tc)
        c:CopyEffect(tc:GetCode(), RESET_EVENT + RESETS_STANDARD)
    end
end
