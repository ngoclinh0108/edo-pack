-- Supreme King Dragon Grimwurm
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x10f8, 0x20f8}

function s.initial_effect(c)
    -- pendulum summon
    Pendulum.AddProcedure(c)

    -- add to your hand
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 1))
    me1:SetCategory(CATEGORY_TOHAND)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    me1:SetCode(EVENT_SUMMON_SUCCESS)
    me1:SetCountLimit(1, id + 1 * 1000000)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)
    local me1b = me1:Clone()
    me1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(me1b)
end

function s.me1filter(c)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return ((c:IsSetCard(0x10f8) and c:IsType(TYPE_PENDULUM)) or
               (c:IsSetCard(0x20f8) and c:IsType(TYPE_MONSTER))) and
               c:IsFaceup() and c:IsAbleToHand()
end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.me1filter, tp, LOCATION_DECK +
                                               LOCATION_GRAVE + LOCATION_EXTRA,
                                           0, 1, nil)
    end
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.me1filter, tp, LOCATION_DECK +
                                          LOCATION_GRAVE + LOCATION_EXTRA, 0, 1,
                                      1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
