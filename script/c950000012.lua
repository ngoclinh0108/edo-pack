-- Starving Venom Magician
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x1050, 0x50}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon procedure
    Fusion.AddProcMixN(c, true, true,
                       aux.FilterBoolFunctionEx(Card.IsType, TYPE_PENDULUM), 2)

    -- pendulum
    Pendulum.AddProcedure(c, false)
    Utility.PlaceToPZoneWhenDestroyed(c)

    -- fusion summon
    local pe1params = {
        nil, Fusion.CheckWithHandler(function(c)
            return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_FUSION) and
                       c:IsOnField() and c:IsAbleToGrave()
        end), function(e) return Group.FromCards(e:GetHandler()) end, nil,
        Fusion.ForcedHandler
    }
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(1170)
    pe1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1)
    pe1:SetTarget(Fusion.SummonEffTG(table.unpack(pe1params)))
    pe1:SetOperation(Fusion.SummonEffOP(table.unpack(pe1params)))
    c:RegisterEffect(pe1)

    -- fusion substitute
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    me1:SetCode(EFFECT_FUSION_SUBSTITUTE)
    me1:SetCondition(function(e)
        local c = e:GetHandler()
        if c:IsLocation(LOCATION_REMOVED + LOCATION_EXTRA) and c:IsFacedown() then
            return false
        end
        return c:IsLocation(
                   LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED +
                       LOCATION_EXTRA)
    end)
    c:RegisterEffect(me1)

    -- damage
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 0))
    me2:SetCategory(CATEGORY_DAMAGE)
    me2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    me2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP +
                        EFFECT_FLAG_PLAYER_TARGET)
    me2:SetCode(EVENT_DESTROYED)
    me2:SetRange(LOCATION_MZONE)
    me2:SetCountLimit(1, id)
    me2:SetCondition(s.me2con)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)
end

function s.me2filter(c, tp)
    return c:IsPreviousLocation(LOCATION_ONFIELD) and
               not c:IsPreviousControler(tp) and
               c:IsReason(REASON_BATTLE + REASON_EFFECT)
end

function s.me2con(e, tp, eg, ep, ev, re, r, rp)
    local rc = re:GetOwner()
    return rc:IsOriginalSetCard(0x1050) and rc:IsRace(RACE_DRAGON) and
               eg:IsExists(s.me2filter, 1, nil, tp)
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local dmg = 0
    local g = eg:Filter(s.me2filter, nil, tp)
    for tc in aux.Next(g) do
        if tc:GetBaseAttack() > 0 then dmg = dmg + tc:GetBaseAttack() end
    end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end
