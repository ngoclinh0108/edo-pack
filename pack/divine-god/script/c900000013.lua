-- Ra's Apostle
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 4059313}

function s.initial_effect(c)
    c:SetSPSummonOnce(id)
    c:EnableReviveLimit()

    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                                                    EFFECT_FLAG_CANNOT_INACTIVATE

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

    -- atk up
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- cannot attack
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- effect gain
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e5:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e5:SetCode(EVENT_BE_PRE_MATERIAL)
    e5:SetCondition(s.e5regcon)
    e5:SetOperation(s.e5regop)
    c:RegisterEffect(e5)
end

function s.e1filter(c) return c:IsCode(CARD_RA) and c:IsAbleToHand() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return not Utility.IsOwnAny(Card.IsCode, tp, CARD_RA) or
                   Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = nil
    if Utility.IsOwnAny(Card.IsCode, tp, CARD_RA) then
        tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
        tc = tc:GetFirst()
    else
        tc = Duel.CreateToken(tp, CARD_RA)
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

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetMaterial()

    local atk = 0
    for tc in aux.Next(g) do atk = atk + tc:GetPreviousAttackOnField() end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
    c:RegisterEffect(ec1)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ATTACK)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e5regcon(e, tp, eg, ep, ev, re, r, rp)
    local rc = e:GetHandler():GetReasonCard()
    return r == REASON_SUMMON and rc:IsFaceup() and rc:IsCode(CARD_RA)
end

function s.e5regop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()

    local atk = 0
    local def = 0
    local mg = rc:GetMaterial()
    for tc in aux.Next(mg) do
        atk = atk + tc:GetPreviousAttackOnField()
        def = def + tc:GetPreviousDefenseOnField()
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD)
    rc:RegisterEffect(ec1, true)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec1b:SetValue(def)
    rc:RegisterEffect(ec1b, true)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    ec2:SetCode(EVENT_SUMMON_SUCCESS)
    ec2:SetOperation(s.e5op)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(ec2, true)
end

function s.e5filter(c) return c:IsCode(4059313) and c:IsAbleToHand() end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Utility.IsOwnAny(Card.IsCode, tp, 4059313) and
        not Duel.IsExistingMatchingCard(s.e5filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) then return end
    if not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 2)) then return end

    local tc = nil
    if Utility.IsOwnAny(Card.IsCode, tp, 4059313) then
        tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e5filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
        tc = tc:GetFirst()
    else
        tc = Duel.CreateToken(tp, 4059313)
    end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, tc)
end
