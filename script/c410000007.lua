-- Eraser the Wicked God
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.divine_hierarchy = 1

function s.initial_effect(c)
    Divine.AddProcedure(c, "wicked")
    Divine.ToGraveLimit(c)

    -- attribute & race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_ATTRIBUTE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_ADD_RACE)
    e1b:SetValue(RACE_FIEND)
    c:RegisterEffect(e1b)
    
    -- atk/def
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_SET_BASE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.e2val)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_SET_BASE_DEFENSE)
    c:RegisterEffect(e2b)

    -- send to grave
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2val(e, c)
    return Duel.GetFieldGroupCount(c:GetControler(), 0, LOCATION_ONFIELD) * 1000
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()
    return c:IsPreviousPosition(POS_FACEUP) and
               c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    Duel.SendtoGrave(g, REASON_EFFECT)
end
