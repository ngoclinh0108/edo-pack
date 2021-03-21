-- Elemental HERO Shining Neos
local s, id = GetID()
Duel.LoadScript("util.lua")

s.listed_names = {CARD_NEOS}
s.material_setcode = {0x8, 0x3008, 0x9}
s.listed_series = {0x1f, 0x8}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Fusion.AddProcMix(c, true, true, CARD_NEOS,
                      aux.FilterBoolFunctionEx(Card.IsType, TYPE_EFFECT))
    Fusion.AddContactProc(c, s.contactfilter, s.contactop, s.splimit)

    -- special summon condition
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        if e:GetHandler():IsLocation(LOCATION_EXTRA) then
            return (st & SUMMON_TYPE_FUSION) == SUMMON_TYPE_FUSION
        end
        return true
    end)
    c:RegisterEffect(splimit)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)

    -- damage
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCondition(aux.bdcon)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.contactfilter(tp)
    return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp,
                                 LOCATION_ONFIELD, 0, nil)
end

function s.contactop(g, tp)
    Duel.ConfirmCards(1 - tp, g)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST + REASON_MATERIAL)
end

function s.e1filter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and
               (c:IsSetCard(0x1f) or c:IsSetCard(0x8))
end
function s.e1val(e, c)
    return Duel.GetMatchingGroupCount(s.e1filter, c:GetControler(),
                                      LOCATION_GRAVE, 0, nil) * 200
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local dmg = e:GetHandler():GetBattleTarget():GetBaseAttack()
    if dmg < 0 then dmg = 0 end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end

function s.e3filter1(c, e, tp)
    return c:IsCode(CARD_NEOS) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e3filter2(c, e, tp)
    return c:IsSetCard(0x1f) and c:IsType(TYPE_MONSTER) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return Duel.IsMainPhase() end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToExtraAsCost() end
    Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 1 and
                   not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and
                   Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_HAND +
                                                   LOCATION_DECK +
                                                   LOCATION_GRAVE, 0, 1, nil, e,
                                               tp) and
                   Duel.IsExistingMatchingCard(s.e3filter2, tp, LOCATION_HAND +
                                                   LOCATION_DECK +
                                                   LOCATION_GRAVE, 0, 1, nil, e,
                                               tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp,
                          LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 or
        Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.e3filter1, tp, LOCATION_HAND +
                                          LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                      1, nil, e, tp)
    g:Merge(Duel.SelectMatchingCard(tp, s.e3filter2, tp, LOCATION_HAND +
                                        LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                    nil, e, tp))
    if #g ~= 2 then return end

    for tc in aux.Next(g) do
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1, true)
        local ec2 = ec1:Clone()
        ec2:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(ec2, true)
    end
end
