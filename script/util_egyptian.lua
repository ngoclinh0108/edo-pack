-- init
if not aux.DivineProcedure then
    aux.DivineProcedure = {}
end
if not Divine then
    Divine = aux.DivineProcedure
end

-- constant: card names
Divine.CARD_OBELISK = 10000000
Divine.CARD_SLIFER = 10000020
Divine.CARD_RA = 10000010
Divine.CARD_RA_SPHERE = 10000080
Divine.CARD_RA_PHOENIX = 10000090
Divine.CARD_HOLACTIE = 10000040
Divine.CARD_DEFUSION = 95286165

-- constant: flag
Divine.FLAG_DIVINE_EVOLUTION = 513000065

-- function
function Divine.DivineHierarchy(s, c, divine_hierarchy, summon_by_three_tributes, spsummon_effect)
    if divine_hierarchy then
        s.divine_hierarchy = divine_hierarchy
    end

    if summon_by_three_tributes then
        -- 3 tribute
        aux.AddNormalSummonProcedure(c, true, false, 3, 3)
        aux.AddNormalSetProcedure(c)

        -- summon cannot be negate
        local sumsafe = Effect.CreateEffect(c)
        sumsafe:SetType(EFFECT_TYPE_SINGLE)
        sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
        c:RegisterEffect(sumsafe)
    end

    -- effect cannot be negated
    local nodis1 = Effect.CreateEffect(c)
    nodis1:SetType(EFFECT_TYPE_SINGLE)
    nodis1:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(nodis1)
    local nodis2 = Effect.CreateEffect(c)
    nodis2:SetType(EFFECT_TYPE_FIELD)
    nodis2:SetCode(EFFECT_CANNOT_DISEFFECT)
    nodis2:SetRange(LOCATION_MZONE)
    nodis2:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(nodis2)

    -- cannot switch control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noswitch:SetRange(LOCATION_MZONE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    c:RegisterEffect(noswitch)

    -- cannot be tributed, or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc)
        return tc and tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(nomaterial)

    -- -- no leave
    -- local noleave_solving = Effect.CreateEffect(c)
    -- noleave_solving:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    -- noleave_solving:SetRange(LOCATION_MZONE)
    -- noleave_solving:SetCode(EVENT_CHAIN_SOLVING)
    -- noleave_solving:SetLabelObject({})
    -- noleave_solving:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
    --     if not re then return end
    --     local c = e:GetHandler()
    --     local rc = re:GetHandler()
    --     if c == rc then return end
    --     if rc:IsMonster() and Divine.GetDivineHierarchy(rc) >
    --         Divine.GetDivineHierarchy(c) then return end

    --     local eff_codes = {
    --         EFFECT_CANNOT_TO_HAND, EFFECT_CANNOT_TO_DECK,
    --         EFFECT_CANNOT_TO_GRAVE, EFFECT_CANNOT_REMOVE
    --     }
    --     for _, eff_code in ipairs(eff_codes) do
    --         local eff = Effect.CreateEffect(c)
    --         eff:SetType(EFFECT_TYPE_SINGLE)
    --         eff:SetRange(LOCATION_MZONE)
    --         eff:SetCode(eff_code)
    --         eff:SetValue(1)
    --         eff:SetReset(RESET_CHAIN)
    --         Divine.RegisterEffect(c, eff)
    --         table.insert(e:GetLabelObject(), eff)
    --     end
    -- end)
    -- c:RegisterEffect(noleave_solving)
    -- local noleave_solved = noleave_solving:Clone()
    -- noleave_solved:SetCode(EVENT_CHAIN_SOLVED)
    -- noleave_solved:SetLabelObject(noleave_solving)
    -- noleave_solved:SetOperation(function(e)
    --     local effs = e:GetLabelObject():GetLabelObject()
    --     while #effs > 0 do
    --         local eff = table.remove(effs)
    --         eff:Reset()
    --     end
    -- end)
    -- c:RegisterEffect(noleave_solved)
    -- local noleave_replace = Effect.CreateEffect(c)
    -- noleave_replace:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    -- noleave_replace:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    -- noleave_replace:SetRange(LOCATION_MZONE)
    -- noleave_replace:SetCode(EFFECT_SEND_REPLACE)
    -- noleave_replace:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
    --     local c = e:GetHandler()
    --     if chk == 0 then
    --         if r & REASON_EFFECT == 0 or not c:IsReason(REASON_EFFECT) or not re or
    --             re:GetHandler() == c then return false end
    --         local rc = re:GetHandler()
    --         return not rc:IsMonster() or Divine.GetDivineHierarchy(rc) <=
    --                    Divine.GetDivineHierarchy(c)
    --     end
    --     return true
    -- end)
    -- c:RegisterEffect(noleave_replace)
    -- local noleave_eff_1 = Effect.CreateEffect(c)
    -- noleave_eff_1:SetType(EFFECT_TYPE_SINGLE)
    -- noleave_eff_1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    -- noleave_eff_1:SetRange(LOCATION_MZONE)
    -- noleave_eff_1:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    -- noleave_eff_1:SetValue(1)
    -- c:RegisterEffect(noleave_eff_1)
    -- local noleave_eff_2 = noleave_eff_1:Clone()
    -- noleave_eff_2:SetCode(EFFECT_UNRELEASABLE_EFFECT)
    -- c:RegisterEffect(noleave_eff_2)
    -- local noleave_eff_3 = noleave_eff_1:Clone()
    -- noleave_eff_3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    -- noleave_eff_3:SetValue(function(e, te)
    --     return te:GetHandler() ~= e:GetHandler()
    -- end)
    -- c:RegisterEffect(noleave_eff_3)

    -- -- immune
    -- local immune = Effect.CreateEffect(c)
    -- immune:SetType(EFFECT_TYPE_SINGLE)
    -- immune:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    -- immune:SetRange(LOCATION_MZONE)
    -- immune:SetCode(EFFECT_IMMUNE_EFFECT)
    -- immune:SetValue(function(e, te)
    --     local c = e:GetHandler()
    --     local tc = te:GetHandler()
    --     local tp = e:GetHandlerPlayer()
    --     return tc:IsControler(1 - tp) and tc:IsMonster() and
    --                Divine.GetDivineHierarchy(tc) < Divine.GetDivineHierarchy(c)
    -- end)
    -- c:RegisterEffect(immune)

    -- -- reset effect
    -- local reset = Effect.CreateEffect(c)
    -- reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    -- reset:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    -- reset:SetRange(LOCATION_MZONE)
    -- reset:SetCode(EVENT_ADJUST)
    -- reset:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
    --     return Duel.GetCurrentPhase() == PHASE_END and
    --                Utility.GetListEffect(e:GetHandler(), ResetEffectFilter)
    -- end)
    -- reset:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
    --     Utility.ResetListEffect(e:GetHandler(), ResetEffectFilter)
    -- end)
    -- c:RegisterEffect(reset)

    -- if spsummon_effect then
    --     -- cannot attack when special summoned from the grave
    --     local spnoattack = Effect.CreateEffect(c)
    --     spnoattack:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    --     spnoattack:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    --     spnoattack:SetCode(EVENT_SPSUMMON_SUCCESS)
    --     spnoattack:SetCondition(function(e)
    --         return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
    --     end)
    --     spnoattack:SetOperation(function(e)
    --         local c = e:GetHandler()
    --         if c:IsHasEffect(EFFECT_UNSTOPPABLE_ATTACK) then return end

    --         local ec1 = Effect.CreateEffect(c)
    --         ec1:SetDescription(3206)
    --         ec1:SetType(EFFECT_TYPE_SINGLE)
    --         ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    --         ec1:SetCode(EFFECT_CANNOT_ATTACK)
    --         ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    --         Divine.RegisterEffect(c, ec1)
    --     end)
    --     c:RegisterEffect(spnoattack)

    --     -- to grave
    --     local togy = Effect.CreateEffect(c)
    --     togy:SetDescription(666003)
    --     togy:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    --     togy:SetRange(LOCATION_MZONE)
    --     togy:SetCode(EVENT_PHASE + PHASE_END)
    --     togy:SetCountLimit(1)
    --     togy:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
    --         local c = e:GetHandler()
    --         return c:IsSummonType(SUMMON_TYPE_SPECIAL) and
    --                    c:IsPreviousLocation(LOCATION_GRAVE) and
    --                    c:IsAbleToGrave()
    --     end)
    --     togy:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
    --         Duel.SendtoGrave(e:GetHandler(), REASON_EFFECT)
    --     end)
    --     c:RegisterEffect(togy)
    -- end
