-- Ra the Sun Divine Immortal Phoenix
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("proc_dimension.lua")
local s, id = GetID()

s.divine_hierarchy = 2
s.listed_names = {CARD_RA, 10000080}

function s.initial_effect(c)
    Dimension.AddProcedure(c, s.dmsfilter)
    Divine.AddProcedure(c, "nomi")

    -- immune spell/trap
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, te)
        return te:GetOwnerPlayer() ~= e:GetOwnerPlayer() and
                   te:IsActiveType(TYPE_SPELL + TYPE_TRAP)
    end)
    c:RegisterEffect(e1)

    -- life point transfer
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- tribute for atk/def
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(s.e3cost)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- destroy
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- end phase
    local e5 = Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_TOGRAVE)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetCode(EVENT_ADJUST)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return Duel.GetCurrentPhase() == PHASE_END
    end)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.dmsfilter(c)
    return c:IsCode(CARD_RA) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and
               c:IsPreviousLocation(LOCATION_GRAVE)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLP(tp) > 100 end
    local lp = Duel.GetLP(tp)
    e:SetLabel(lp - 100)
    Duel.PayLPCost(tp, lp - 100)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetChainLimit(aux.FALSE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
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
    ec3:SetOperation(s.e2recoverop)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec3)
end

function s.e2recoverop(e, tp, eg, ep, ev, re, r, rp)
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

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
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

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
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

function s.e4filter(tc, e)
    local c = e:GetOwner()
    return not tc.divine_hierarchy or tc.divine_hierarchy <= c.divine_hierarchy
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetOwner()
    if chk == 0 then
        return Duel.CheckLPCost(tp, 1000) and c:GetFlagEffect(id) == 0
    end

    Duel.PayLPCost(tp, 1000)
    c:RegisterFlagEffect(id, RESET_CHAIN, 0, 1)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetOwner()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_MZONE,
                                           LOCATION_MZONE, 1, c, e)
    end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local tc = Duel.SelectMatchingCard(tp, s.e4filter, tp, LOCATION_MZONE,
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

function s.e5filter(c) return c:IsCode(10000080) and c:IsType(Dimension.TYPE) end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()
    Duel.Hint(HINT_CARD, tp, id)
    Duel.HintSelection(Group.FromCards(c))

    local b1 = Dimension.Zones(c:GetOwner()):IsExists(s.e5filter, 1, nil)
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
        local sc = Dimension.Zones(c:GetOwner()):Filter(s.e5filter, nil)
                       :GetFirst()
        Dimension.Change(sc, c, tp, tp, POS_FACEUP_DEFENSE, c:GetMaterial())
    else
        Duel.SendtoGrave(c, REASON_EFFECT)
    end
end
