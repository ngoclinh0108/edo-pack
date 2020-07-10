-- Ra the Sun Divine Sphere
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("proc_dimension.lua")
local s, id = GetID()

s.divine_hierarchy = 2
s.listed_names = {CARD_RA}

function s.initial_effect(c)
    Dimension.AddProcedure(c)
    Divine.AddProcedure(c, "nomi")

    -- seal form
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    Duel.RegisterEffect(e1, nil)

    -- attack limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(e2)

    -- cannot be targeted
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    -- battle indes & damage avoid
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetValue(function(e) return e:GetOwner():IsDefensePos() end)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    c:RegisterEffect(e4b)

    -- standard form
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetProperty(EFFECT_FLAG_BOTH_SIDE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.e1filter(c, mc)
    return c:IsCode(CARD_RA) and c:GetOwner() == mc:GetOwner()
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e1filter, 1, nil, e:GetOwner())
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()
    local mc = eg:Filter(s.e1filter, nil, c):GetFirst()
    if not mc then return end
    Duel.BreakEffect()

    Dimension.Change(c, mc, mc:GetControler(), mc:GetControler(),
                     mc:GetPosition())
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetOwner()
    local mc = c:GetMaterial():GetFirst()

    if chk == 0 then
        return mc and mc:GetOwner() == tp and
                   (c:IsControler(tp) or
                       Duel.GetLocationCount(tp, LOCATION_MZONE) > 0)
    end
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()
    if not c:IsControler(tp) and Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then
        return
    end

    local tc = Dimension.Dechange(c, tp, tp)

    local atk = 0
    local def = 0
    if tc:IsSummonType(SUMMON_TYPE_TRIBUTE) then
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
