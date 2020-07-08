-- Ra the Sun Divine Sphere
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("proc_dimension.lua")
local s, id = GetID()

s.divine_hierarchy = 2
s.listed_names = {CARD_RA}

function s.initial_effect(c)
    Dimension.AddProcedure(c)
    Divine.AddProcedure(c, 'nomi', false)

    -- seal ra
    local dms = Effect.CreateEffect(c)
    dms:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    dms:SetCode(EVENT_SUMMON_SUCCESS)
    dms:SetCondition(s.dmscon)
    dms:SetOperation(s.dmsop)
    Duel.RegisterEffect(dms, nil)

    -- attack limit
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(e1)

    -- battle indes
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(2)
    e2:SetValue(function(e, re, r, rp) return (r & REASON_BATTLE) ~= 0 end)
    c:RegisterEffect(e2)

    -- battle damage avoid
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- standard form
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_BOTH_SIDE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.dmsfilter(c, mc)
    return c:IsCode(CARD_RA) and c:GetOwner() == mc:GetOwner()
end

function s.dmscon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.dmsfilter, 1, nil, e:GetOwner())
end

function s.dmsop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()
    local mc = eg:Filter(s.dmsfilter, nil, c):GetFirst()
    if not mc then return end
    Duel.BreakEffect()

    Dimension.Change(c, mc, mc:GetControler(), mc:GetControler(),
                     mc:GetPosition())
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetOwner()
    local mc = c:GetMaterial():GetFirst()

    if chk == 0 then
        return tp == mc:GetOwner() and
                   (c:IsControler(tp) or
                       Duel.GetLocationCount(tp, LOCATION_MZONE) > 0)
    end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
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
