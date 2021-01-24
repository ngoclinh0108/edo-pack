-- Ra the Sun Divine Beast - Sphere Mode
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("proc_dimension.lua")
local s, id = GetID()

s.listed_names = {CARD_RA}

function s.initial_effect(c)
    Dimension.AddProcedure(c)
    Divine.SetHierarchy(s, 2)

    -- startup
    Dimension.RegisterEffect(c, function(e, tp)
        local dms = Effect.CreateEffect(c)
        dms:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        dms:SetCode(EVENT_SUMMON_SUCCESS)
        dms:SetCondition(s.dmscon)
        dms:SetOperation(s.dmsop)
        Duel.RegisterEffect(dms, tp)
    end)

    -- activation and effects cannot be negated
    local inact = Effect.CreateEffect(c)
    inact:SetType(EFFECT_TYPE_FIELD)
    inact:SetCode(EFFECT_CANNOT_INACTIVATE)
    inact:SetRange(LOCATION_MZONE)
    inact:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(inact)
    local inact2 = inact:Clone()
    inact2:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(inact2)
    local nodis = Effect.CreateEffect(c)
    nodis:SetType(EFFECT_TYPE_SINGLE)
    nodis:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    nodis:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nodis)

    -- cannot be targeted
    local untargetable = Effect.CreateEffect(c)
    untargetable:SetType(EFFECT_TYPE_SINGLE)
    untargetable:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    untargetable:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    untargetable:SetRange(LOCATION_MZONE)
    untargetable:SetValue(1)
    c:RegisterEffect(untargetable)

    -- cannot be tributed or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_SINGLE)
    norelease:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetValue(1)
    c:RegisterEffect(norelease)
    local nofus = norelease:Clone()
    nofus:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    c:RegisterEffect(nofus)
    local nosync = norelease:Clone()
    nosync:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    c:RegisterEffect(nosync)
    local noxyz = norelease:Clone()
    noxyz:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    c:RegisterEffect(noxyz)
    local nolnk = norelease:Clone()
    nolnk:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    c:RegisterEffect(nolnk)

    -- cannot be flipped face-down
    local noflip = Effect.CreateEffect(c)
    noflip:SetType(EFFECT_TYPE_SINGLE)
    noflip:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noflip:SetCode(EFFECT_CANNOT_TURN_SET)
    noflip:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noflip)

    -- cannot be switch control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- immunity
    local immunity = Effect.CreateEffect(c)
    immunity:SetType(EFFECT_TYPE_SINGLE)
    immunity:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    immunity:SetCode(EFFECT_IMMUNE_EFFECT)
    immunity:SetRange(LOCATION_MZONE)
    immunity:SetValue(function(e, te)
        local c = e:GetHandler()
        local tc = te:GetHandler()

        if (tc == c) or
            (tc.divine_hierarchy and tc.divine_hierarchy >= c.divine_hierarchy) then
            return false
        end

        return te:IsActiveType(TYPE_MONSTER) or
                   te:IsHasCategory(CATEGORY_DESTROY + CATEGORY_REMOVE +
                                        CATEGORY_TOGRAVE + CATEGORY_TOHAND +
                                        CATEGORY_TODECK + CATEGORY_RELEASE +
                                        CATEGORY_FUSION_SUMMON)
    end)
    c:RegisterEffect(immunity)

    -- reset effect
    local reset = Effect.CreateEffect(c)
    reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    reset:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    reset:SetCode(EVENT_ADJUST)
    reset:SetRange(LOCATION_MZONE)
    reset:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        if Duel.GetCurrentPhase() ~= PHASE_END then return false end

        local c = e:GetHandler()
        local check = false
        local effs = {c:GetCardEffect()}
        for _, eff in ipairs(effs) do
            check = (eff:GetOwner() ~= c and
                        not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) and
                        eff:GetCode() ~= EFFECT_SPSUMMON_PROC and
                        (eff:GetTarget() == aux.PersistentTargetFilter or
                            not eff:IsHasType(EFFECT_TYPE_GRANT)))
            if check == true then break end
        end
        return check
    end)
    reset:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local effs = {c:GetCardEffect()}
        for _, eff in ipairs(effs) do
            local ec = eff:GetOwner()
            local check = ec ~= c and
                              not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) and
                              eff:GetCode() ~= EFFECT_SPSUMMON_PROC and
                              (eff:GetTarget() == aux.PersistentTargetFilter or
                                  not eff:IsHasType(EFFECT_TYPE_GRANT))

            if check then
                if not eff:IsHasType(EFFECT_TYPE_FIELD) then
                    eff:Reset()
                end

                if (not ec.divine_hierarchy) then
                    local immunity = Effect.CreateEffect(c)
                    immunity:SetType(EFFECT_TYPE_SINGLE)
                    immunity:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
                    immunity:SetCode(EFFECT_IMMUNE_EFFECT)
                    immunity:SetRange(LOCATION_MZONE)
                    immunity:SetLabelObject(ec)
                    immunity:SetValue(function(e, te)
                        return te:GetHandler() == e:GetLabelObject()
                    end)
                    immunity:SetReset(RESET_EVENT + RESETS_STANDARD)
                    c:RegisterEffect(immunity)
                end
            end
        end
    end)
    c:RegisterEffect(reset)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_PYRO + RACE_WINGEDBEAST)
    c:RegisterEffect(e1)

    -- attack limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(e2)

    -- battle indes & damage avoid
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.e3val)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    c:RegisterEffect(e3b)

    -- summon ra
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_BOTH_SIDE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.dmsfilter(c, dc)
    return c:GetOwner() == dc:GetOwner() and c:IsCode(CARD_RA)
end

function s.dmscon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.dmsfilter, 1, nil, e:GetHandler())
end

function s.dmsop(e, tp, eg, ep, ev, re, r, rp)
    Duel.BreakEffect()
    local c = e:GetHandler()

    local mc
    local mg = eg:Filter(s.dmsfilter, nil, c)
    if #mg <= 0 then
        return
    elseif #mg == 1 then
        mc = mg:GetFirst()
    else
        mc = mg:Select(c:GetOwner(), 1, 1):GetFirst()
    end
    if not mc then return end

    Dimension.Change(c, mc, mc:GetControler(), mc:GetControler(),
                     mc:GetPosition())
end

function s.e3val(e, tc)
    local c = e:GetHandler()
    return c:IsDefensePos() and tc and
               (not tc.divine_hierarchy or tc.divine_hierarchy <
                   c.divine_hierarchy)
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local mc = c:GetMaterial():GetFirst()

    if chk == 0 then
        return mc and mc:GetOwner() == tp and
                   (c:IsControler(tp) or
                       Duel.GetLocationCount(tp, LOCATION_MZONE) > 0)
    end

    Dimension.SendToDimension(c, REASON_COST)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local mc = c:GetMaterial():GetFirst()

    if chk == 0 then return mc:IsCanBeSpecialSummoned(e, 0, tp, true, false) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, mc, 1, 0, 0)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetMaterial():GetFirst()
    if not tc then return end
    if not c:IsControler(tp) and Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then
        Duel.SendtoGrave(tc, REASON_RULE)
        return
    end

    local is_tribute_summon = tc:IsSummonType(SUMMON_TYPE_TRIBUTE)
    Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP)
    Dimension.Zones(tc:GetOwner()):RemoveCard(tc)

    local atk = 0
    local def = 0
    if is_tribute_summon then
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
