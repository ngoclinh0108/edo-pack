-- Divine Servant
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.listed_names = {Divine.CARD_OBELISK, Divine.CARD_SLIFER, Divine.CARD_RA}

function s.initial_effect(c)
    -- activate
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                       EFFECT_FLAG_CANNOT_INACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetHintTiming(0, TIMING_MAIN_END + TIMING_BATTLE_START)
    e0:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e0:SetCondition(function()
        return Duel.IsMainPhase() or Duel.IsBattlePhase()
    end)
    e0:SetTarget(Utility.MultiEffectTarget(s))
    e0:SetOperation(Utility.MultiEffectOperation(s))
    c:RegisterEffect(e0)

    -- tribute summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SUMMON)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    Utility.RegisterMultiEffect(s, 1, e1)

    -- divine evolution
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    Utility.RegisterMultiEffect(s, 2, e2)
end

function s.e1filter1(c, ec)
    if not c:IsRace(RACE_DIVINE) then return false end

    local ec1 = Effect.CreateEffect(ec)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    ec1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
    ec1:SetTargetRange(0, LOCATION_MZONE)
    ec1:SetValue(POS_FACEUP)
    ec1:SetReset(RESET_CHAIN)
    c:RegisterEffect(ec1, true)

    local res = c:IsSummonable(true, nil, 1) or c:IsMSetable(true, nil, 1)
    ec1:Reset()
    return res
end

function s.e1filter2(c)
    return c:IsCode(Divine.CARD_OBELISK, Divine.CARD_SLIFER, Divine.CARD_RA) and
               c:IsAbleToHand()
end

function s.e1check1(e, tp)
    return Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_HAND, 0, 1,
                                       nil, e:GetHandler())
end

function s.e1check2(tp)
    return
        Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_DECK, 0, 1, nil) and
            Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil):GetClassCount(
                Card.GetCode) >= 3
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return (Duel.IsMainPhase() or Duel.IsBattlePhase()) and
                   (s.e1check1(e, tp) or s.e1check2(tp))
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_SUMMON, nil, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local b1 = s.e1check1(e, tp)
    local b2 = s.e1check2(tp)

    if (not b1 and b2) or (b2 and Duel.SelectYesNo(tp, 506)) then
        local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter2,
                                             tp, LOCATION_DECK, 0, 1, 1, nil)
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end

    local sc = Utility.SelectMatchingCard(HINTMSG_SUMMON, tp, s.e1filter1, tp,
                                          LOCATION_HAND, 0, 1, 1, nil, c):GetFirst()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
    ec1:SetTargetRange(0, LOCATION_MZONE)
    ec1:SetValue(POS_FACEUP)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    sc:RegisterEffect(ec1, true)

    local s1 = sc:IsSummonable(true, nil, 1)
    local s2 = sc:IsMSetable(true, nil, 1)
    if (s1 and s2 and
        Duel.SelectPosition(tp, tc, POS_FACEUP_ATTACK + POS_FACEDOWN_DEFENSE) ==
        POS_FACEUP_ATTACK) or not s2 then
        Duel.Summon(tp, sc, true, nil, 1)
    else
        Duel.MSet(tp, sc, true, nil, 1)
    end
end

function s.e2filter(c)
    return c:IsFaceup() and c:IsOriginalRace(RACE_DIVINE) and
               Divine.GetDivineHierarchy(c) > 0 and
               not Divine.IsDivineEvolution(c)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_MZONE, 0, 1,
                                           nil)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_FACEUP, tp, s.e2filter, tp,
                                          LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
    if not tc then return end

    Duel.HintSelection(Group.FromCards(tc))
    Divine.DivineEvolution(tc)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EFFECT_CANNOT_DISABLE)
    Divine.RegisterEffect(tc, ec1)
    local ec1b = Effect.CreateEffect(c)
    ec1b:SetType(EFFECT_TYPE_FIELD)
    ec1b:SetRange(LOCATION_MZONE)
    ec1b:SetCode(EFFECT_CANNOT_INACTIVATE)
    ec1b:SetTargetRange(1, 0)
    ec1b:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    Divine.RegisterEffect(tc, ec1b)
    local ec1c = ec1b:Clone()
    ec1c:SetCode(EFFECT_CANNOT_DISEFFECT)
    Divine.RegisterEffect(tc, ec1c)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec2:SetCode(EFFECT_UPDATE_ATTACK)
    ec2:SetValue(1000)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec2)
    local ec2b = ec2:Clone()
    ec2b:SetCode(EFFECT_UPDATE_DEFENSE)
    tc:RegisterEffect(ec2b)
end
