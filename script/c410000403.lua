-- Elemental HERO Prime Neos
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_neos.lua")

s.listed_names = {CARD_NEOS}
s.listed_series = {0x8, 0x3008, 0x9, 0x1f}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Neos.AddProc(c, {
        function(tc)
            return tc:IsType(TYPE_EFFECT) and tc:IsLevelBelow(5) and
                       not tc:IsSetCard(0x1f)
        end
    }, function(g, tp, c)
        c:RegisterFlagEffect(id,
                             RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD +
                                 RESET_PHASE + PHASE_END,
                             EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 0))
    end, true, false)

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
    e2:SetDescription(aux.Stringid(id, 1))
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
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and
               (c:IsSetCard(0x1f) or c:IsSetCard(0x8))
end
function s.e1val(e, c)
    return Duel.GetMatchingGroupCount(s.e1filter, c:GetControler(),
                                      LOCATION_GRAVE, 0, nil) * 300
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

function s.e3filter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               (c:IsCode(CARD_NEOS) or c:IsSetCard(0x1f))
end

function s.e3check(g, e, tp) return g:GetClassCount(Card.GetCode) == #g end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToExtraAsCost() end
    Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local loc = LOCATION_HAND + LOCATION_GRAVE + LOCATION_DECK
    local g = Duel.GetMatchingGroup(s.e3filter, tp, loc, 0, nil, e, tp)

    if chk == 0 then
        return c:GetFlagEffect(id) == 0 and
                   Duel.IsPlayerCanSpecialSummonCount(tp, 2) and
                   not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 1 and
                   aux.SelectUnselectGroup(g, e, tp, 2, 2, s.e3check, 0)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, loc)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) or
        Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 then return end

    local c = e:GetHandler()
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e3filter), tp, loc,
                                    0, nil, e, tp)
    g = aux.SelectUnselectGroup(g, e, tp, 2, 2, s.e3check, 1, tp,
                                HINTMSG_SPSUMMON)
    if #g ~= 2 then return end

    for tc in aux.Next(g) do
        if Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetDescription(3206)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            ec1:SetCode(EFFECT_CANNOT_ATTACK)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(ec1)
            local ec2 = ec1:Clone()
            ec2:SetDescription(3302)
            ec2:SetCode(EFFECT_CANNOT_TRIGGER)
            tc:RegisterEffect(ec2)
        end
    end
    Duel.SpecialSummonComplete()
end
