-- Palladium Knight of Queen
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(25652259)
    c:RegisterEffect(code)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, {id, 1}, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2b)

    -- gain effect
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and
               not c:IsPublic()
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local rg = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_HAND, 0,
                                     e:GetHandler())
    return #rg > 0 and
               aux.SelectUnselectGroup(rg, e, tp, 1, 1, aux.ChkfMMZ(1), 0)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, c)
    local rg = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_HAND, 0,
                                     e:GetHandler())
    local g = aux.SelectUnselectGroup(rg, e, tp, 1, 1, aux.ChkfMMZ(1), 1, tp,
                                      HINTMSG_CONFIRM, nil, nil, true)
    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
    g:DeleteGroup()
end

function s.e2filter(c)
    return c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and
               c:IsRace(RACE_WARRIOR) and not c:IsCode(25652259) and
               c:IsAbleToHand()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e2filter),
                                         tp, LOCATION_DECK + LOCATION_GRAVE, 0,
                                         1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()
    return (r & REASON_FUSION) ~= 0 and rc:IsAttribute(ATTRIBUTE_LIGHT) and
               rc:IsRace(RACE_WARRIOR)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()

    local ec1 = Effect.CreateEffect(rc)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(ec1, true)

    if not rc:IsType(TYPE_EFFECT) then
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetCode(EFFECT_ADD_TYPE)
        ec2:SetValue(TYPE_EFFECT)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        rc:RegisterEffect(ec2, true)
    end

    local ec3 = Effect.CreateEffect(c)
    ec3:SetDescription(1108)
    ec3:SetCategory(CATEGORY_DRAW)
    ec3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    ec3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec3:SetCode(EVENT_BATTLE_DESTROYING)
    ec3:SetCondition(aux.bdocon)
    ec3:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return true end
        Duel.SetTargetPlayer(tp)
        Duel.SetTargetParam(1)
        Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
    end)
    ec3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                       CHAININFO_TARGET_PARAM)
        Duel.Draw(p, d, REASON_EFFECT)
    end)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(ec3, true)
end
