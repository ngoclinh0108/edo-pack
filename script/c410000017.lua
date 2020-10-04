-- Palladium Chaos Oracle Aknamkanon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {410000025}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(30208479)
    c:RegisterEffect(code)

    -- attribute
    local attribute = Effect.CreateEffect(c)
    attribute:SetType(EFFECT_TYPE_SINGLE)
    attribute:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    attribute:SetCode(EFFECT_ADD_ATTRIBUTE)
    attribute:SetValue(ATTRIBUTE_LIGHT)
    c:RegisterEffect(attribute)

    -- search
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- change attribute
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, LOCATION_MZONE)
    e2:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e2)

    -- cannot be target
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE, 0)
    e3:SetTarget(function(e, c) return c:IsRace(RACE_SPELLCASTER) end)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)

    -- banish
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(1107)
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_BATTLED)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- search spell/trap
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetCategory(CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_PHASE + PHASE_END)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1, id)
    e5:SetCost(s.e5cost)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
    aux.GlobalCheck(s, function()
        local e5reg = Effect.CreateEffect(c)
        e5reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e5reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e5reg:SetCode(EVENT_SUMMON_SUCCESS)
        e5reg:SetLabel(id)
        e5reg:SetOperation(aux.sumreg)
        Duel.RegisterEffect(e5reg, 0)
        local e5regb = e5reg:Clone()
        e5regb:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
        Duel.RegisterEffect(e5regb, 0)
        local e5regc = e5reg:Clone()
        e5regc:SetCode(EVENT_SPSUMMON_SUCCESS)
        Duel.RegisterEffect(e5regc, 0)
    end)
end

function s.e1filter(c)
    return c:IsAbleToHand() and not c:IsType(TYPE_RITUAL) and
               c:IsAttribute(ATTRIBUTE_LIGHT + ATTRIBUTE_DARK) and
               c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(8)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDiscardable() end

    Duel.SendtoGrave(c, REASON_COST + REASON_DISCARD)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(s.e1filter, tp,
                                    LOCATION_DECK + LOCATION_GRAVE, 0, nil)
    if #g > 1 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        g = g:Select(tp, 1, 1, nil)
    end

    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    e:SetLabelObject(bc)

    return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and
               c:IsStatus(STATUS_OPPO_BATTLE)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, e:GetLabelObject(), 1, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local bc = e:GetLabelObject()
    if not bc:IsRelateToBattle() or not bc:IsAbleToRemove() then return end

    Duel.Remove(bc, POS_FACEUP, REASON_EFFECT)
end

function s.e5filter(c)
    return c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsAbleToHand()
end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetFlagEffect(id) ~= 0 end
    c:ResetFlagEffect(id)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e5filter, tp,
                                     LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, 0)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.e5filter, tp,
                                      LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                      nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
