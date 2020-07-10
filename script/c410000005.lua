-- Ra the Sun Divine Immortal Phoenix
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("proc_dimension.lua")
local s, id = GetID()

s.divine_hierarchy = 2
s.listed_names = {CARD_RA, 10000080}

function s.initial_effect(c)
    Dimension.AddProcedure(c, s.dmsfilter)
    Divine.AddProcedure(c, "nomi")

    -- race
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(RACE_PYRO+RACE_WINGEDBEAST)
    c:RegisterEffect(e1)
    
    -- immune spell/trap
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(function(e, te)
        return te:GetOwnerPlayer() ~= e:GetOwnerPlayer() and
                   te:IsActiveType(TYPE_SPELL + TYPE_TRAP)
    end)
    c:RegisterEffect(e2)

    -- life point transfer
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- tribute for atk/def
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCost(s.e4cost)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- destroy
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCost(s.e5cost)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- end phase
    local e6 = Effect.CreateEffect(c)
    e6:SetCategory(CATEGORY_TOGRAVE)
    e6:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e6:SetCode(EVENT_ADJUST)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return Duel.GetCurrentPhase() == PHASE_END
    end)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
end

function s.dmsfilter(c)
    return c:IsCode(CARD_RA) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and
               c:IsPreviousLocation(LOCATION_GRAVE)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLP(tp) > 100 end
    local lp = Duel.GetLP(tp)
    e:SetLabel(lp - 100)
    Duel.PayLPCost(tp, lp - 100)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetChainLimit(aux.FALSE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()
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
    ec3:SetOperation(s.e3recoverop)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec3)
end

function s.e3recoverop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()
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

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetOwner()
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, nil, 1, false, nil, c)
    end

    local g = Duel.SelectReleaseGroupCost(tp, nil, 1, 99, false, nil, c)
    Duel.Release(g, REASON_COST)
    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
    end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local g = e:GetLabelObject()
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

function s.e5filter(tc, e)
    local c = e:GetOwner()
    return not tc.divine_hierarchy or tc.divine_hierarchy <= c.divine_hierarchy
end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetOwner()
    if chk == 0 then
        return Duel.CheckLPCost(tp, 1000) and c:GetFlagEffect(id) == 0
    end

    Duel.PayLPCost(tp, 1000)
    c:RegisterFlagEffect(id, RESET_CHAIN, 0, 1)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetOwner()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e5filter, tp, LOCATION_MZONE,
                                           LOCATION_MZONE, 1, c, e)
    end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, 0)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local tc = Duel.SelectMatchingCard(tp, s.e5filter, tp, LOCATION_MZONE,
                                       LOCATION_MZONE, 1, 1, c, e):GetFirst()
    if not tc then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_CHAIN)
    tc:RegisterEffect(ec1, true)
    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(ec2, true)
    local ec3 = ec1:Clone()
    ec3:SetCode(EFFECT_IMMUNE_EFFECT)
    ec3:SetValue(function(e, te) return te:GetOwner() ~= e:GetOwner() end)
    tc:RegisterEffect(ec3, true)
    Duel.AdjustInstantly(c)

    Duel.Destroy(tc, REASON_EFFECT)
end

function s.e6filter(c) return c:IsCode(10000080) and c:IsType(Dimension.TYPE) end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()
    Duel.Hint(HINT_CARD, tp, id)
    Duel.HintSelection(Group.FromCards(c))

    local b1 = Dimension.Zones(c:GetOwner()):IsExists(s.e6filter, 1, nil)
    local b2 = c:IsAbleToGrave()

    local opt
    if b1 and b2 then
        opt = Duel.SelectOption(tp, aux.Stringid(id, 3), aux.Stringid(id, 4))
    elseif b1 then
        opt = Duel.SelectOption(tp, aux.Stringid(id, 3))
    else
        opt = Duel.SelectOption(tp, aux.Stringid(id, 4)) + 1
    end

    if opt == 0 then
        local sc = Dimension.Zones(c:GetOwner()):Filter(s.e6filter, nil)
                       :GetFirst()
        Dimension.Change(sc, c, tp, tp, POS_FACEUP_DEFENSE, c:GetMaterial())
    else
        Duel.SendtoGrave(c, REASON_EFFECT)
    end
end
