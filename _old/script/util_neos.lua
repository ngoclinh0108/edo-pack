-- init
if not aux.NeosProcedure then aux.NeosProcedure = {} end
if not Neos then Neos = aux.NeosProcedure end

-- function
function Neos.AddProc(c, insf1, insf2, op, splimit, return_extra)
    -- fusion material
    Fusion.AddProcMix(c, true, true, CARD_NEOS, insf1, insf2)
    Fusion.AddContactProc(c, function(tp)
        return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp,
                                     LOCATION_ONFIELD, 0, nil)
    end, function(g, tp, sc)
        Duel.ConfirmCards(1 - tp, g)
        Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST + REASON_MATERIAL)
        if op then op(g, tp, sc) end
    end, splimit and function(e, se, sp, st)
        if e:GetHandler():IsLocation(LOCATION_EXTRA) then
            return (st & SUMMON_TYPE_FUSION) == SUMMON_TYPE_FUSION
        end
        return true
    end or nil)

    -- return to extra deck during end phase
    if return_extra then aux.EnableNeosReturn(c) end
end
