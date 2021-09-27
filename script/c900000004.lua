-- Sun Divine Beast of Ra - Sphere Mode
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {Divine.CARD_RA, Divine.CARD_ANCIENT_CHANT}

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 2, false, false)
    Dimension.AddProcedure(c)

    -- dimension change
    Dimension.RegisterChange({
        handler = c,
        event_code = EVENT_SUMMON_SUCCESS,
        filter = function(c, sc)
            return c:IsCode(Divine.CARD_RA) and c:GetOwner() == sc:GetOwner()
        end,
        custom_op = function(e, tp, mc)
            local c = e:GetHandler()
            if mc:IsControler(tp) then
                Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 2))
                local op = Duel.SelectOption(tp, aux.Stringid(id, 3),
                                             aux.Stringid(id, 4))
                if op == 0 then
                    Utility.HintCard(c)
                    s.battlemode(c, mc, 4000, 4000)
                    return
                end
            end

            local divine_evolution = Divine.IsDivineEvolution(mc)
            Dimension.Change(mc, c)
            if divine_evolution then Divine.DivineEvolution(c) end
        end
    })

    -- cannot attack
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    Divine.RegisterEffect(c, e1)

    -- untargetable
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(1)
    Divine.RegisterEffect(c, e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
    Divine.RegisterEffect(c, e2b)

    -- summon ra to opponent's field
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE +
                       EFFECT_FLAG_SPSUM_PARAM)
    e3:SetCode(EFFECT_LIMIT_SUMMON_PROC)
    e3:SetTargetRange(POS_FACEUP_ATTACK, 1)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    e3:SetValue(SUMMON_TYPE_TRIBUTE)
    local e3grant = Effect.CreateEffect(c)
    e3grant:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3grant:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e3grant:SetCode(EVENT_STARTUP)
    e3grant:SetRange(LOCATION_ALL)
    e3grant:SetCountLimit(1, id)
    e3grant:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local g = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil,
                                        Divine.CARD_RA)
        for tc in aux.Next(g) do
            local eff = tc:GetCardEffect(EFFECT_LIMIT_SUMMON_PROC)
            eff:SetDescription(aux.Stringid(id, 0))
        end

        local grant = Effect.CreateEffect(c)
        grant:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
        grant:SetTargetRange(LOCATION_HAND, 0)
        grant:SetLabelObject(e3)
        grant:SetCondition(function(e)
            return Dimension.IsInDimensionZone(e:GetHandler())
        end)
        grant:SetTarget(aux.TargetBoolFunction(Card.IsCode, Divine.CARD_RA))
        Duel.RegisterEffect(grant, tp)
        c:IsHasEffect(id)
    end)
    Divine.RegisterEffect(c, e3grant)

    -- battle mode
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 4))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_BOTH_SIDE + EFFECT_FLAG_CANNOT_DISABLE +
                       EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(function(e)
        return Duel.GetTurnCount() ~= e:GetHandler():GetTurnID()
    end)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    Divine.RegisterEffect(c, e4)
end

function s.e3con(e, c, minc, zone, relzone, exeff)
    if c == nil then return true end
    if exeff then
        local ret = exeff:GetValue()
        if type(ret) == "function" then
            ret = {ret(exeff, c)}
            if #ret > 1 then zone = (ret[2] >> 16) & 0x7f end
        end
    end
    local tp = c:GetControler()
    local mg = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
    mg = mg:Filter(Auxiliary.IsZone, nil, relzone, tp)
    return minc <= 3 and Duel.CheckTribute(c, 3, 3, mg, 1 - tp, zone)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, c, minc, zone, relzone, exeff)
    if exeff then
        local ret = exeff:GetValue()
        if type(ret) == "function" then
            ret = {ret(exeff, c)}
            if #ret > 1 then zone = (ret[2] >> 16) & 0x7f end
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

function s.e3op(e, tp, eg, ep, ev, re, r, rp, c, minc, zone, relzone, exeff)
    local g = e:GetLabelObject()
    c:SetMaterial(g)
    Duel.Release(g, REASON_SUMMON + REASON_MATERIAL)
    g:DeleteGroup()
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil,
                                    Divine.CARD_ANCIENT_CHANT)
    if chk == 0 then return tp == c:GetOwner() or #g > 0 end

    if tp == c:GetOwner() and
        (#g == 0 or not Duel.SelectYesNo(tp, aux.Stringid(id, 5))) then
        return
    end

    Duel.ConfirmCards(1 - tp, g:GetFirst())
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local mc = c:GetMaterial():GetFirst()
    if chk == 0 then
        return mc and Dimension.CanBeDimensionChanged(mc) and
                   (c:GetControler() == tp or
                       Duel.GetLocationCount(tp, LOCATION_MZONE) > 0)
    end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetMaterial():GetFirst()

    local divine_evolution = Divine.IsDivineEvolution(c)
    Dimension.Change(c, tc, tc:GetMaterial(), tp, tp)
    if divine_evolution then Divine.DivineEvolution(tc) end
    s.battlemode(c, tc, 4000, 4000)
end

function s.battlemode(c, tc, base_atk, base_def)
    -- calculate atk/def
    local atk = 0
    local def = 0
    if tc:IsSummonType(SUMMON_TYPE_TRIBUTE) then
        local mg = tc:GetMaterial()
        for mc in aux.Next(mg) do
            if mc:GetPreviousAttackOnField() > 0 then
                atk = atk + mc:GetPreviousAttackOnField()
            end
            if mc:GetPreviousDefenseOnField() > 0 then
                def = def + mc:GetPreviousDefenseOnField()
            end
        end
    else
        if base_atk ~= nil then atk = base_atk end
        if base_def ~= nil then def = base_def end
    end

    -- set base atk/def
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterGrantEffect(tc, ec1, true)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec1b:SetValue(def)
    Divine.RegisterGrantEffect(tc, ec1b, true)
end
