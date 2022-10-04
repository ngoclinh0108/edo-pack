-- In the Name of the Pharaoh
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {10000000, 10000020, CARD_RA}

function s.initial_effect(c)
    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                                                    EFFECT_FLAG_CANNOT_INACTIVATE

    -- activate
    local act = Effect.CreateEffect(c)
    act:SetDescription(aux.Stringid(id, 0))
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetHintTiming(0, TIMING_MAIN_END + TIMING_BATTLE_START)
    act:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    act:SetTarget(s.acttg)
    act:SetOperation(s.actop)
    c:RegisterEffect(act)
end

function s.acttg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return s.e1check(e, tp) or s.e2check(e, tp)
    end

    local op = Duel.SelectEffect(tp, {s.e1check(e, tp), aux.Stringid(id, 1)}, {s.e2check(e, tp), aux.Stringid(id, 2)})
    e:SetLabel(op)

    if op == 1 then
        e:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SUMMON)
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
        Duel.SetOperationInfo(0, CATEGORY_SUMMON, nil, 1, 0, 0)
    elseif op == 2 then
        e:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    end
end

function s.actop(e, tp, eg, ep, ev, re, r, rp)
    local op = e:GetLabel()
    if op == 1 then
        s.e1op(e, tp, eg, ep, ev, re, r, rp)
    elseif op == 2 then
        s.e2op(e, tp, eg, ep, ev, re, r, rp)
    end
end

function s.e1check(e, tp)
    return Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
end

function s.e1filter1(c)
    return (c:IsCode(10000000, 10000020, CARD_RA) or c:ListsCode(10000000, 10000020, CARD_RA)) and not c:IsCode(id) and
               c:IsAbleToHand()
end

function s.e1filter2(c)
    return c:IsSummonable(true, nil) and c:IsRace(RACE_DIVINE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter1, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
        nil)

    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 and
        Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_HAND + LOCATION_MZONE, 0, 1, nil) and
        Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.ShuffleDeck(tp)
        Duel.BreakEffect()

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SUMMON)
        local tc = Duel.SelectMatchingCard(tp, s.e1filter2, tp, LOCATION_HAND + LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
        if tc then
            Duel.Summon(tp, tc, true, nil)
        end
    end
end

function s.e2check(e, tp)
    return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.e2filter(c)
    return c:IsFaceup() and Divine.GetDivineHierarchy(c) > 0 and not Divine.IsDivineEvolution(c)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e2filter, tp, LOCATION_MZONE, 0, nil)
    for tc in aux.Next(g) do
        Divine.DivineEvolution(tc)

        -- atk/def
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(1000)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_UPDATE_DEFENSE)
        tc:RegisterEffect(ec1b)

        -- prevent negation
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_FIELD).ec2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec2:SetCode(EFFECT_CANNOT_INACTIVATE)
        ec2:SetRange(LOCATION_MZONE)
        ec2:SetTargetRange(1, 0)
        ec2:SetValue(function(e, ct)
            local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
            return te:GetHandler() == e:GetHandler()
        end)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
    end
end
