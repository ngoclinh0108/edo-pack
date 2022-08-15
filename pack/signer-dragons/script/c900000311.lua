-- Ultimaya Life Stream Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synhcro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 99)

    -- add code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(SignerDragon.CARD_LIFE_STREAM_DRAGON)
    c:RegisterEffect(code)

    -- change lp
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- damage reduce
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CHANGE_DAMAGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(1, 0)
    e2:SetValue(function(e, re, val, r, rp, rc)
        if r & REASON_EFFECT ~= 0 then
            return 0
        end
        return val
    end)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    c:RegisterEffect(e2b)

    -- to hand
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- synchro level
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e4:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:GetMaterial():IsExists(Card.IsType, 1, nil, TYPE_SYNCHRO)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.SetLP(tp, 8000)
end

function s.e3filter(c)
    return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.e3filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e4op(e, tg, ntg, sg, lv, sc, tp)
    local check1 = #sg - 1 + e:GetHandler():GetLevel() == lv
    local check2 = (#sg - 1) * 2 + e:GetHandler():GetLevel() == lv
    return check1 or check2, true
end
