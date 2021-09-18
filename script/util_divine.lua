-- init
if not aux.DivineProcedure then aux.DivineProcedure = {} end
if not Divine then Divine = aux.DivineProcedure end

-- constant
Divine.DIVINE_EVOLUTION = 513000065

-- function
function Divine.DivineHierarchy(s, c, divine_hierarchy,
                                summon_by_three_tributes, limit)
    if divine_hierarchy then s.divine_hierarchy = divine_hierarchy end

    if summon_by_three_tributes then
        aux.AddNormalSummonProcedure(c, true, false, 3, 3)
        aux.AddNormalSetProcedure(c)

        -- summon cannot be negate
        local sumsafe = Effect.CreateEffect(c)
        sumsafe:SetType(EFFECT_TYPE_SINGLE)
        sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
        Divine.RegisterEffect(c, sumsafe)
    end

    -- activation and effects cannot be negated
    local nodis = Effect.CreateEffect(c)
    nodis:SetType(EFFECT_TYPE_SINGLE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    Divine.RegisterEffect(c, nodis)
    local inact = Effect.CreateEffect(c)
    inact:SetType(EFFECT_TYPE_FIELD)
    inact:SetCode(EFFECT_CANNOT_DISEFFECT)
    inact:SetRange(LOCATION_MZONE)
    inact:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    Divine.RegisterEffect(c, inact)
    local inact2 = inact:Clone()
    inact2:SetCode(EFFECT_CANNOT_INACTIVATE)
    c:RegisterEffect(inact2)

    -- cannot switch control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    Divine.RegisterEffect(c, noswitch)

    -- cannot be tributed by your opponent or by card effect
    local norelease1 = Effect.CreateEffect(c)
    norelease1:SetType(EFFECT_TYPE_FIELD)
    norelease1:SetProperty(EFFECT_FLAG_PLAYER_TARGET +
                               EFFECT_FLAG_CANNOT_DISABLE)
    norelease1:SetCode(EFFECT_CANNOT_RELEASE)
    norelease1:SetRange(LOCATION_MZONE)
    norelease1:SetTargetRange(0, 1)
    norelease1:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    Divine.RegisterEffect(c, norelease1)
    local norelease2 = Effect.CreateEffect(c)
    norelease2:SetType(EFFECT_TYPE_SINGLE)
    norelease2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    norelease2:SetCode(EFFECT_UNRELEASABLE_EFFECT)
    norelease2:SetRange(LOCATION_MZONE)
    norelease2:SetValue(1)
    Divine.RegisterEffect(c, norelease2)

    -- cannot be used as a material by your opponent
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc)
        if not tc then return false end
        return tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    Divine.RegisterEffect(c, nomaterial)

    -- cannot change position with effect
    local posunchange = Effect.CreateEffect(c)
    posunchange:SetType(EFFECT_TYPE_SINGLE)
    posunchange:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    posunchange:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    Divine.RegisterEffect(c, posunchange)

    -- immune
    local immunity = Effect.CreateEffect(c)
    immunity:SetType(EFFECT_TYPE_SINGLE)
    immunity:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    immunity:SetCode(EFFECT_IMMUNE_EFFECT)
    immunity:SetRange(LOCATION_MZONE)
    immunity:SetValue(function(e, te)
        local c = e:GetHandler()
        local tc = te:GetHandler()
        if tc == c or Divine.GetDivineHierarchy(tc) >=
            Divine.GetDivineHierarchy(c) then return false end
        return te:IsHasCategory(CATEGORY_TOHAND + CATEGORY_DESTROY +
                                    CATEGORY_REMOVE + CATEGORY_TODECK +
                                    CATEGORY_RELEASE + CATEGORY_TOGRAVE +
                                    CATEGORY_FUSION_SUMMON)
    end)
    Divine.RegisterEffect(c, immunity)
    local noleave = Effect.CreateEffect(c)
    noleave:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    noleave:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noleave:SetCode(EFFECT_SEND_REPLACE)
    noleave:SetRange(LOCATION_MZONE)
    noleave:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        local c = e:GetHandler()
        if chk == 0 then
            return
                c:IsReason(REASON_EFFECT) and r & REASON_EFFECT ~= 0 and re and
                    re:GetHandler() ~= c and
                    Divine.GetDivineHierarchy(re:GetHandler()) <
                    Divine.GetDivineHierarchy(c)
        end
        return true
    end)
    noleave:SetValue(function() return false end)
    Divine.RegisterEffect(c, noleave)

    -- reset effect
    local reset = Effect.CreateEffect(c)
    reset:SetDescription(666002)
    reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    reset:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    reset:SetCode(EVENT_ADJUST)
    reset:SetRange(LOCATION_MZONE)
    reset:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        if Duel.GetCurrentPhase() ~= PHASE_END then return false end
        local check = false
        local c = e:GetHandler()

        local effs = {c:GetCardEffect()}
        for _, eff in ipairs(effs) do
            if eff:GetOwner() ~= c and
                not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) and
                eff:GetCode() ~= EFFECT_SPSUMMON_PROC and
                (eff:GetTarget() == aux.PersistentTargetFilter or
                    not eff:IsHasType(EFFECT_TYPE_GRANT + EFFECT_TYPE_FIELD)) then
                check = true
                break
            end
        end
        return check
    end)
    reset:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local effs = {c:GetCardEffect()}
        for _, eff in ipairs(effs) do
            if eff:GetOwner() ~= c and
                not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) and
                eff:GetCode() ~= EFFECT_SPSUMMON_PROC and
                (eff:GetTarget() == aux.PersistentTargetFilter or
                    not eff:IsHasType(EFFECT_TYPE_GRANT + EFFECT_TYPE_FIELD)) then
                eff:Reset()
            end
        end
    end)
    Divine.RegisterEffect(c, reset)

    -- switch target
    local switchtarget = Effect.CreateEffect(c)
    switchtarget:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    switchtarget:SetCode(EVENT_SPSUMMON_SUCCESS)
    switchtarget:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if c:IsFacedown() or c:IsAttackPos() then return end

        local ac = Duel.GetAttacker()
        local bc = Duel.GetAttackTarget()
        local te, tg = Duel.GetChainInfo(ev + 1, CHAININFO_TRIGGERING_EFFECT,
                                         CHAININFO_TARGET_CARDS)

        local b1 = ac and bc and ac:CanAttack() and bc:IsControler(tp) and
                       not ac:IsImmuneToEffect(e)
        local b2 =
            te and te ~= re and te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and tg and
                #tg == 1 and tg:IsExists(
                function(c, tp)
                    return c:IsMonster() and c:IsControler(tp)
                end, 1, nil, tp)
        if not (b1 or b2) then return end
        if not Duel.SelectYesNo(tp, 666003) then return end

        Utility.HintCard(c)
        if b1 then Duel.ChangeAttackTarget(c) end
        if b2 then Duel.ChangeTargetCard(ev + 1, Group.FromCards(c)) end
    end)
    c:RegisterEffect(switchtarget)

    if limit then
        -- cannot attack when special summoned from the grave
        local spnoattack = Effect.CreateEffect(c)
        spnoattack:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
        spnoattack:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        spnoattack:SetCode(EVENT_SPSUMMON_SUCCESS)
        spnoattack:SetCondition(function(e)
            return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
        end)
        spnoattack:SetOperation(function(e)
            local c = e:GetHandler()
            local ec1 = Effect.CreateEffect(c)
            ec1:SetDescription(3206)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            ec1:SetCode(EFFECT_CANNOT_ATTACK)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            c:RegisterEffect(ec1)
        end)
        Divine.RegisterEffect(c, spnoattack)

        -- return
        local returnend = Effect.CreateEffect(c)
        returnend:SetDescription(666004)
        returnend:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        returnend:SetCode(EVENT_PHASE + PHASE_END)
        returnend:SetRange(LOCATION_MZONE)
        returnend:SetCountLimit(1)
        returnend:SetCode(EVENT_PHASE + PHASE_END)
        returnend:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
            local c = e:GetHandler()
            return c:IsSummonType(SUMMON_TYPE_SPECIAL) and
                       c:IsPreviousLocation(LOCATION_GRAVE) and
                       c:IsAbleToGrave()
        end)
        returnend:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            Duel.SendtoGrave(e:GetHandler(), REASON_EFFECT)
        end)
        Divine.RegisterEffect(c, returnend)
    end
