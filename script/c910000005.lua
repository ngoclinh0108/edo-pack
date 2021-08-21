-- Winged Divine Beast of Ra - Immortal Phoenix
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 10000080}

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 2, false, false)
    Dimension.AddProcedure(c)

    -- startup
    Dimension.RegisterChange(c, function(e, tp)
        local dms = Effect.CreateEffect(c)
        dms:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        dms:SetCode(EVENT_SPSUMMON_SUCCESS)
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
    e1:SetValue(RACE_PYRO)
    c:RegisterEffect(e1)

    -- position
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    c:RegisterEffect(e2)

    -- battle & avoid damage
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(function(e, tc)
        return Divine.GetDivineHierarchy(tc) <
                   Divine.GetDivineHierarchy(e:GetHandler())
    end)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    c:RegisterEffect(e3b)

    -- unstoppable attack
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    e4:SetRange(LOCATION_MZONE)
    c:RegisterEffect(e4)

    -- tribute for atk/def
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetCost(s.e5cost)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- life point transfer
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 1))
    e7:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e7:SetType(EFFECT_TYPE_QUICK_O)
    e7:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e7:SetCode(EVENT_FREE_CHAIN)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCountLimit(1)
    e7:SetCost(s.e7cost)
    e7:SetTarget(s.e7tg)
    e7:SetOperation(s.e7op)
    c:RegisterEffect(e7)

    -- destroy
    local e8 = Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id, 2))
    e8:SetCategory(CATEGORY_DESTROY)
    e8:SetType(EFFECT_TYPE_QUICK_O)
    e8:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e8:SetCode(EVENT_FREE_CHAIN)
    e8:SetRange(LOCATION_MZONE)
    e8:SetCost(s.e8cost)
    e8:SetTarget(s.e8tg)
    e8:SetOperation(s.e8op)
    c:RegisterEffect(e8)

    -- end phase
    local e9 = Effect.CreateEffect(c)
    e9:SetDescription(aux.Stringid(id, 3))
    e9:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e9:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e9:SetCode(EVENT_PHASE + PHASE_END)
    e9:SetRange(LOCATION_MZONE)
    e9:SetOperation(s.e9op)
    c:RegisterEffect(e9)
end

function s.dmsfilter(c, tp)
    return Dimension.CanBeDimensionMaterial(c) and c:GetControler() == tp and
               c:IsCode(CARD_RA) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and
               c:IsSummonLocation(LOCATION_GRAVE)
end

function s.dmscon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.dmsfilter, 1, nil, e:GetOwnerPlayer())
end

function s.dmsop(e, tp, eg, ep, ev, re, r, rp)
    Duel.BreakEffect()

    local c = e:GetHandler()
    local mc = Utility.GroupSelect(eg:Filter(s.dmsfilter, nil,
                                             e:GetOwnerPlayer()), rp, 1, 1,
                                   666100):GetFirst()
    if not mc then return end

    local divine_evolution = mc:GetFlagEffect(Divine.DIVINE_EVOLUTION) > 0
    Dimension.Change(c, mc, rp, rp, mc:GetPosition())
    if divine_evolution then
        c:RegisterFlagEffect(Divine.DIVINE_EVOLUTION,
                             RESET_EVENT + RESETS_STANDARD,
                             EFFECT_FLAG_CLIENT_HINT, 1, 0, 666002)
    end
end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
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

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
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

function s.e7cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLP(tp) > 1 end
    local lp = Duel.GetLP(tp)
    Duel.PayLPCost(tp, lp - 1)
    e:SetLabel(lp - 1)
end

function s.e7tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetChainLimit(aux.FALSE)
end

function s.e7op(e, tp, eg, ep, ev, re, r, rp)
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
    ec3:SetDescription(aux.Stringid(id, 1))
    ec3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec3:SetCode(EVENT_RECOVER)
    ec3:SetRange(LOCATION_MZONE)
    ec3:SetCondition(function(e, tp, eg, ep) return ep == tp end)
    ec3:SetOperation(s.e7recoverop)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec3)
end

function s.e7recoverop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsLocation(LOCATION_MZONE) or c:IsFacedown() then return end

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

    Duel.SetLP(tp, 1, REASON_EFFECT)
end

function s.e8filter(c, sc)
    return Divine.GetDivineHierarchy(c) <= Divine.GetDivineHierarchy(sc)
end

function s.e8cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e8tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetFlagEffect(id) == 0 and
                   Duel.IsExistingMatchingCard(s.e8filter, tp, LOCATION_MZONE,
                                               LOCATION_MZONE, 1, c, c)
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, 0)
    c:RegisterFlagEffect(id, RESET_CHAIN, 0, 1)
end

function s.e8op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local tc = Duel.SelectMatchingCard(tp, s.e8filter, tp, LOCATION_MZONE,
                                       LOCATION_MZONE, 1, 1, c, c):GetFirst()
    if not tc then return end
    Duel.HintSelection(Group.FromCards(tc))

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
    ec3:SetValue(function(e, te) return te:GetHandler() ~= e:GetHandler() end)
    tc:RegisterEffect(ec3, true)
    Duel.AdjustInstantly(c)

    Duel.Destroy(tc, REASON_EFFECT)
end

function s.e9filter(c) return c:IsCode(10000080) and c:IsType(Dimension.TYPE) end

function s.e9op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.HintSelection(Group.FromCards(c))

    local sg = Dimension.Zones(c:GetOwner()):Filter(s.e9filter, nil)
    if #sg > 0 then
        local sc = sg:GetFirst()
        local divine_evolution = c:GetFlagEffect(Divine.DIVINE_EVOLUTION) > 0
        Dimension.Change(sc, c, tp, tp, POS_FACEUP_DEFENSE, c:GetMaterial())
        if divine_evolution then
            sc:RegisterFlagEffect(Divine.DIVINE_EVOLUTION,
                                  RESET_EVENT + RESETS_STANDARD,
                                  EFFECT_FLAG_CLIENT_HINT, 1, 0, 666002)
        end
    else
        Duel.SendtoGrave(c, REASON_EFFECT)
    end
end
