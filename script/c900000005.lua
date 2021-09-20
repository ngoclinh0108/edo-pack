-- Sun Divine Beast of Ra - Immortal Phoenix
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 10000080}

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 2, false, false)
    Dimension.AddProcedure(c)

    -- dimension change
    Dimension.RegisterChange({
        handler = c,
        custom_reg = function(c, flag_id)
            local dms = Effect.CreateEffect(c)
            dms:SetType(EFFECT_TYPE_CONTINUOUS)
            dms:SetCode(EFFECT_DESTROY_REPLACE)
            dms:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
                local g = eg:Filter(s.dmsfilter, nil, e:GetOwnerPlayer())
                if chk == 0 then return #g > 0 end
                for tc in aux.Next(g) do
                    tc:RegisterFlagEffect(flag_id, 0, 0, 1)
                end
                return true
            end)
            dms:SetValue(function(e, c)
                return s.dmsfilter(c, e:GetOwnerPlayer())
            end)
            Duel.RegisterEffect(dms, 0)
        end,
        custom_op = function(e, c, mc)
            local divine_evolution = Divine.IsDivineEvolution(mc)
            Dimension.Change(mc, c)
            if divine_evolution then Divine.DivineEvolution(c) end
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            ec1:SetCode(EFFECT_SET_BASE_ATTACK)
            ec1:SetRange(LOCATION_MZONE)
            ec1:SetValue(4000)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            Divine.RegisterRaEffect(c, ec1, true)
            local ec1b = ec1:Clone()
            ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
            Divine.RegisterRaEffect(c, ec1b, true)
        end
    })

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_PYRO)
    Divine.RegisterEffect(c, e1)

    -- indes & no damage
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(function(e, tc)
        if Divine.GetDivineHierarchy(tc) >=
            Divine.GetDivineHierarchy(e:GetHandler()) then return false end
        c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                 PHASE_END, 0, 1)
        return true
    end)
    Divine.RegisterEffect(c, e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_SINGLE)
    e2b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e2b:SetValue(function(e)
        return e:GetHandler():GetFlagEffect(id) == 0 and 1 or 0
    end)
    Divine.RegisterEffect(c, e2b)

    -- unstoppable attack
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    e3:SetRange(LOCATION_MZONE)
    Divine.RegisterEffect(c, e3)

    -- to grave
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetHintTiming(TIMING_END_PHASE)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    Divine.RegisterEffect(c, e4)

    -- return
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetCode(EVENT_PHASE + PHASE_END)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetOperation(s.e5op)
    Divine.RegisterEffect(c, e5)
end

function s.dmsfilter(c, tp)
    local re = c:GetReasonEffect()
    return c:IsControler(tp) and c:IsReason(REASON_EFFECT) and
               not c:IsReason(REASON_REPLACE) and re and re:GetHandler() == c and
               c:IsFaceup() and c:IsCode(CARD_RA)
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetFlagEffect(id + 100000) == 0 and
                   Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_MZONE,
                                               LOCATION_MZONE, 1, c)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_MZONE,
                                      LOCATION_MZONE, 1, 1, c)
    Duel.SetTargetCard(g)

    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, #g, 0, 0)
    c:RegisterFlagEffect(id + 100000, RESET_CHAIN, 0, 1)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_CHAIN)
    tc:RegisterEffect(ec1, true)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(ec1b, true)
    local ec1c = ec1:Clone()
    ec1c:SetCode(EFFECT_IMMUNE_EFFECT)
    ec1c:SetValue(function(e, te) return te:GetHandler() == e:GetHandler() end)
    tc:RegisterEffect(ec1c, true)
    Duel.AdjustInstantly(tc)
    Duel.SendtoGrave(tc, REASON_EFFECT)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.HintSelection(Group.FromCards(c))

    local tc = Dimension.Zones(c:GetOwner()):Filter(function(c)
        return c:IsCode(10000080) and c:IsType(Dimension.TYPE)
    end, nil):GetFirst()

    if tc then
        local divine_evolution = Divine.IsDivineEvolution(c)
        Dimension.Change(c, tc, c:GetMaterial())
        if divine_evolution then Divine.DivineEvolution(tc) end
    else
        Duel.SendtoGrave(c, REASON_EFFECT)
    end
end
