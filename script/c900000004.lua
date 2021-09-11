-- Sun Divine Beast of Ra - Sphere Mode
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 10000080}

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 2, false, false)
    Dimension.AddProcedure(c)

    -- dimension change
    Dimension.RegisterChange(s, c, function(_, tp)
        local dms1 = Effect.CreateEffect(c)
        dms1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        dms1:SetCode(EVENT_SUMMON_SUCCESS)
        dms1:SetOperation(s.dms1op)
        Duel.RegisterEffect(dms1, tp)

        local dms2reg = Effect.CreateEffect(c)
        dms2reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        dms2reg:SetCode(EVENT_SUMMON_SUCCESS)
        dms2reg:SetOperation(s.dms2regop)
        Duel.RegisterEffect(dms2reg, tp)
        local dms2 = Effect.CreateEffect(c)
        dms2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        dms2:SetCode(EVENT_ADJUST)
        dms2:SetCondition(s.dms2con)
        dms2:SetOperation(s.dms2op)
        Duel.RegisterEffect(dms2, tp)
    end)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_MACHINE)
    Divine.RegisterEffect(c, e1)

    -- cannot attack
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    Divine.RegisterEffect(c, e2)

    -- cannot be target
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(1)
    Divine.RegisterEffect(c, e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
    Divine.RegisterEffect(c, e3b)

    -- ancient chant
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_BOTH_SIDE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    Divine.RegisterEffect(c, e4)
end

function s.dms1filter(c, tp, rp)
    return Dimension.CanBeDimensionMaterial(c) and c:IsCode(CARD_RA) and
               c:GetOwner() == tp and tp ~= rp and
               not Utility.IsOwnAny(Card.IsCode, rp, 10000080)
end

function s.dms1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local mc = eg:Filter(s.dms1filter, nil, c:GetOwner(), rp):GetFirst()
    if not mc then return end
    if not Dimension.CanBeDimensionChanged(c) then return end

    local divine_evolution = mc:GetFlagEffect(Divine.DIVINE_EVOLUTION) > 0
    Dimension.Change(mc, c, rp, rp, mc:GetPosition())
    if divine_evolution then
        c:RegisterFlagEffect(Divine.DIVINE_EVOLUTION,
                             RESET_EVENT + RESETS_STANDARD,
                             EFFECT_FLAG_CLIENT_HINT, 1, 0, 666003)
    end
end

function s.dms2filter(c, check_flag)
    if check_flag and c:GetFlagEffect(id) == 0 then return false end
    return c:IsCode(CARD_RA)
end

function s.dms2regop(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(s.dms2filter, nil, false)
    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                  PHASE_END, 0, 1)
    end
end

function s.dms2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local mc = Utility.SelectMatchingCard(tp, s.dms2filter, tp, LOCATION_MZONE,
                                          0, 1, 1, nil, true):GetFirst()
    if not mc then return end
    mc:ResetFlagEffect(id)

    -- calculate atk/def
    local atk = 0
    local def = 0
    if mc:IsSummonType(SUMMON_TYPE_TRIBUTE) then
        local mg = mc:GetMaterial()
        for mc in aux.Next(mg) do
            if mc:GetPreviousAttackOnField() > 0 then
                atk = atk + mc:GetPreviousAttackOnField()
            end
            if mc:GetPreviousDefenseOnField() > 0 then
                def = def + mc:GetPreviousDefenseOnField()
            end
        end
    end

    -- set base atk/def
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterEffect(mc, ec1, true)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec1b:SetValue(def)
    Divine.RegisterEffect(mc, ec1b, true)

    -- unstoppable attack
    local ec2 = Effect.CreateEffect(c)
    ec2:SetDescription(aux.Stringid(id, 1))
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE +
                        EFFECT_FLAG_CLIENT_HINT)
    ec2:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    ec2:SetRange(LOCATION_MZONE)
    Divine.RegisterEffect(mc, ec2, true)
    local spnoattack = mc:GetCardEffect(EFFECT_CANNOT_ATTACK)
    if spnoattack then spnoattack:Reset() end
end

function s.dms2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.dms2filter, tp, LOCATION_MZONE, 0, 1,
                                       nil, true)
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Dimension.IsAbleToDimension(c) end
    e:SetLabel(c:GetFlagEffect(Divine.DIVINE_EVOLUTION))
    Dimension.SendToDimension(c, REASON_COST)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local mc = c:GetMaterial():GetFirst()
    if chk == 0 then
        return c:GetOwner() == tp and mc and
                   (c:GetControler() == tp or
                       Duel.GetLocationCount(tp, LOCATION_MZONE) > 0) and
                   Dimension.CanBeDimensionSummoned(mc, e, tp, false, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, mc, 1, 0, 0)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp, immediately)
    local c = e:GetHandler()
    local mc = c:GetMaterial():GetFirst()
    if not mc then return end
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then
        Duel.SendtoGrave(mc, REASON_RULE)
        return
    end

    -- calculate atk/def
    local atk = 0
    local def = 0
    if mc:IsSummonType(SUMMON_TYPE_TRIBUTE) then
        local mg = mc:GetMaterial()
        for mc in aux.Next(mg) do
            if mc:GetPreviousAttackOnField() > 0 then
                atk = atk + mc:GetPreviousAttackOnField()
            end
            if mc:GetPreviousDefenseOnField() > 0 then
                def = def + mc:GetPreviousDefenseOnField()
            end
        end
    else
        atk = 4000
        def = 4000
    end

    -- transform
    local pos = immediately and c:GetPreviousPosition() or POS_FACEUP
    local seq = immediately and c:GetPreviousSequence() or nil
    if not Dimension.Summon(mc, tp, tp, pos, seq) then return end

    -- set base atk/def
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterEffect(mc, ec1, true)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec1b:SetValue(def)
    Divine.RegisterEffect(mc, ec1b, true)

    -- unstoppable attack
    local ec2 = Effect.CreateEffect(c)
    ec2:SetDescription(aux.Stringid(id, 1))
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE +
                        EFFECT_FLAG_CLIENT_HINT)
    ec2:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    ec2:SetRange(LOCATION_MZONE)
    Divine.RegisterEffect(mc, ec2, true)
    local spnoattack = mc:GetCardEffect(EFFECT_CANNOT_ATTACK)
    if spnoattack then spnoattack:Reset() end

    if e:GetLabel() > 0 then
        mc:RegisterFlagEffect(Divine.DIVINE_EVOLUTION,
                              RESET_EVENT + RESETS_STANDARD,
                              EFFECT_FLAG_CLIENT_HINT, 1, 0, 666003)
    end
end
