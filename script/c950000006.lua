-- Genesis Omega Dragon Z-ARC
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {950000001}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- pendulum summon
    Pendulum.AddProcedure(c)

    -- to grave
    local toextra = Effect.CreateEffect(c)
    toextra:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    toextra:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    toextra:SetCode(EVENT_PREDRAW)
    toextra:SetRange(LOCATION_HAND + LOCATION_DECK)
    toextra:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return not e:GetHandler():IsForbidden() end
    end)
    toextra:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsRelateToEffect(e) and
            not c:IsLocation(LOCATION_HAND + LOCATION_DECK) then return end
        Utility.HintCard(id)
        Duel.SendtoExtraP(c, tp, REASON_EFFECT)
    end)
    c:RegisterEffect(toextra)

    -- search supreme soul
    local searchsoul = Effect.CreateEffect(c)
    searchsoul:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    searchsoul:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    searchsoul:SetCode(EVENT_PREDRAW)
    searchsoul:SetRange(LOCATION_EXTRA)
    searchsoul:SetCountLimit(1)
    searchsoul:SetCondition(function(e, tp)
        return e:GetHandler():IsFaceup() and Duel.IsTurnPlayer(tp)
    end)
    searchsoul:SetTarget(s.searchsoultg)
    searchsoul:SetOperation(s.searchsoulop)
    c:RegisterEffect(searchsoul)
end

function s.searchsoulfilter(c) return c:IsCode(950000001) and c:IsAbleToHand() end

function s.searchsoultg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.searchsoulfilter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.searchsoulop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.searchsoulfilter, tp,
                                    LOCATION_DECK + LOCATION_GRAVE, 0, nil)
    if #g > 1 then g = g:Select(tp, 1, 1, nil) end

    if #g > 0 then
        Utility.HintCard(id)
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
