-- Blue-Eyes Savior Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0xdd}
s.listed_names = {CARD_BLUEEYES_W_DRAGON}
s.listed_series = {0xdd}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, aux.FilterBoolFunction(Card.IsSetCard, 0xdd), 8, 2,
                     s.ovfilter, aux.Stringid(id, 0), 2)

    -- atk/def
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- destroy replace
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.e2tg)
    e2:SetValue(s.e2val)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.ovfilter(c, tp, lc)
    return c:IsFaceup() and c:IsCode(CARD_BLUEEYES_W_DRAGON)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end

    local atk = 0
    local mg = c:GetMaterial()
    for tc in aux.Next(mg) do
        if tc:IsRace(RACE_DRAGON) and tc:GetTextAttack() > 0 then
            atk = atk + tc:GetTextAttack()
        end
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
    c:RegisterEffect(ec1)
end

function s.e2filter(c, tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and
               c:IsReason(REASON_BATTLE + REASON_EFFECT) and
               not c:IsReason(REASON_REPLACE)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return eg:IsExists(s.e2filter, 1, nil, tp) and
                   c:CheckRemoveOverlayCard(tp, 1, REASON_EFFECT)
    end

    if Duel.SelectEffectYesNo(tp, c, 96) then
        c:RemoveOverlayCard(tp, 1, 1, REASON_EFFECT)
        return true
    else
        return false
    end
end

function s.e2val(e, c) return s.e2filter(c, e:GetHandlerPlayer()) end

function s.e3filter1(c, tp)
    return not c:IsCode(id) and c:IsPreviousSetCard(0xdd) and
               c:IsPreviousControler(tp) and
               c:IsPreviousLocation(LOCATION_MZONE) and
               c:IsPreviousPosition(POS_FACEUP) and
               (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and
                   c:GetReasonPlayer() ~= tp)
end

function s.e3filter2(c) return tc:IsRace(RACE_DRAGON) end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e3filter1, 1, nil, tp)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
                   Duel.IsExistingMatchingCard(Card.IsRace, tp, LOCATION_GRAVE,
                                               0, 1, nil, RACE_DRAGON)
    end

    local g = Duel.GetMatchingGroup(Card.IsRace, tp, LOCATION_GRAVE, 0, nil,
                                    RACE_DRAGON)
    local dmg = g:GetClassCount(Card.GetCode) * 800

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) ~= 0 then
        local dmg = Duel.GetMatchingGroup(Card.IsRace, tp, LOCATION_GRAVE, 0,
                                          nil, RACE_DRAGON):GetClassCount(
                        Card.GetCode) * 800
        Duel.Damage(1 - tp, dmg, REASON_EFFECT)

        local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e3filter2), tp,
                                        LOCATION_GRAVE, 0, nil)
        if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
            Duel.BreakEffect()

            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
            local mg = g:Select(tp, 1, 1, nil)
            Duel.Overlay(c, mg)
        end
    end
end
