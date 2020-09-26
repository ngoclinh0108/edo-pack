-- Palladium Oracle Mahad - Sacred Wizard
local s, id = GetID()

s.listed_names = {CARD_DARK_MAGICIAN}

function s.initial_effect(c)
    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(CARD_DARK_MAGICIAN)
    c:RegisterEffect(code)

    -- normal monster
    local normal = Effect.CreateEffect(c)
    normal:SetType(EFFECT_TYPE_SINGLE)
    normal:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    normal:SetCode(EFFECT_ADD_TYPE)
    normal:SetValue(TYPE_NORMAL)
    c:RegisterEffect(normal)
    local normalb = normal:Clone()
    normalb:SetCode(EFFECT_REMOVE_TYPE)
    normalb:SetValue(TYPE_EFFECT)
    c:RegisterEffect(normalb)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetRange(LOCATION_HAND)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_SET_ATTACK_FINAL)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetValue(s.e2val)
    c:RegisterEffect(e2)

     -- act quick spell/trap in hand
     local e3 = Effect.CreateEffect(c)
     e3:SetType(EFFECT_TYPE_FIELD)
     e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
     e3:SetRange(LOCATION_MZONE)
     e3:SetTargetRange(LOCATION_HAND, 0)
     e3:SetCountLimit(1, id)
     e3:SetCondition(s.e3con)
     c:RegisterEffect(e3)
     local e3b = e3:Clone()
     e3b:SetCode(EFFECT_TRAP_ACT_IN_HAND)
     c:RegisterEffect(e3b)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return not e:GetHandler():IsPublic() end
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsRelateToEffect(e) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e2con(e)
    local ph = Duel.GetCurrentPhase()
    local bc = e:GetHandler():GetBattleTarget()
    return (ph == PHASE_DAMAGE or ph == PHASE_DAMAGE_CAL) and bc and
               bc:IsAttribute(ATTRIBUTE_DARK)
end

function s.e2val(e, c) return e:GetHandler():GetAttack() * 2 end

function s.e3con(e) return Duel.GetTurnPlayer() ~= e:GetHandlerPlayer() end