end

function Divine.GetDivineHierarchy(c, get_base)
    if not c then
        return 0
    end
    local divine_hierarchy = c.divine_hierarchy
    if not divine_hierarchy then
        divine_hierarchy = 0
    end
    if get_base then
        return divine_hierarchy
    end

    if c:GetFlagEffect(Divine.FLAG_DIVINE_EVOLUTION) > 0 then
        divine_hierarchy = divine_hierarchy + 1
    end

    return divine_hierarchy
end

function Divine.DivineEvolution(c)
    c:RegisterFlagEffect(Divine.FLAG_DIVINE_EVOLUTION, RESET_EVENT + RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT, 1, 0,
        666000)
end

function Divine.IsDivineEvolution(c)
    return c:GetFlagEffect(Divine.FLAG_DIVINE_EVOLUTION) > 0
end

function Divine.RegisterRaFuse(c, tc, reset, forced)
    local id = c:GetOriginalCode()
    if tc == nil then
        tc = c
    end

    -- fusion type
    local fus = Effect.CreateEffect(c)
    fus:SetType(EFFECT_TYPE_SINGLE)
    fus:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    fus:SetCode(EFFECT_ADD_TYPE)
    fus:SetCondition(function(e)
        return e:GetHandler():IsHasEffect(id)
    end)
    fus:SetValue(TYPE_FUSION)
    if reset then
        fus:SetReset(reset)
    end
    Divine.RegisterEffect(c, fus, forced)

    -- base atk/def
    local atk = Effect.CreateEffect(c)
    atk:SetType(EFFECT_TYPE_SINGLE)
    atk:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    atk:SetCode(EFFECT_SET_BASE_ATTACK)
    atk:SetCondition(function(e)
        return e:GetHandler():IsHasEffect(id)
    end)
    atk:SetValue(function(e)
        return e:GetHandler():GetCardEffect(id):GetLabelObject()[1]
    end)
    if reset then
        atk:SetReset(reset)
    end
    Divine.RegisterEffect(c, atk, forced)
    local def = atk:Clone()
    def:SetCode(EFFECT_SET_BASE_DEFENSE)
    def:SetValue(function(e)
        return e:GetHandler():GetCardEffect(id):GetLabelObject()[2]
    end)
    Divine.RegisterEffect(c, def, forced)

    -- life point transfer
    local lp = Effect.CreateEffect(c)
    lp:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    lp:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    lp:SetRange(LOCATION_MZONE)
    lp:SetCode(EVENT_RECOVER)
    lp:SetCondition(function(e, tp, eg, ep)
        return ep == tp
    end)
    lp:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsLocation(LOCATION_MZONE) or c:IsFacedown() or not c:IsHasEffect(id) then
            return
        end

        local eff = c:GetCardEffect(id)
        local label = eff:GetLabelObject()
        label[1] = label[1] + ev
        label[2] = label[2] + ev
        eff:SetLabelObject(label)

        Duel.SetLP(tp, Duel.GetLP(tp) - ev, REASON_EFFECT)
    end)
    if reset then
        lp:SetReset(reset)
    end
    Divine.RegisterEffect(c, lp, forced)
