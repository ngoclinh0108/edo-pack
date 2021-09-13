-- init
if not aux.UtilPendulumProcedure then aux.UtilPendulumProcedure = {} end
if not UtilPendulum then UtilPendulum = aux.UtilPendulumProcedure end

-- function
function UtilPendulum.CountFreePendulumZones(tp)
    local count = 0
    if Duel.CheckLocation(tp, LOCATION_PZONE, 0) then count = count + 1 end
    if Duel.CheckLocation(tp, LOCATION_PZONE, 1) then count = count + 1 end
    return count
end

function UtilPendulum.PlaceToPZoneWhenDestroyed(c, tg, preop, postop)
    local eff = Effect.CreateEffect(c)
    eff:SetDescription(1160)
    eff:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    eff:SetProperty(EFFECT_FLAG_DELAY)
    eff:SetCode(EVENT_DESTROYED)
    eff:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and
                   e:GetHandler():IsFaceup()
    end)
    eff:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if tg then
            return tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
        else
            if chk == 0 then
                return Duel.CheckLocation(tp, LOCATION_PZONE, 0) or
                           Duel.CheckLocation(tp, LOCATION_PZONE, 1)
            end
        end
    end)
    eff:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if preop then preop(e, tp, eg, ep, ev, re, r, rp) end

        local c = e:GetHandler()
        if not c:IsRelateToEffect(e) then return end
        if not Duel.CheckLocation(tp, LOCATION_PZONE, 0) and
            not Duel.CheckLocation(tp, LOCATION_PZONE, 1) then
            return false
        end
        Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true)

        if postop then postop(e, tp, eg, ep, ev, re, r, rp) end
    end)
    c:RegisterEffect(eff)
end
