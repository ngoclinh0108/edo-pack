-- Sun Divine Beast of Ra - Immortal Phoenix
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 10000080}

function s.initial_effect(c)
    s.divine_hierarchy = 2
    Dimension.AddProcedure(c)

    -- dimension change (special summon)
    Dimension.RegisterChange({
        handler = c,
        flag_id = id + 100000,
        event_code = EVENT_SPSUMMON_SUCCESS,
        filter = function(c, sc)
            return c:IsCode(CARD_RA) and c:GetOwner() == sc:GetOwner() and
                       c:IsPreviousLocation(LOCATION_GRAVE)
        end,
        custom_op = function(e, tp, mc)
            local c = e:GetHandler()
            Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 0))
            local op = Duel.SelectOption(tp, aux.Stringid(id, 1),
                                         aux.Stringid(id, 2))
            if op == 0 then return end

            local divine_evolution = Divine.IsDivineEvolution(mc)
            Dimension.Change(mc, c)
            if divine_evolution then Divine.DivineEvolution(c) end
        end
    })

    -- dimension change (self destroy)
    Dimension.RegisterChange({
        handler = c,
        flag_id = id + 200000,
        custom_reg = function(c, flag_id)
            local dms = Effect.CreateEffect(c)
            dms:SetType(EFFECT_TYPE_CONTINUOUS)
            dms:SetCode(EFFECT_DESTROY_REPLACE)
            dms:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
                local sc = e:GetHandler()
                local g = eg:Filter(s.dmsfilter, nil, sc:GetOwner())
                if chk == 0 then return #g > 0 end
                for tc in aux.Next(g) do
                    tc:RegisterFlagEffect(flag_id, 0, 0, 1)
                end
                return true
            end)
            dms:SetValue(function(e, c)
                return s.dmsfilter(c, e:GetHandler():GetOwner())
            end)
            Duel.RegisterEffect(dms, 0)
        end,
        custom_op = function(e, tp, mc)
            local c = e:GetHandler()
            local atk = mc:GetBaseAttack()
            local def = mc:GetBaseDefense()

            local divine_evolution = Divine.IsDivineEvolution(mc)
            Dimension.Change(mc, c)
            if divine_evolution then Divine.DivineEvolution(c) end

            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            ec1:SetRange(LOCATION_MZONE)
            ec1:SetCode(EFFECT_SET_BASE_ATTACK)
            ec1:SetValue(atk)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            Divine.RegisterRaEffect(c, ec1, true)
            local ec1b = ec1:Clone()
            ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
            ec1b:SetValue(def)
            Divine.RegisterRaEffect(c, ec1b, true)
        end
    })

    -- effects cannot be negated
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE)
    Divine.RegisterEffect(c, e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetCode(EFFECT_CANNOT_DISEFFECT)
    e1b:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    Divine.RegisterEffect(c, e1b)

    -- race
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_ADD_RACE)
    e2:SetValue(RACE_PYRO)
    Divine.RegisterEffect(c, e2)

    -- cannot switch control
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    Divine.RegisterEffect(c, e3)

    -- cannot be Tributed, or be used as a material
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_CANNOT_RELEASE)
    e4:SetTargetRange(0, 1)
    e4:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    Divine.RegisterEffect(c, e4)
    local e4b = Effect.CreateEffect(c)
    e4b:SetType(EFFECT_TYPE_SINGLE)
    e4b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e4b:SetValue(function(e, tc)
        return tc and tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    Divine.RegisterEffect(c, e4b)

    -- indes & no damage
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e5:SetValue(function(e, tc)
        if Divine.GetDivineHierarchy(tc) >=
            Divine.GetDivineHierarchy(e:GetHandler()) then return false end
        return true
    end)
    Divine.RegisterEffect(c, e5)
    local e5b = e5:Clone()
    e5b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    Divine.RegisterEffect(c, e5b)

    -- cannot attack
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_CANNOT_ATTACK)
    e6:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id) == 0 end)
    Divine.RegisterEffect(c, e6)

    -- immune
    local e7 = Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_SINGLE)
    e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCode(EFFECT_IMMUNE_EFFECT)
    e7:SetValue(function(e, te) return te:GetOwner() ~= e:GetOwner() end)
    Divine.RegisterEffect(c, e7)

    -- attack
    local e8 = Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id, 3))
    e8:SetCategory(CATEGORY_TOGRAVE)
    e8:SetType(EFFECT_TYPE_QUICK_O)
    e8:SetRange(LOCATION_MZONE)
    e8:SetCode(EVENT_FREE_CHAIN)
    e8:SetHintTiming(TIMING_END_PHASE)
    e8:SetCost(s.e8cost)
    e8:SetTarget(s.e8tg)
    e8:SetOperation(s.e8op)
    Divine.RegisterEffect(c, e8)

    -- return
    local e9 = Effect.CreateEffect(c)
    e9:SetDescription(aux.Stringid(id, 4))
    e9:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e9:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e9:SetRange(LOCATION_MZONE)
    e9:SetCode(EVENT_PHASE + PHASE_END)
    e9:SetCountLimit(1)
    e9:SetOperation(s.e9op)
    Divine.RegisterEffect(c, e9)
end

function s.dmsfilter(c, tp)
    local re = c:GetReasonEffect()
    if c:IsReason(REASON_REPLACE) then return false end
    return c:IsReason(REASON_EFFECT) and re and re:GetHandler() == c and
               c:IsControler(tp) and c:IsFaceup() and c:IsCode(CARD_RA)
end

function s.e8cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e8tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetFlagEffect(id) == 0 and
                   Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_MZONE,
                                               1, c)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, 0, LOCATION_MZONE)
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                             PHASE_END, 0, 1)
end

function s.e8op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTACK)
    local tc = Duel.SelectMatchingCard(tp, aux.TRUE, tp, 0, LOCATION_MZONE, 1,
                                       1, c):GetFirst()
    if not tc then return end

    Duel.ForceAttack(c, tc)
end

function s.e9op(e, tp, eg, ep, ev, re, r, rp)
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
