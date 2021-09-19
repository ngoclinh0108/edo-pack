-- init
if not aux.DivineProcedure then aux.DivineProcedure = {} end
if not Divine then Divine = aux.DivineProcedure end

-- constant
Divine.DIVINE_EVOLUTION = 513000065

-- function
function Divine.DivineHierarchy(s, c, divine_hierarchy,
                                summon_by_three_tributes, spsummon_effect)
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

    -- effects cannot be negated
    local nodis = Effect.CreateEffect(c)
    nodis:SetType(EFFECT_TYPE_SINGLE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    Divine.RegisterEffect(c, nodis)
    local nodisb = Effect.CreateEffect(c)
    nodisb:SetType(EFFECT_TYPE_FIELD)
    nodisb:SetCode(EFFECT_CANNOT_DISEFFECT)
    nodisb:SetRange(LOCATION_MZONE)
    nodisb:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    Divine.RegisterEffect(c, nodisb)

    -- cannot switch control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    Divine.RegisterEffect(c, noswitch)

    -- cannot be Tributed, or be used as a material for an Summon by your opponent.
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    Divine.RegisterEffect(c, norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc)
        return tc and tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    Divine.RegisterEffect(c, nomaterial)

    -- no leave
    local noleave1 = Effect.CreateEffect(c)
    noleave1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    noleave1:SetCode(EVENT_CHAINING)
    noleave1:SetRange(LOCATION_MZONE)
    noleave1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not re or re:GetHandler():IsMonster() then return end
        local c = e:GetHandler()

        local eff_codes = {
            EFFECT_UNRELEASABLE_NONSUM, EFFECT_UNRELEASABLE_EFFECT,
            EFFECT_CANNOT_CHANGE_POS_E, EFFECT_INDESTRUCTABLE_EFFECT,
            EFFECT_CANNOT_TO_HAND, EFFECT_CANNOT_TO_DECK,
            EFFECT_CANNOT_TO_GRAVE, EFFECT_CANNOT_REMOVE
        }
        for _, eff_code in ipairs(eff_codes) do
            local eff = Effect.CreateEffect(c)
            eff:SetType(EFFECT_TYPE_SINGLE)
            eff:SetCode(eff_code)
            eff:SetRange(LOCATION_MZONE)
            eff:SetReset(RESET_CHAIN)
            eff:SetValue(1)
            c:RegisterEffect(eff)
        end
    end)
    Divine.RegisterEffect(c, noleave1)
    local noleave2 = Effect.CreateEffect(c)
    noleave2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    noleave2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noleave2:SetCode(EFFECT_SEND_REPLACE)
    noleave2:SetRange(LOCATION_MZONE)
    noleave2:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return r & REASON_EFFECT ~= 0 and
                       e:GetHandler():IsReason(REASON_EFFECT) and re and
                       not re:GetHandler():IsMonster()
        end
        return true
    end)
    Divine.RegisterEffect(c, noleave2)

    -- immune
    local immune = Effect.CreateEffect(c)
    immune:SetType(EFFECT_TYPE_SINGLE)
    immune:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    immune:SetCode(EFFECT_IMMUNE_EFFECT)
    immune:SetRange(LOCATION_MZONE)
    immune:SetValue(function(e, te)
        return te:GetHandler() ~= e:GetHandler() and
                   te:IsActiveType(TYPE_MONSTER) and
                   Divine.GetDivineHierarchy(te:GetHandler()) <
                   Divine.GetDivineHierarchy(c)
    end)
    Divine.RegisterEffect(c, immune)

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

    if spsummon_effect then
        -- switch target
        local switchtarget = Effect.CreateEffect(c)
        switchtarget:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
        switchtarget:SetCode(EVENT_SPSUMMON_SUCCESS)
        switchtarget:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local c = e:GetHandler()
            if c:IsFacedown() or c:IsAttackPos() then return end

            local ac = Duel.GetAttacker()
            local bc = Duel.GetAttackTarget()
            local te, tg = Duel.GetChainInfo(ev + 1,
                                             CHAININFO_TRIGGERING_EFFECT,
                                             CHAININFO_TARGET_CARDS)

            local b1 = ac and bc and ac:CanAttack() and bc:IsControler(tp) and
                           not ac:IsImmuneToEffect(e)
            local b2 = te and te ~= re and
                           te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and tg and
                           #tg == 1 and tg:IsExists(function(c, tp)
                return c:IsMonster() and c:IsControler(tp)
            end, 1, nil, tp)
            if not (b1 or b2) then return end
            if not Duel.SelectYesNo(tp, 666003) then return end

            Utility.HintCard(c)
            if b1 then Duel.ChangeAttackTarget(c) end
            if b2 then
                Duel.ChangeTargetCard(ev + 1, Group.FromCards(c))
            end
        end)
        c:RegisterEffect(switchtarget)

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

        -- to grave
        local togy = Effect.CreateEffect(c)
        togy:SetDescription(666004)
        togy:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        togy:SetCode(EVENT_PHASE + PHASE_END)
        togy:SetRange(LOCATION_MZONE)
        togy:SetCountLimit(1)
        togy:SetCode(EVENT_PHASE + PHASE_END)
        togy:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
            local c = e:GetHandler()
            return c:IsSummonType(SUMMON_TYPE_SPECIAL) and
                       c:IsPreviousLocation(LOCATION_GRAVE) and
                       c:IsAbleToGrave()
        end)
        togy:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            Duel.SendtoGrave(e:GetHandler(), REASON_EFFECT)
        end)
        Divine.RegisterEffect(c, togy)
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

function Divine.RegisterRaFuse(c, tc, forced)
    local id = c:GetOriginalCode()

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

function Divine.RegisterRaDefuse(s, c)
    local id = c:GetOriginalCode()

    function DefuseFilter(c)
        return c:IsCode(95286165) and not c:IsHasEffect(id)
    end

    aux.GlobalCheck(s, function()
        local defuse = Effect.CreateEffect(c)
        defuse:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        defuse:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        defuse:SetCode(EVENT_ADJUST)
        defuse:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
            return Duel.IsExistingMatchingCard(DefuseFilter, tp, 0xff, 0xff, 1,
                                               nil)
        end)
        defuse:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local g = Duel.GetMatchingGroup(DefuseFilter, tp, 0xff, 0xff, nil)
            for tc in aux.Next(g) do
                local eff = Effect.CreateEffect(tc)
                eff:SetType(EFFECT_TYPE_SINGLE)
                eff:SetCode(id)
                tc:RegisterEffect(eff)

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
