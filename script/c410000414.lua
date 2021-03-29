-- Elemental HERO Prime Neos
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_neos.lua")

s.listed_names = {CARD_NEOS, 42015635}
s.listed_series = {0x8, 0x3008, 0x9, 0x1f}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Neos.AddProc(c, {function(tc) return tc:IsLevelAbove(5) end}, nil, true,
                 false)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)

    -- damage (and recover)
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

    -- neos return
    aux.EnableNeosReturn(c, CATEGORY_ATKCHANGE, nil, s.shuffleop)
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
    local bc = e:GetHandler():GetBattleTarget()
    local atk = bc:GetBaseAttack()
    local def = bc:GetBaseDefense()

    if Duel.IsEnvironment(42015635) then
        e:SetCategory(CATEGORY_DAMAGE + CATEGORY_RECOVER)
        Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, atk)
        Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, def)
    else
        e:SetCategory(CATEGORY_DAMAGE)
        Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, atk)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local bc = e:GetHandler():GetBattleTarget()

    local atk = bc:GetAttack()
    local def = bc:GetDefense()
    if atk < 0 then atk = 0 end
    if def < 0 then def = 0 end

    Duel.Damage(1 - tp, atk, REASON_EFFECT)
    Duel.Recover(tp, def, REASON_EFFECT)
end

function s.shuffleop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    for tc in aux.Next(g) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
        ec1:SetValue(0)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
    end
end
