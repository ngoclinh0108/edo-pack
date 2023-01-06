-- Raviel, Ruler of Phantasms
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {69890968}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon procedure
    local spr = Effect.CreateEffect(c)
    spr:SetType(EFFECT_TYPE_FIELD)
    spr:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    spr:SetCode(EFFECT_SPSUMMON_PROC)
    spr:SetRange(LOCATION_HAND)
    spr:SetCondition(s.sprcon)
    spr:SetOperation(s.sprop)
    c:RegisterEffect(spr)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(splimit)

    -- special summon cannot be negated
    local spsafe = Effect.CreateEffect(c)
    spsafe:SetType(EFFECT_TYPE_SINGLE)
    spsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(spsafe)

    -- no change control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- cannot be tributed, or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc)
        return tc == e:GetHandler()
    end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc)
        return tc and tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(nomaterial)

    -- special summon tokens
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1b)

    -- tribute up ATK
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.e2cost)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.sprfilter(c, tp)
    return c:IsControler(tp) and c:GetSequence() < 5
end

function s.sprcon(e, c)
    if c == nil then
        return true
    end
    local tp = c:GetControler()
    local rg = Duel.GetReleaseGroup(tp)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local ct = -ft + 1
    return ft > -3 and #rg > 2 and (ft > 0 or rg:IsExists(s.sprfilter, ct, nil, tp))
end

function s.sprop(e, tp, eg, ep, ev, re, r, rp, c)
    local rg = Duel.GetReleaseGroup(tp)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local g = nil

    if ft > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
        g = rg:Select(tp, 3, 3, nil)
    elseif ft > -2 then
        local ct = -ft + 1
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
        g = rg:FilterSelect(tp, s.mzfilter, ct, ct, nil, tp)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
        local g2 = rg:Select(tp, 3 - ct, 3 - ct, g)
        g:Merge(g2)
    else
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
        g = rg:FilterSelect(tp, s.mzfilter, 3, 3, nil, tp)
    end

    Duel.Release(g, REASON_COST)
end

function s.e1filter(c, sp)
    if c:IsLocation(LOCATION_MZONE) then
        return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:GetSummonPlayer() == sp
    else
        return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetSummonPlayer() == sp
    end
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e1filter, 1, nil, 1 - tp) and
               (not re or (not re:IsHasType(EFFECT_TYPE_ACTIONS) or re:IsHasType(EFFECT_TYPE_CONTINUOUS))) and
               Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
               Duel.IsPlayerCanSpecialSummonMonster(tp, id + 1, 0, TYPES_TOKEN, 1000, 1000, 1, RACE_FIEND,
            ATTRIBUTE_DARK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Utility.HintCard(c)

    local token = Duel.CreateToken(tp, 69890968)
    Duel.SpecialSummon(token, 0, tp, tp, false, false, POS_FACEUP)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    token:RegisterEffect(ec1, true)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, Card.IsFaceup, 1, false, nil, c)
    end

    local g = Duel.SelectReleaseGroupCost(tp, Card.IsFaceup, 1, 2, false, nil, c)
    e:SetLabel(g:GetSum(Card.GetAttack))
    Duel.Release(g, REASON_COST)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then
        return
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(e:GetLabel())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end
