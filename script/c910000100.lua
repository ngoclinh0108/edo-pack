-- Millennium Memories
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785}
s.listed_series = {0x13a}
s.counter_place_list = {COUNTER_SPELL}

function s.initial_effect(c)
    -- activate
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetHintTiming(TIMING_DAMAGE_STEP)
    e0:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e0:SetTarget(Utility.MultiEffectTarget(s, s.extg))
    e0:SetOperation(Utility.MultiEffectOperation(s))
    c:RegisterEffect(e0)

    -- search
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    Utility.RegisterMultiEffect(s, 1, e1)

    -- spell counter
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_COUNTER)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    Utility.RegisterMultiEffect(s, 2, e2)

    -- atk up & unaffected
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    Utility.RegisterMultiEffect(s, 3, e3)
end

function s.extg(e, tp, eg, ep, ev, re, r, rp, chk)
    if e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler() == e:GetOwner() and
        Duel.IsExistingMatchingCard(
            aux.FilterFaceupFunction(Card.IsCode, 71703785), tp,
            LOCATION_ONFIELD, 0, 1, nil) then
        Duel.SetChainLimit(function(e, ep, tp) return tp == ep end)
    end
end

function s.e1filter(c)
    return c:IsSetCard(0x13a) and c:IsType(TYPE_SPELL + TYPE_TRAP) and
               c:IsAbleToHand()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp,
                                         aux.NecroValleyFilter(s.e1filter), tp,
                                         LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                         1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e2filter(c)
    return c:IsFaceup() and c:IsCanAddCounter(COUNTER_SPELL, 1)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_ONFIELD,
                                           LOCATION_ONFIELD, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_COUNTER, nil, 1, 0, COUNTER_SPELL)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Utility.SelectMatchingCard(aux.Stringid(id, 4), tp, s.e2filter,
                                          tp, LOCATION_ONFIELD,
                                          LOCATION_ONFIELD, 1, 1, nil):GetFirst()

    local max = tc:IsCanAddCounter(COUNTER_SPELL, 2) and 2 or 1
    local ct = 1
    if max > 1 then ct = Duel.AnnounceNumber(tp, 1, max) end
    tc:AddCounter(COUNTER_SPELL, ct)
end

function s.e3filter(c) return c:IsFaceup() and c:IsSetCard(0x13a) end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_MZONE, 0, 1,
                                           nil)
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local g = Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_MZONE, 0, nil)
    for tc in aux.Next(g) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(1000)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)

        local ec2 = ec1:Clone()
        ec2:SetDescription(3110)
        ec2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec2:SetCode(EFFECT_IMMUNE_EFFECT)
        ec2:SetOwnerPlayer(tp)
        ec2:SetValue(function(e, re)
            return e:GetHandler():GetOwner() ~= re:GetHandler():GetOwner()
        end)
        tc:RegisterEffect(ec2)
    end
end
