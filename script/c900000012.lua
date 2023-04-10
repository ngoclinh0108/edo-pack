-- Osiris's Apostle
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {10000020, 42469671}

function s.initial_effect(c)
    c:SetSPSummonOnce(id)
    c:EnableReviveLimit()

    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE

    -- link summon
    Link.AddProcedure(c, nil, 3, 3)

    -- search divine-beast
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- triple tribute
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e2:SetCode(EFFECT_TRIPLE_TRIBUTE)
    e2:SetValue(function(e, c) return c:IsAttribute(ATTRIBUTE_DIVINE) end)
    c:RegisterEffect(e2)

    -- effect gain
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e3:SetCode(EVENT_BE_PRE_MATERIAL)
    e3:SetCondition(s.e3regcon)
    e3:SetOperation(s.e3regop)
    c:RegisterEffect(e3)
end

function s.e1filter(c) return c:IsCode(10000020) and c:IsAbleToHand() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return not Utility.IsOwnAny(Card.IsCode, tp, 10000020) or
                   Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = nil
    if Utility.IsOwnAny(Card.IsCode, tp, 10000020) then
        tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()
    else
        tc = Duel.CreateToken(tp, 10000020)
    end

    if Duel.SendtoHand(tc, nil, REASON_EFFECT) > 0 then
        Duel.ConfirmCards(1 - tp, tc)

        if Duel.GetFlagEffect(tp, id) == 0 then
            Duel.RegisterFlagEffect(tp, id, RESET_PHASE + PHASE_END, 0, 1)
            local ec1 = Effect.CreateEffect(c)
            ec1:SetDescription(aux.Stringid(id, 0))
            ec1:SetType(EFFECT_TYPE_FIELD)
            ec1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
            ec1:SetTargetRange(LOCATION_HAND, 0)
            ec1:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove, 5))
            ec1:SetValue(0x1)
            ec1:SetReset(RESET_PHASE + PHASE_END)
            Duel.RegisterEffect(ec1, tp)
            local ec1b = ec1:Clone()
            ec1b:SetCode(EFFECT_EXTRA_SET_COUNT)
            Duel.RegisterEffect(ec1b, tp)
        end
    end

    local ec2 = Effect.CreateEffect(c)
    ec2:SetDescription(aux.Stringid(id, 1))
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec2:SetCode(EFFECT_CANNOT_SUMMON)
    ec2:SetTargetRange(1, 0)
    ec2:SetTarget(function(e, c) return not c:IsRace(RACE_DIVINE) end)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)
    local ec2b = ec2:Clone()
    ec2b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    Duel.RegisterEffect(ec2b, tp)
    local ec2c = ec2:Clone()
    ec2c:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
    Duel.RegisterEffect(ec2c, tp)
end

function s.e3regcon(e, tp, eg, ep, ev, re, r, rp)
    local rc = e:GetHandler():GetReasonCard()
    return r == REASON_SUMMON and rc:IsFaceup() and rc:IsCode(10000020)
end

function s.e3regop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()
    local eff = Effect.CreateEffect(c)
    eff:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    eff:SetCode(EVENT_SUMMON_SUCCESS)
    eff:SetOperation(s.e3op)
    eff:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(eff, true)
end

function s.e3filter(c) return c:IsCode(42469671) and c:IsAbleToHand() end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Utility.IsOwnAny(Card.IsCode, tp, 42469671) and not Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) then
        return
    end
    if not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 2)) then return end

    local tc = nil
    if Utility.IsOwnAny(Card.IsCode, tp, 42469671) then
        tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e3filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()
    else
        tc = Duel.CreateToken(tp, 42469671)
    end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, tc)
end
