-- Ra the Sun Divine Immortal Phoenix
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("proc_dimension.lua")
local s, id = GetID()

s.divine_hierarchy = 2
s.listed_names = {CARD_RA}

function s.initial_effect(c)
    Dimension.AddProcedure(c, s.transfilter)
    Divine.AddProcedure(c, 'self', false, RACE_WINGEDBEAST + RACE_PYRO)

    -- indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_INDESTRUCTABLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- immune & unstoppable attack
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(function(e, te)
        return e:GetOwnerPlayer() ~= te:GetOwnerPlayer() and
                   te:IsActiveType(TYPE_SPELL + TYPE_TRAP)
    end)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    e2b:SetValue(1)
    c:RegisterEffect(e2b)

    -- battle damage avoid
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- life point transfer
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- tribute for atk/def
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCost(s.e5cost)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- destroy
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 3))
    e6:SetCategory(CATEGORY_DESTROY)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e6:SetCode(EVENT_FREE_CHAIN)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCost(s.e6cost)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)

    -- to grave
    local togy = Effect.CreateEffect(c)
    togy:SetDescription(666000)
    togy:SetCategory(CATEGORY_TOGRAVE)
    togy:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    togy:SetCode(EVENT_PHASE + PHASE_END)
    togy:SetRange(LOCATION_MZONE)
    togy:SetCountLimit(1)
    togy:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Duel.SendtoGrave(e:GetHandler(), REASON_EFFECT)
    end)
    c:RegisterEffect(togy)
end

function s.transfilter(c)
    return c:IsCode(CARD_RA) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and
               c:IsPreviousLocation(LOCATION_GRAVE)
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLP(tp) > 100 end

    local lp = Duel.GetLP(tp)
    e:SetLabel(lp - 100)
    Duel.PayLPCost(tp, lp - 100)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetChainLimit(aux.FALSE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(c:GetBaseAttack() + e:GetLabel())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)

    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec2:SetValue(c:GetBaseDefense() + e:GetLabel())
    c:RegisterEffect(ec2)

    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec3:SetCode(EVENT_RECOVER)
    ec3:SetRange(LOCATION_MZONE)
    ec3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return ep == tp end)
    ec3:SetOperation(s.e4recoverop)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec3)
end

function s.e4recoverop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    if c:IsFacedown() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(c:GetBaseAttack() + ev)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)

    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec2:SetValue(c:GetBaseDefense() + ev)
    c:RegisterEffect(ec2)

    Duel.SetLP(tp, 100, REASON_EFFECT)
end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, Card.IsFaceup, 1, false, nil, c)
    end

    local g = Duel.SelectReleaseGroupCost(tp, Card.IsFaceup, 1, 99, false, nil,
                                          c)
    Duel.Release(g, REASON_COST)

    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
    end
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = e:GetLabelObject()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
    if not g then return end

    local atk = 0
    local def = 0
    for tc in aux.Next(g) do
        if tc:GetBaseAttack() > 0 then atk = atk + tc:GetBaseAttack() end
        if tc:GetBaseDefense() > 0 then def = def + tc:GetBaseDefense() end
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(c:GetBaseAttack() + atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)
    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec2:SetValue(c:GetBaseDefense() + def)
    c:RegisterEffect(ec2)

    g:DeleteGroup()
end

function s.e6filter(tc, e)
    local c = e:GetHandler()
    return not tc.divine_hierarchy or tc.divine_hierarchy <= c.divine_hierarchy
end

function s.e6cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.CheckLPCost(tp, 1000) and c:GetFlagEffect(id) == 0
    end

    Duel.PayLPCost(tp, 1000)
    c:RegisterFlagEffect(id, RESET_CHAIN, 0, 1)
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e6filter, tp, LOCATION_MZONE,
                                           LOCATION_MZONE, 1, c, e)
    end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, 0)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local tc = Duel.SelectMatchingCard(tp, s.e6filter, tp, LOCATION_MZONE,
                                       LOCATION_MZONE, 1, 1, c, e):GetFirst()
    if not tc then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_CHAIN)
    tc:RegisterEffect(ec1, true)
    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(ec2, true)
    local ec3 = ec1:Clone()
    ec3:SetCode(EFFECT_IMMUNE_EFFECT)
    ec3:SetRange(LOCATION_MZONE)
    ec3:SetValue(function(e, te) return te:GetOwner() ~= e:GetOwner() end)
    tc:RegisterEffect(ec3, true)
    Duel.AdjustInstantly(c)

    Duel.Destroy(tc, REASON_EFFECT)
end
