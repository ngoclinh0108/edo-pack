-- Ra the Sun Divine Sphere
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("proc_dimension.lua")
local s, id = GetID()

s.listed_names = {CARD_RA}

function s.initial_effect(c)
    Dimension.AddProcedure(c)
    Divine.DivineImmunity(s, c, 2, "nomi")

    -- startup
    Dimension.RegisterEffect(c, function(e, tp)
        local dms = Effect.CreateEffect(c)
        dms:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        dms:SetCode(EVENT_SUMMON_SUCCESS)
        dms:SetCondition(s.dmscon)
        dms:SetOperation(s.dmsop)
        Duel.RegisterEffect(dms, tp)
    end)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_PYRO + RACE_WINGEDBEAST)
    c:RegisterEffect(e1)

    -- attack limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(e2)

    -- cannot be targeted
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- battle indes & damage avoid
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetValue(function(e) return e:GetHandler():IsDefensePos() end)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    c:RegisterEffect(e4b)

    -- standard form
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetProperty(EFFECT_FLAG_BOTH_SIDE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetCost(s.e5cost)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.dmsfilter(c, dc)
    return c:GetOwner() == dc:GetOwner() and c:IsCode(CARD_RA)
end

function s.dmscon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.dmsfilter, 1, nil, e:GetHandler())
end

function s.dmsop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local mc = eg:Filter(s.dmsfilter, nil, c):GetFirst()
    if not mc then return end
    Duel.BreakEffect()

    Dimension.Change(c, mc, mc:GetControler(), mc:GetControler(),
                     mc:GetPosition())
end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local mc = c:GetMaterial():GetFirst()

    if chk == 0 then
        return mc and mc:GetOwner() == tp and
                   (c:IsControler(tp) or
                       Duel.GetLocationCount(tp, LOCATION_MZONE) > 0)
    end

    Dimension.SendToDimension(c, REASON_COST)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local mc = c:GetMaterial():GetFirst()

    if chk == 0 then return mc:IsCanBeSpecialSummoned(e, 0, tp, true, false) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, mc, 1, 0, 0)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetMaterial():GetFirst()
    if not tc then return end
    if not c:IsControler(tp) and Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then
        Duel.SendtoGrave(tc, REASON_RULE)
        return
    end

    local is_tribute_summon = tc:IsSummonType(SUMMON_TYPE_TRIBUTE)
    Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP)
    Dimension.Zones(tc:GetOwner()):RemoveCard(tc)
    Duel.BreakEffect()

    local atk = 0
    local def = 0
    if is_tribute_summon then
        local mg = tc:GetMaterial()
        for mc in aux.Next(mg) do
            if mc:GetBaseAttack() > 0 then
                atk = atk + mc:GetBaseAttack()
            end
            if mc:GetBaseDefense() > 0 then
                def = def + mc:GetBaseDefense()
            end
        end
    end
    if atk < 4000 then atk = 4000 end
    if def < 4000 then def = 4000 end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE - RESET_TOFIELD)
    tc:RegisterEffect(ec1)
    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec2:SetValue(def)
    tc:RegisterEffect(ec2)
end
