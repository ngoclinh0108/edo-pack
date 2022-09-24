-- The Descent Sun God
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_RA}

function s.initial_effect(c)
    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                                                    EFFECT_FLAG_CANNOT_INACTIVATE

    -- activate
    local act = Effect.CreateEffect(c)
    act:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SPECIAL_SUMMON)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetCountLimit(1, {id, 1})
    act:SetTarget(s.acttg)
    act:SetOperation(s.actop)
    c:RegisterEffect(act)
end

function s.acttg(e, tp, eg, ep, ev, re, r, rp, chk)
    local check1 = Duel.GetMatchingGroupCount(s.eff1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, nil) > 0
    local check2 = Duel.GetMatchingGroupCount(s.eff2filter1, tp, LOCATION_HAND, 0, nil, e, tp) > 0
    if chk == 0 then
        return check1 or check2
    end

    local op = Duel.SelectEffect(tp, {check1, aux.Stringid(id, 0)}, {check2, aux.Stringid(id, 1)})
    e:SetLabel(op)

    if op == 1 then
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
    else
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND)
    end
end

function s.actop(e, tp, eg, ep, ev, re, r, rp)
    if e:GetLabel() == 1 then
        s.eff1op(e, tp, eg, ep, ev, re, r, rp)
    else
        s.eff2op(e, tp, eg, ep, ev, re, r, rp)
    end
end

function s.eff1filter(c)
    return c:IsSpellTrap() and c:ListsCode(CARD_RA) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.eff1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.eff1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.eff2filter1(c, e, tp)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local check1 = Duel.CheckReleaseGroup(tp, s.eff2filter2, 3, nil, ft, tp)
    local check2 = ft > 0 and
                       Duel.CheckReleaseGroup(tp, Card.IsControler, 3, false, 3, false, nil, tp, 0xff, true, nil, 1 - tp)
    return c:IsCode(CARD_RA) and c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and (check1 or check2)
end

function s.eff2filter2(c, ft, tp)
    return ft > 0 or (c:IsControler(tp) and c:GetSequence() < 5)
end

function s.eff2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local check1 = Duel.CheckReleaseGroup(tp, s.eff2filter1, 3, nil, ft, tp)
    local check2 = ft > 0 and
                       Duel.CheckReleaseGroup(tp, Card.IsControler, 3, false, 3, false, nil, tp, 0xff, true, nil, 1 - tp)

    local op = Duel.SelectEffect(tp, {check1, aux.Stringid(id, 2)}, {check2, aux.Stringid(id, 3)})
    local g = Group.CreateGroup()
    if op == 1 then
        g = Duel.SelectReleaseGroup(tp, s.e1filter1, 3, 3, nil, ft, tp)
    else
        g = Duel.SelectReleaseGroup(tp, Card.IsControler, 3, 3, false, false, true, c, tp, 0xff, true, nil, 1 - tp)
    end

    local tc =
        Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e1filter2, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp):GetFirst()
    if tc and Duel.Release(g, REASON_EFFECT) == 3 and Duel.SpecialSummonStep(tc, 0, tp, tp, true, false, POS_FACEUP) then
        local atk = 0
        local def = 0
        for mc in aux.Next(g) do
            atk = atk + mc:GetAttack()
            def = def + mc:GetDefense()
        end

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_SET_BASE_ATTACK)
        ec1:SetValue(atk)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
        ec1b:SetValue(def)
        tc:RegisterEffect(ec1b)
    end
    Duel.SpecialSummonComplete()
end
