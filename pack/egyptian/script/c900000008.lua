-- The Descent Sun God
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_RA}

function s.initial_effect(c)
    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                                                    EFFECT_FLAG_CANNOT_INACTIVATE

    -- special summon ra
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, {id, 0})
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter1(c, ft, tp)
    return ft > 0 or (c:IsControler(tp) and c:GetSequence() < 5)
end

function s.e1filter2(c, e, tp)
    return c:IsCode(CARD_RA) and c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local check1 = Duel.CheckReleaseGroup(tp, s.e1filter1, 3, nil, ft, tp)
    local check2 = ft > 0 and Duel.CheckReleaseGroup(1 - tp, nil, 3, nil)

    if chk == 0 then
        return (check1 or check2) and Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_HAND, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local check1 = Duel.CheckReleaseGroup(tp, s.e1filter1, 3, nil, ft, tp)
    local check2 = ft > 0 and Duel.CheckReleaseGroup(1 - tp, nil, 3, nil)

    local opt = {}
    local sel = {}
    if check1 then
        table.insert(sel, 1)
        table.insert(opt, aux.Stringid(id, 1))
    end
    if check2 then
        table.insert(sel, 2)
        table.insert(opt, aux.Stringid(id, 2))
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EFFECT)
    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]

    local g = Group.CreateGroup()
    if op == 1 then
        g = Duel.SelectReleaseGroup(tp, s.e1filter1, 3, 3, nil, ft, tp)
    else
        g = Duel.SelectReleaseGroup(1 - tp, nil, 3, 3, nil)
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
