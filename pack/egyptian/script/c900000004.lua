-- Sun Divine Dragon of Ra - Sphere Mode
Duel.LoadScript("util.lua")
Duel.LoadScript("util_egyptian.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 78665705}

function s.initial_effect(c)
    Dimension.AddProcedure(c)
    Divine.DivineHierarchy(s, c, 2)

    -- dimension change
    Dimension.RegisterChange({
        handler = c,
        event_code = EVENT_SUMMON_SUCCESS,
        filter = function(c, sc)
            return c:IsCode(CARD_RA) and c:GetOwner() == sc:GetOwner()
        end,
        custom_op = function(e, tp, mc)
            local c = e:GetHandler()

            if mc:IsControler(tp) then
                Utility.HintCard(c)
                s.battlemode(c, mc)
            else
                local divine_evolution = Divine.IsDivineEvolution(mc)
                Dimension.Change(mc, c)
                if divine_evolution then
                    Divine.DivineEvolution(c)
                end
            end
        end
    })

    -- summon ra to opponent's field
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_SPSUM_PARAM)
    e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
    e1:SetTargetRange(POS_FACEUP_ATTACK, 1)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    e1:SetValue(SUMMON_TYPE_TRIBUTE)
    local e1grant = Effect.CreateEffect(c)
    e1grant:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1grant:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1grant:SetCode(EVENT_STARTUP)
    e1grant:SetRange(LOCATION_ALL)
    e1grant:SetCountLimit(1, id)
    e1grant:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local g = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, CARD_RA)
        for tc in aux.Next(g) do
            local eff = tc:GetCardEffect(EFFECT_LIMIT_SUMMON_PROC)
            eff:SetDescription(aux.Stringid(id, 0))
        end

        local grant = Effect.CreateEffect(c)
        grant:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
        grant:SetTargetRange(LOCATION_HAND, 0)
        grant:SetLabelObject(e1)
        grant:SetCondition(function(e)
            return Dimension.IsInDimensionZone(e:GetHandler())
        end)
        grant:SetTarget(aux.TargetBoolFunction(Card.IsCode, CARD_RA))
        Duel.RegisterEffect(grant, tp)
        c:IsHasEffect(id)
    end)
    c:RegisterEffect(e1grant)

    -- cannot switch control
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    e2:SetRange(LOCATION_MZONE)
    c:RegisterEffect(e2)

    -- cannot be Tributed, or be used as a material
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_UNRELEASABLE_SUM)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(1)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(e3b)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    c:RegisterEffect(e3b)

    -- immune
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EFFECT_IMMUNE_EFFECT)
    e4:SetRange(LOCATION_MZONE)
    e4:SetValue(function(e, te)
        local c = e:GetHandler()
        local tc = te:GetHandler()
        return c ~= tc and Divine.GetDivineHierarchy(tc) <= Divine.GetDivineHierarchy(c)
    end)
    c:RegisterEffect(e4)

    -- cannot attack
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(e5)

    -- untargetable
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e6:SetRange(LOCATION_MZONE)
    e6:SetValue(1)
    c:RegisterEffect(e6)
    local e6b = e6:Clone()
    e6b:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
    c:RegisterEffect(e6b)

    -- battle mode
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 2))
    e7:SetType(EFFECT_TYPE_IGNITION)
    e7:SetProperty(EFFECT_FLAG_BOTH_SIDE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                       EFFECT_FLAG_CANNOT_INACTIVATE)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCountLimit(1)
    e7:SetCondition(function(e)
        return Duel.GetTurnCount() ~= e:GetHandler():GetTurnID()
    end)
    e7:SetCost(s.e7cost)
    e7:SetTarget(s.e7tg)
    e7:SetOperation(s.e7op)
    c:RegisterEffect(e7)
end

function s.e1con(e, c, minc, zone, relzone, exeff)
    if c == nil then
        return true
    end
    if exeff then
        local ret = exeff:GetValue()
        if type(ret) == "function" then
            ret = {ret(exeff, c)}
            if #ret > 1 then
                zone = (ret[2] >> 16) & 0x7f
            end
        end
    end
    local tp = c:GetControler()
    local mg = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
    mg = mg:Filter(Auxiliary.IsZone, nil, relzone, tp)
    return minc <= 3 and Duel.CheckTribute(c, 3, 3, mg, 1 - tp, zone)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, c, minc, zone, relzone, exeff)
    if exeff then
        local ret = exeff:GetValue()
        if type(ret) == "function" then
            ret = {ret(exeff, c)}
            if #ret > 1 then
                zone = (ret[2] >> 16) & 0x7f
            end
        end
    end
    local mg = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
    mg = mg:Filter(Auxiliary.IsZone, nil, relzone, tp)
    local g = Duel.SelectTribute(tp, c, 3, 3, mg, 1 - tp, zone, true)
    if g and #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c, minc, zone, relzone, exeff)
    local g = e:GetLabelObject()
    c:SetMaterial(g)
    Duel.Release(g, REASON_SUMMON + REASON_MATERIAL)
    g:DeleteGroup()
end

function s.e7cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 78665705)
    if chk == 0 then
        return tp == c:GetOwner() or #g > 0
    end

    if tp == c:GetOwner() and (#g == 0 or not Duel.SelectYesNo(tp, aux.Stringid(id, 3))) then
        return
    end

    Duel.ConfirmCards(1 - tp, g:GetFirst())
end

function s.e7tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local mc = c:GetMaterial():GetFirst()
    if chk == 0 then
        return mc and Dimension.CanBeDimensionChanged(mc) and
                   (c:GetControler() == tp or Duel.GetLocationCount(tp, LOCATION_MZONE) > 0)
    end
end

function s.e7op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetMaterial():GetFirst()

    local divine_evolution = Divine.IsDivineEvolution(c)
    Dimension.Change(c, tc, tc:GetMaterial(), tp, tp, POS_FACEUP)
    if divine_evolution then
        Divine.DivineEvolution(tc)
    end

    s.battlemode(c, tc, 4000)
end

function s.battlemode(c, tc, base_value)
    -- calculate atk/def
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
    elseif base_value ~= nil then
        atk = base_value
        def = base_value
    end

    -- set base atk/def
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec1b:SetValue(def)
    tc:RegisterEffect(ec1b)
end
