-- Palladium Reborn
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_RA}
s.listed_series = {0x13a}

function s.initial_effect(c)
    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(83764718)
    c:RegisterEffect(code)

    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1check1(c) return c:IsAbleToHand() end

function s.e1check2(c, e, tp)
    local isRa = c:IsOriginalCode(CARD_RA) and true or false
    if not c:IsCanBeSpecialSummoned(e, 0, tp, isRa, false) or
        (c:IsLocation(LOCATION_EXTRA) and c:IsFacedown()) then return false end

    if (c:IsLocation(LOCATION_EXTRA)) then
        return Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0
    else
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    end

end

function s.e1filter(c, e, tp)
    return c:IsType(TYPE_MONSTER) and (s.e1check1(c) or s.e1check2(c, e, tp))
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp,
                                           LOCATION_GRAVE + LOCATION_EXTRA,
                                           LOCATION_GRAVE + LOCATION_EXTRA, 1,
                                           nil, e, tp)
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e1filter), tp,
                                    LOCATION_GRAVE + LOCATION_EXTRA,
                                    LOCATION_GRAVE + LOCATION_EXTRA, nil, e, tp)
    if #g == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
    local sc = g:Select(tp, 1, 1, nil):GetFirst()

    local b1 = s.e1check1(sc)
    local b2 = s.e1check2(sc, e, tp)
    local op = 0
    if b1 and b2 then
        op = Duel.SelectOption(tp, 573, 5)
    elseif b1 then
        op = Duel.SelectOption(tp, 573)
    else
        op = Duel.SelectOption(tp, 5) + 1
    end

    if op == 0 then
        Duel.SendtoHand(sc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sc)
    else
        local isRa = c:IsOriginalCode(CARD_RA) and true or false
        Duel.SpecialSummon(sc, 0, tp, tp, isRa, false, POS_FACEUP)

        if not sc:IsSetCard(0x13a) then
            sc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD +
                                      RESET_PHASE + PHASE_END,
                                  EFFECT_FLAG_CLIENT_HINT, 1, 0,
                                  aux.Stringid(id, 0))

            local ec1 = Effect.CreateEffect(c)
            ec1:SetDescription(666000)
            ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
            ec1:SetCode(EVENT_PHASE + PHASE_END)
            ec1:SetCountLimit(1)
            ec1:SetOperation(s.e1gyop)
            ec1:SetReset(RESET_PHASE + PHASE_END)
            Duel.RegisterEffect(ec1, tp)
        end
    end
end

function s.e1gyop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(function(c)
        return c:GetFlagEffect(id) ~= 0
    end, tp, LOCATION_MZONE, 0, nil)
    if #g > 0 then Duel.SendtoGrave(g, REASON_EFFECT) end
end
