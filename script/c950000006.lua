-- Genesis Omega Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {950000001}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- pendulum summon
    Pendulum.AddProcedure(c)

    -- predraw
    local predraw = Effect.CreateEffect(c)
    predraw:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    predraw:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    predraw:SetCode(EVENT_PREDRAW)
    predraw:SetRange(LOCATION_ALL)
    predraw:SetCountLimit(1)
    predraw:SetTarget(s.predrawtg)
    predraw:SetOperation(s.predrawop)
    c:RegisterEffect(predraw)
end

function s.predrawfilter(c) return c:IsCode(950000001) and c:IsAbleToHand() end

function s.predrawtoextracheck(e)
    local c = e:GetHandler()
    return c:IsLocation(LOCATION_HAND + LOCATION_EXTRA) and not c:IsForbidden()
end

function s.predrawsearchcheck(tp)
    return Duel.IsExistingMatchingCard(s.predrawfilter, tp,
                                       LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
end

function s.predrawtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return s.predrawtoextracheck(e) or s.predrawsearchcheck(tp)
    end

    if s.predrawsearchcheck(tp) then
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                              LOCATION_DECK + LOCATION_GRAVE)
    end
end

function s.predrawop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    if c:IsLocation(LOCATION_HAND + LOCATION_DECK) then
        Duel.SendtoExtraP(c, tp, REASON_EFFECT)
    end

    if Duel.IsTurnPlayer(tp) then
        local g = Duel.GetMatchingGroup(s.predrawfilter, tp,
                                        LOCATION_DECK + LOCATION_GRAVE, 0, nil)
        if #g > 1 then g = g:Select(tp, 1, 1, nil) end
        if #g > 0 then
            Utility.HintCard(id)
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    end
end
