-- Sun Divine Beast of Ra - Immortal Phoenix
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 10000080, 95286165}

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 2, false, false)
    Divine.RegisterRaDefuse(s, c)
    Dimension.AddProcedure(c)

    -- dimension change
    Dimension.RegisterChange(s, c, function(_, tp)
        local dmsreg = Effect.CreateEffect(c)
        dmsreg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        dmsreg:SetCode(EVENT_SPSUMMON_SUCCESS)
        dmsreg:SetOperation(s.dmsregop)
        Duel.RegisterEffect(dmsreg, tp)
        local dms = Effect.CreateEffect(c)
        dms:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        dms:SetCode(EVENT_ADJUST)
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
    e1:SetValue(RACE_PYRO)
    Divine.RegisterEffect(c, e1)

    -- indes & no damage
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(function(e, tc)
        local c = e:GetHandler()
        if Divine.GetDivineHierarchy(tc) >= Divine.GetDivineHierarchy(c) then
            return false
        end

        c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                 PHASE_END, 0, 1)
        return true
    end)
    Divine.RegisterEffect(c, e3)
    local e3b = Effect.CreateEffect(c)
    e3b:SetType(EFFECT_TYPE_SINGLE)
    e3b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e3b:SetValue(function(e)
        return e:GetHandler():GetFlagEffect(id) == 0 and 1 or 0
    end)
    c:RegisterEffect(e3b)

    -- return
    local e9 = Effect.CreateEffect(c)
    e9:SetDescription(aux.Stringid(id, 3))
    e9:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e9:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e9:SetCode(EVENT_PHASE + PHASE_END)
    e9:SetRange(LOCATION_MZONE)
    e9:SetCountLimit(1)
    e9:SetOperation(s.e9op)
    Divine.RegisterEffect(c, e9)
end

function s.dmsfilter(c, check_flag)
    if check_flag and c:GetFlagEffect(id) == 0 then return false end
    return Dimension.CanBeDimensionMaterial(c) and c:IsCode(CARD_RA) and
               c:IsSummonType(SUMMON_TYPE_SPECIAL) and
               c:IsSummonLocation(LOCATION_GRAVE) and c:IsAttackPos()
end

function s.dmsregop(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(s.dmsfilter, nil, false)
    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                  PHASE_END, 0, 1)
    end
end

function s.dmscon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.dmsfilter, tp, LOCATION_MZONE, 0, 1,
                                       nil, true)
end

function s.dmsop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local mc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.dmsfilter, tp,
                                          LOCATION_MZONE, 0, 1, 1, nil, true):GetFirst()
    if not mc then return end
    mc:ResetFlagEffect(id)

    local opt = {}
    local sel = {}
    table.insert(opt, aux.Stringid(id, 0))
    table.insert(sel, 1)
    if Duel.GetLP(tp) > 100 then
        table.insert(opt, aux.Stringid(id, 1))
        table.insert(sel, 2)
    end
    if Dimension.CanBeDimensionChanged(c) then
        table.insert(opt, aux.Stringid(id, 2))
        table.insert(sel, 3)
    end

    Duel.HintSelection(Group.FromCards(mc))
    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]
    if op == 1 then
        return
    elseif op == 2 then
        s.granteffect(e, tp, mc)
    else
        local divine_evolution = Divine.IsDivineEvolution(mc)
        Dimension.Change(mc, c, tp, tp)
        if divine_evolution then Divine.DivineEvolution(c) end
    end
end

function s.granteffect(e, tp, tc)
    local c = e:GetHandler()
    Utility.HintCard(tc)

    -- life point transfer
    Divine.RegisterRaFuse(c, tc, true)
    local paidlp = Duel.GetLP(tp) - 100
    Duel.PayLPCost(tp, paidlp)
    local label = {paidlp, paidlp}
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 1))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(id)
    ec1:SetLabelObject(label)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterEffect(tc, ec1, true)

    -- unstoppable attack
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
    ec2:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    ec2:SetRange(LOCATION_MZONE)
    ec2:SetCondition(function(e) return e:GetHandler():IsHasEffect(id) end)
    Divine.RegisterEffect(tc, ec2, true)
    local spnoattack = tc:GetCardEffect(EFFECT_CANNOT_ATTACK)
    if spnoattack then spnoattack:Reset() end

    -- tribute monsters to up atk
    local ec3 = Effect.CreateEffect(c)
    ec3:SetDescription(aux.Stringid(id, 4))
    ec3:SetCategory(CATEGORY_ATKCHANGE)
    ec3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    ec3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec3:SetCode(EVENT_ATTACK_ANNOUNCE)
    ec3:SetRange(LOCATION_MZONE)
    ec3:SetCountLimit(1)
    ec3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return Duel.GetAttacker() == c or
                   (Duel.GetAttackTarget() and Duel.GetAttackTarget() == c) and
                   e:GetHandler():IsHasEffect(id)
    end)
    ec3:SetCost(function(e, tp, eg, ep, ev, re, r, rp, chk)
        local c = e:GetHandler()
        if chk == 0 then
            return Duel.CheckReleaseGroupCost(tp, Card.IsFaceup, 1, false, nil,
                                              c)
        end

        local g = Duel.SelectReleaseGroupCost(tp, Card.IsFaceup, 1, 99, false,
                                              nil, c)
        e:SetLabel(g:GetSum(Card.GetBaseAttack))
        Duel.Release(g, REASON_COST)
    end)
    ec3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if c:IsFacedown() or not c:IsRelateToEffect(e) or not c:IsHasEffect(id) then
            return
        end

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(e:GetLabel())
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        Divine.RegisterEffect(c, ec1)
    end)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterEffect(tc, ec3, true)

    -- after damage calculation
    local ec4 = Effect.CreateEffect(c)
    ec4:SetCategory(CATEGORY_TOGRAVE)
    ec4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    ec4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec4:SetCode(EVENT_BATTLED)
    ec4:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return Duel.GetAttacker() == e:GetHandler() and
                   e:GetHandler():IsHasEffect(id)
    end)
    ec4:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsHasEffect(id) then return end

        Utility.HintCard(c)
        local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
        Duel.SendtoGrave(g, REASON_EFFECT)
    end)
    ec4:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterEffect(tc, ec4, true)
end

function s.e9op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.HintSelection(Group.FromCards(c))

    local tc = Dimension.Zones(c:GetOwner()):Filter(function(c)
        return c:IsCode(10000080) and c:IsType(Dimension.TYPE)
    end, nil):GetFirst()

    if tc then
        local divine_evolution = Divine.IsDivineEvolution(c)
        Dimension.Change(c, tc, tp, tp, c:GetMaterial())
        if divine_evolution then Divine.DivineEvolution(tc) end
    else
        Duel.SendtoGrave(c, REASON_EFFECT)
    end
end