end

function Divine.GetDivineHierarchy(c, get_base)
    if not c then return 0 end
    local divine_hierarchy = c.divine_hierarchy
    if not divine_hierarchy then divine_hierarchy = 0 end
    if get_base then return divine_hierarchy end

    if c:GetFlagEffect(Divine.DIVINE_EVOLUTION) > 0 then
        divine_hierarchy = divine_hierarchy + 1
    end

    return divine_hierarchy
end

function Divine.DivineEvolution(c)
    c:RegisterFlagEffect(Divine.DIVINE_EVOLUTION, RESET_EVENT + RESETS_STANDARD,
                         EFFECT_FLAG_CLIENT_HINT, 1, 0, 666005)
end

function Divine.IsDivineEvolution(c)
    return c:GetFlagEffect(Divine.DIVINE_EVOLUTION) > 0
end

function Divine.RegisterEffect(c, eff, forced)
    local e = eff:Clone()
    e:SetProperty(e:GetProperty() + EFFECT_FLAG_UNCOPYABLE)
    c:RegisterEffect(e, forced)
end

function Divine.RegisterRaFuse(id, c, tc, forced)
    -- fusion type
    local fus = Effect.CreateEffect(c)
    fus:SetType(EFFECT_TYPE_SINGLE)
    fus:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    fus:SetCode(EFFECT_ADD_TYPE)
    fus:SetCondition(function(e) return e:GetHandler():IsHasEffect(id) end)
    fus:SetValue(TYPE_FUSION)
    fus:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterEffect(tc, fus, forced)

    -- base atk/def
    local atk = Effect.CreateEffect(c)
    atk:SetType(EFFECT_TYPE_SINGLE)
    atk:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    atk:SetCode(EFFECT_SET_BASE_ATTACK)
    atk:SetCondition(function(e) return e:GetHandler():IsHasEffect(id) end)
    atk:SetValue(function(e)
        return e:GetHandler():GetCardEffect(id):GetLabelObject()[1]
    end)
    atk:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterEffect(tc, atk, forced)
    local def = atk:Clone()
    def:SetCode(EFFECT_SET_BASE_DEFENSE)
    def:SetValue(function(e)
        return e:GetHandler():GetCardEffect(id):GetLabelObject()[2]
    end)
    Divine.RegisterEffect(tc, def, forced)

    -- life point transfer
    local lp = Effect.CreateEffect(c)
    lp:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    lp:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    lp:SetCode(EVENT_RECOVER)
    lp:SetRange(LOCATION_MZONE)
    lp:SetCondition(function(e, tp, eg, ep) return ep == tp end)
    lp:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsLocation(LOCATION_MZONE) or c:IsFacedown() or
            not c:IsHasEffect(id) then return end

        local eff = c:GetCardEffect(id)
        local label = eff:GetLabelObject()
        label[1] = label[1] + ev
        label[2] = label[2] + ev
        eff:SetLabelObject(label)

        Duel.SetLP(tp, Duel.GetLP(tp) - ev, REASON_EFFECT)
    end)
    lp:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterEffect(tc, lp, forced)
