-- Stardust Converging Maiden
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

s.listed_names = {CARD_STARDUST_DRAGON}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synhcro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 99)

    -- add card
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, {id, 1})
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon dragon
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    return c:IsAbleToHand() and aux.IsCodeListed(c, CARD_STARDUST_DRAGON)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, aux.NecroValleyFilter(s.e1filter), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
        nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e2filter(c, e, tp)
    return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and not c:IsCode(id) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 2))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT + EFFECT_FLAG_OATH)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, c, sump, sumtype, sumpos, targetp, se)
        return c:IsLocation(LOCATION_EXTRA) and not (c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON))
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then
        return
    end

    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.e2filter), tp,
        LOCATION_GRAVE + LOCATION_HAND, 0, 1, 1, nil, e, tp):GetFirst()
    if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) ~= 0 and
        Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_LVRANK)
        local lv = Duel.AnnounceLevel(tp, 1, 12, tc:GetLevel())

        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec2:SetCode(EFFECT_CHANGE_LEVEL)
        ec2:SetValue(lv)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
    end
end
