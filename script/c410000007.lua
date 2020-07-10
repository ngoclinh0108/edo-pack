-- Eraser the Wicked God
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.divine_hierarchy = 1

function s.initial_effect(c)
    Divine.AddProcedure(c, "wicked")
    Divine.ToGraveLimit(c)

    -- atk/def
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SET_BASE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    c:RegisterEffect(e1b)

    -- send to grave
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1val(e, c)
    return Duel.GetFieldGroupCount(c:GetControler(), 0, LOCATION_ONFIELD) * 1000
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetOwner()
    return c:IsPreviousPosition(POS_FACEUP) and
               c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    Duel.SendtoGrave(g, REASON_EFFECT)
end
