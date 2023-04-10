-- Wicked's Apostle
Duel.LoadScript("util.lua")
local s, id = GetID()

local wicked_monsters = {62180201, 57793869, 21208154}
s.listed_names = {62180201, 57793869, 21208154, 7373632}

function s.initial_effect(c)
    c:SetSPSummonOnce(id)
    c:EnableReviveLimit()

    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                                                    EFFECT_FLAG_CANNOT_INACTIVATE

    -- link summon
    Link.AddProcedure(c, nil, 3, 3)

    -- search wicked
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
    e2:SetValue(function(e, c) return c:IsCode(wicked_monsters) end)
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

function s.e1filter(c, code) return c:IsCode(code) and c:IsAbleToHand() end

function s.e1check1(tp)
    return not Utility.IsOwnAny(Card.IsCode, tp, 62180201) or
               Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, 62180201)
end

function s.e1check2(tp)
    return not Utility.IsOwnAny(Card.IsCode, tp, 57793869) or
               Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, 57793869)
end

function s.e1check3(tp)
    return not Utility.IsOwnAny(Card.IsCode, tp, 21208154) or
               Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, 21208154)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return s.e1check1(tp) or s.e1check2(tp) or s.e1check3(tp) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local opt = {}
    local sel = {}
    if s.e1check1(tp) then
        table.insert(opt, aux.Stringid(id, 2))
        table.insert(sel, 1)
    end
    if s.e1check2(tp) then
        table.insert(opt, aux.Stringid(id, 3))
        table.insert(sel, 2)
    end
    if s.e1check3(tp) then
        table.insert(opt, aux.Stringid(id, 4))
        table.insert(sel, 3)
    end

    local code = nil
    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]
    if op == 1 then
        code = 62180201
    elseif op == 2 then
        code = 57793869
    elseif op == 3 then
        code = 21208154
    end

    local tc = nil
    if Utility.IsOwnAny(Card.IsCode, tp, code) then
        tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, code)
        tc = tc:GetFirst()
    else
        tc = Duel.CreateToken(tp, code)
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
    ec2:SetTarget(function(e, c) return not c:IsCode(wicked_monsters) end)
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
    return r == REASON_SUMMON and rc:IsFaceup() and rc:IsCode(wicked_monsters)
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

function s.e3filter(c) return c:IsCode(7373632) and c:IsAbleToHand() end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Utility.IsOwnAny(Card.IsCode, tp, 7373632) and
        not Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) then return end
    if not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 5)) then return end

    local tc = nil
    if Utility.IsOwnAny(Card.IsCode, tp, 7373632) then
        tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e3filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
        tc = tc:GetFirst()
    else
        tc = Duel.CreateToken(tp, 7373632)
    end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, tc)
end
