-- Elemental HERO Steam Neos
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_neos.lua")

s.listed_names = {CARD_NEOS, 89621922, 17955766, 42015635}
s.material_setcode = {0x8, 0x3008, 0x9, 0x1f}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Neos.AddProc(c, 89621922, 17955766, nil, true, false)

    -- indes & untargetable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1b:SetValue(aux.tgoval)
    c:RegisterEffect(e1b)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.e2val)
    c:RegisterEffect(e2)

    -- act limit
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_CANNOT_ACTIVATE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0, 1)
    e3:SetCondition(s.e3con)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- negate
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- neos return
    aux.EnableNeosReturn(c, CATEGORY_TOGRAVE, s.retinfo, s.retop)
end

function s.e2val(e, c)
    return Duel.GetFieldGroupCount(0, LOCATION_ONFIELD, LOCATION_ONFIELD) * 400
end

function s.e3con(e) return Duel.GetAttacker() == e:GetHandler() end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and
               Duel.IsChainNegatable(ev) and ep == 1 - tp and
               (Duel.GetTurnPlayer() == tp or Duel.IsEnvironment(42015635))
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)

    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
    end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and
        Duel.Destroy(eg, REASON_EFFECT) ~= 0 and c:IsRelateToEffect(e) and
        c:IsFaceup() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(1000)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
        c:RegisterEffect(ec1)
    end
end

function s.retinfo(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsAbleToGrave, tp, LOCATION_ONFIELD,
                                    LOCATION_ONFIELD, 1, 1, c, tp)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, #g, 0, 0)
end

function s.retop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsAbleToGrave, tp, LOCATION_ONFIELD,
                                    LOCATION_ONFIELD, 1, 1, nil, tp)
    Duel.SendtoGrave(g, REASON_EFFECT)
end
