-- Winged Divine Beast of Ra - Sphere Mode
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {CARD_RA}

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 2, false, false)
    Dimension.AddProcedure(c)

    -- startup
    Dimension.RegisterChange(s, c, function(_, tp)
        local dms = Effect.CreateEffect(c)
        dms:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        dms:SetCode(EVENT_SUMMON_SUCCESS)
        dms:SetCondition(Dimension.Condition(s.dmscon))
        dms:SetOperation(s.dmsop)
        Duel.RegisterEffect(dms, tp)
    end)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_MACHINE)
    c:RegisterEffect(e1)

    -- cannot attack
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(e2)

    -- cannot be target
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(1)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    c:RegisterEffect(e3b)

    -- summon ra
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
    c:RegisterEffect(e4)
end

function s.dmsfilter(c)
    return Dimension.CanBeDimensionMaterial(c) and c:IsCode(CARD_RA)
end

function s.dmscon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.dmsfilter, 1, nil)
end

function s.dmsop(e, tp, eg, ep, ev, re, r, rp)
    Duel.BreakEffect()

    local c = e:GetHandler()
    local mc =
        Utility.GroupSelect(eg:Filter(s.dmsfilter, nil), rp, 1, 1, 666100):GetFirst()
    if not mc then return end

    local divine_evolution = mc:GetFlagEffect(Divine.DIVINE_EVOLUTION) > 0
    Dimension.Change(c, mc, rp, rp, mc:GetPosition())

    if divine_evolution then
        c:RegisterFlagEffect(Divine.DIVINE_EVOLUTION,
                             RESET_EVENT + RESETS_STANDARD,
                             EFFECT_FLAG_CLIENT_HINT, 1, 0, 666002)
    end
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
                   Dimension.CanBeDimensionSummoned(mc, e, tp, true, false,
                                                    POS_FACEUP)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, mc, 1, 0, 0)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local mc = c:GetMaterial():GetFirst()
    if not mc then return end
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then
        Duel.SendtoGrave(mc, REASON_RULE)
        return
    end

    local atk = 0
    local def = 0
    if mc:IsSummonType(SUMMON_TYPE_TRIBUTE) then
        local mg = mc:GetMaterial()
        for mc in aux.Next(mg) do
            if mc:GetBaseAttack() > 0 then
                atk = atk + mc:GetBaseAttack()
            end
            if mc:GetBaseDefense() > 0 then
                def = def + mc:GetBaseDefense()
            end
        end
    end
    if atk == 0 and def == 0 then
        atk = 4000
        def = 4000
    end

    Dimension.ZonesRemoveCard(mc)
    if Duel.SpecialSummonStep(mc, 0, tp, tp, true, false, POS_FACEUP) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
        ec1:SetCode(EFFECT_SET_BASE_ATTACK)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetValue(atk)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        mc:RegisterEffect(ec1, true)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
        ec1b:SetValue(def)
        mc:RegisterEffect(ec1b, true)

        local ec2 = Effect.CreateEffect(c)
        ec2:SetDescription(aux.Stringid(id, 1))
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE +
                            EFFECT_FLAG_CLIENT_HINT)
        ec2:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
        ec2:SetRange(LOCATION_MZONE)
        mc:RegisterEffect(ec2, true)

        if e:GetLabel() > 0 then
            mc:RegisterFlagEffect(Divine.DIVINE_EVOLUTION,
                                  RESET_EVENT + RESETS_STANDARD,
                                  EFFECT_FLAG_CLIENT_HINT, 1, 0, 666002)
        end
    end
    Duel.SpecialSummonComplete()

    local spnoattack = mc:GetCardEffect(EFFECT_CANNOT_ATTACK)
    if spnoattack then spnoattack:Reset() end
end