end

function Divine.RegisterRaDefuse(s, id, c)
    aux.GlobalCheck(s, function()
        local defuse = Effect.CreateEffect(c)
        defuse:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        defuse:SetCode(EVENT_ADJUST)
        defuse:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local g = Duel.GetMatchingGroup(function(c)
                return c:IsCode(95286165) and c:GetFlagEffect(id) == 0
            end, tp, 0xff, 0xff, nil)

            for tc in aux.Next(g) do
                tc:RegisterFlagEffect(id, 0, 0, 0)
                local ec1 = Effect.CreateEffect(tc)
                ec1:SetDescription(666006)
                ec1:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE +
                                    CATEGORY_RECOVER)
                ec1:SetType(EFFECT_TYPE_ACTIVATE)
                ec1:SetCode(tc:GetActivateEffect():GetCode())
                ec1:SetProperty(tc:GetActivateEffect():GetProperty() +
                                    EFFECT_FLAG_DAMAGE_STEP +
                                    EFFECT_FLAG_IGNORE_IMMUNE +
                                    EFFECT_FLAG_CANNOT_DISABLE +
                                    EFFECT_FLAG_CANNOT_INACTIVATE +
                                    EFFECT_FLAG_CANNOT_NEGATE)
                ec1:SetHintTiming(TIMING_DAMAGE_STEP,
                                  TIMING_DAMAGE_STEP + TIMINGS_CHECK_MONSTER)
                ec1:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
                    if chk == 0 then
                        return Duel.IsExistingTarget(RaDefuseFilter, tp,
                                                     LOCATION_MZONE,
                                                     LOCATION_MZONE, 1, nil, id)
                    end

                    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
                    local tc = Duel.SelectTarget(tp, RaDefuseFilter, tp,
                                                 LOCATION_MZONE, LOCATION_MZONE,
                                                 1, 1, nil, id):GetFirst()

                    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0,
                                          tc:GetControler(), tc:GetAttack())
                end)
                ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
                    local c = e:GetHandler()
                    local tc = Duel.GetFirstTarget()
                    if tc:IsFacedown() or not tc:IsRelateToEffect(e) or
                        not tc:IsHasEffect(id) then return end

                    local atk = tc:GetAttack()
                    tc:GetCardEffect(id):Reset()
                    if tc:GetCardEffect(EFFECT_SET_BASE_ATTACK) then
                        tc:GetCardEffect(EFFECT_SET_BASE_ATTACK):Reset()
                    end
                    if tc:GetCardEffect(EFFECT_SET_BASE_DEFENSE) then
                        tc:GetCardEffect(EFFECT_SET_BASE_DEFENSE):Reset()
                    end

                    local ec1 = Effect.CreateEffect(c)
                    ec1:SetType(EFFECT_TYPE_SINGLE)
                    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE +
                                        EFFECT_FLAG_UNCOPYABLE)
                    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
                    ec1:SetValue(0)
                    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
                    tc:RegisterEffect(ec1)
                    local ec1b = ec1:Clone()
                    ec1b:SetCode(EFFECT_SET_DEFENSE_FINAL)
                    tc:RegisterEffect(ec1b)
                    Duel.AdjustInstantly(tc)

                    Duel.Recover(tc:GetControler(), atk, REASON_EFFECT)
                end)
                tc:RegisterEffect(ec1)
            end
        end)
        Duel.RegisterEffect(defuse, 0)
    end)
end

function RaDefuseFilter(c, id)
    return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsCode(CARD_RA) and
               c:IsHasEffect(id)
end