end

function Divine.RegisterRaDefuse(s, c)
    local id = c:GetOriginalCode()

    function DefuseFilter(c)
        return c:IsCode(Divine.CARD_DEFUSION) and not c:IsHasEffect(id)
    end

    function RaDefuseFilter(c, id)
        return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsCode(CARD_RA) and c:IsHasEffect(id)
    end

    aux.GlobalCheck(s, function()
        local defuse = Effect.CreateEffect(c)
        defuse:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        defuse:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        defuse:SetCode(EVENT_ADJUST)
        defuse:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
            return Duel.IsExistingMatchingCard(DefuseFilter, tp, 0xff, 0xff, 1, nil)
        end)
        defuse:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local g = Duel.GetMatchingGroup(DefuseFilter, tp, 0xff, 0xff, nil)
            for tc in aux.Next(g) do
                local eff = Effect.CreateEffect(tc)
                eff:SetType(EFFECT_TYPE_SINGLE)
                eff:SetCode(id)
                tc:RegisterEffect(eff)

                local ec1 = Effect.CreateEffect(tc)
                ec1:SetDescription(666005)
                ec1:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE + CATEGORY_RECOVER)
                ec1:SetType(EFFECT_TYPE_ACTIVATE)
                ec1:SetCode(tc:GetActivateEffect():GetCode())
                ec1:SetProperty(tc:GetActivateEffect():GetProperty() + EFFECT_FLAG_DAMAGE_STEP +
                                    EFFECT_FLAG_IGNORE_IMMUNE)
                ec1:SetHintTiming(TIMING_DAMAGE_STEP, TIMING_DAMAGE_STEP + TIMINGS_CHECK_MONSTER)
                ec1:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
                    if chk == 0 then
                        return Duel.IsExistingTarget(RaDefuseFilter, tp, LOCATION_MZONE, 0, 1, nil, id)
                    end

                    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
                    local tc = Duel.SelectTarget(tp, RaDefuseFilter, tp, LOCATION_MZONE, 0, 1, 1, nil, id):GetFirst()

                    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tc:GetControler(), tc:GetAttack())
                    Duel.SetChainLimit(aux.FALSE)
                end)
                ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
                    local c = e:GetHandler()
                    local tc = Duel.GetFirstTarget()
                    if tc:IsFacedown() or not tc:IsRelateToEffect(e) or not tc:IsHasEffect(id) then
                        return
                    end

                    tc:RegisterFlagEffect(95286165, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END,
                        EFFECT_FLAG_CLIENT_HINT, 1, 0, 666006)

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
                    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
                    ec1:SetValue(0)
                    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
                    Divine.RegisterGrantEffect(tc, ec1)
                    local ec1b = ec1:Clone()
                    ec1b:SetCode(EFFECT_SET_DEFENSE_FINAL)
                    Divine.RegisterGrantEffect(tc, ec1b)
                    Duel.AdjustInstantly(tc)
                    Duel.Recover(tc:GetControler(), atk, REASON_EFFECT)

                    local ec2 = Effect.CreateEffect(c)
                    ec2:SetType(EFFECT_TYPE_SINGLE)
                    ec2:SetCode(EFFECT_CANNOT_TRIGGER)
                    ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
                    tc:RegisterEffect(ec2)

                    local ec3 = Effect.CreateEffect(c)
                    ec3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
                    ec3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
                    ec3:SetCode(EVENT_PHASE + PHASE_END)
                    ec3:SetCountLimit(1)
                    ec3:SetLabelObject(tc)
                    ec3:SetCondition(function(e)
                        return e:GetLabelObject():GetFlagEffect(95286165) ~= 0
                    end)
                    ec3:SetOperation(function(e)
                        Duel.SendtoGrave(e:GetLabelObject(), REASON_EFFECT + REASON_RULE)
                    end)
                    ec3:SetReset(RESET_PHASE + PHASE_END)
                    Duel.RegisterEffect(ec3, tp)
                end)
                tc:RegisterEffect(ec1)
            end
        end)
        Duel.RegisterEffect(defuse, 0)
    end)
end

function DisableEffectFilter(e, c)
    local ec = e:GetOwner()
    return ec ~= c and not ec:IsMonster() and
               (e:GetTarget() == aux.PersistentTargetFilter or not e:IsHasType(EFFECT_TYPE_GRANT + EFFECT_TYPE_FIELD))
end

function ResetEffectFilter(e, c)
    if e:GetOwner() == c then
        return false
    end
    return not e:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) and e:GetCode() ~= EFFECT_SPSUMMON_PROC and
               (e:GetTarget() == aux.PersistentTargetFilter or not e:IsHasType(EFFECT_TYPE_GRANT + EFFECT_TYPE_FIELD))
end
