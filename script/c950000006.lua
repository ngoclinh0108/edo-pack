-- Supreme Overlord Z-ARC
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_DRAGON), 4,
                      4, s.lnkcheck)

    -- pendulum
    Pendulum.AddProcedure(c, false)
    Utility.PlaceToPZoneWhenDestroyed(c,
                                      function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return true end
        local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_PZONE, 0,
                                        nil)
        if #g > 0 then
            Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
        end
    end, function(e, tp, eg, ep, ev, re, r, rp)
        local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_PZONE, 0,
                                        nil)
        if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
    end)

    -- overscale
    local pensp = Effect.CreateEffect(c)
    pensp:SetType(EFFECT_TYPE_SINGLE)
    pensp:SetCode(511004423)
    c:RegisterEffect(pensp)
    
    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return (st & SUMMON_TYPE_LINK) == SUMMON_TYPE_LINK or
                   (st & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM
    end)
    c:RegisterEffect(splimit)

    -- summon cannot be negated
    local nospnegate = Effect.CreateEffect(c)
    nospnegate:SetType(EFFECT_TYPE_SINGLE)
    nospnegate:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nospnegate:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(nospnegate)

    -- activation and effects cannot be negated
    local inact = Effect.CreateEffect(c)
    inact:SetType(EFFECT_TYPE_FIELD)
    inact:SetCode(EFFECT_CANNOT_INACTIVATE)
    inact:SetRange(LOCATION_MZONE)
    inact:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(inact)
    local inact2 = inact:Clone()
    inact2:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(inact2)
    local nodis = Effect.CreateEffect(c)
    nodis:SetType(EFFECT_TYPE_SINGLE)
    nodis:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    nodis:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nodis)

    -- cannot be switch control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- cannot be tributed or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc, tp, sumtp)
        return tc == e:GetHandler()
    end)
    c:RegisterEffect(norelease)
    local nofus = Effect.CreateEffect(c)
    nofus:SetType(EFFECT_TYPE_SINGLE)
    nofus:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    nofus:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    nofus:SetRange(LOCATION_MZONE)
    nofus:SetValue(function(e, tc)
        if not tc then return false end
        return tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(nofus)
    local nosync = nofus:Clone()
    nosync:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    c:RegisterEffect(nosync)
    local noxyz = nofus:Clone()
    noxyz:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    c:RegisterEffect(noxyz)
    local nolnk = nofus:Clone()
    nolnk:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    c:RegisterEffect(nolnk)

    -- indestructable by card effect
    local indes = Effect.CreateEffect(c)
    indes:SetType(EFFECT_TYPE_SINGLE)
    indes:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    indes:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    indes:SetRange(LOCATION_MZONE)
    indes:SetValue(1)
    c:RegisterEffect(indes)

    -- cannot be targeted
    local untarget = Effect.CreateEffect(c)
    untarget:SetType(EFFECT_TYPE_SINGLE)
    untarget:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    untarget:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    untarget:SetRange(LOCATION_MZONE)
    untarget:SetValue(aux.tgoval)
    c:RegisterEffect(untarget)

    -- immune
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_SINGLE)
    pe1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    pe1:SetCode(EFFECT_IMMUNE_EFFECT)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetValue(function(e, te)
        return te:GetOwnerPlayer() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(pe1)
    
    -- double ATK (pendulum)
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 1))
    pe2:SetCategory(CATEGORY_ATKCHANGE)
    pe2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    pe2:SetCode(EVENT_BATTLE_CONFIRM)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1)
    pe2:SetCondition(s.pe2con)
    pe2:SetCost(s.pe2cost)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- act limit
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_FIELD)
    me1:SetCode(EFFECT_CANNOT_ACTIVATE)
    me1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    me1:SetRange(LOCATION_PZONE)
    me1:SetTargetRange(0, 1)
    me1:SetValue(s.me1val)
    c:RegisterEffect(me1)

    -- unstoppable attack
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_SINGLE)
    me2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    me2:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    me2:SetRange(LOCATION_MZONE)
    c:RegisterEffect(me2)

    -- attack all monsters
    local me3 = Effect.CreateEffect(c)
    me3:SetType(EFFECT_TYPE_SINGLE)
    me3:SetCode(EFFECT_ATTACK_ALL)
    me3:SetValue(1)
    c:RegisterEffect(me3)

    -- destroy drawn
    local me4 = Effect.CreateEffect(c)
    me4:SetDescription(aux.Stringid(id, 0))
    me4:SetCategory(CATEGORY_DESTROY)
    me4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    me4:SetCode(EVENT_TO_HAND)
    me4:SetRange(LOCATION_MZONE)
    me4:SetCountLimit(1)
    me4:SetCondition(s.me4con)
    me4:SetTarget(s.me4tg)
    me4:SetOperation(s.me4op)
    c:RegisterEffect(me4)

    -- double ATK (monster)
    local me5 = Effect.CreateEffect(c)
    me5:SetDescription(aux.Stringid(id, 1))
    me5:SetCategory(CATEGORY_ATKCHANGE)
    me5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    me5:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    me5:SetRange(LOCATION_MZONE)
    me5:SetCountLimit(1)
    me5:SetCondition(s.me5con)
    me5:SetOperation(s.me5op)
    c:RegisterEffect(me5)
end

function s.lnkcheck(g, sc, sumtype, tp)
    local mg = g:Clone()
    if not g:IsExists(Card.IsType, 1, nil, TYPE_FUSION, sc, sumtype, tp) then
        return false
    end
    mg:Remove(Card.IsType, nil, TYPE_FUSION, sc, sumtype, tp)
    if not g:IsExists(Card.IsType, 1, nil, TYPE_SYNCHRO, sc, sumtype, tp) then
        return false
    end
    mg:Remove(Card.IsType, nil, TYPE_SYNCHRO, sc, sumtype, tp)
    if not g:IsExists(Card.IsType, 1, nil, TYPE_XYZ, sc, sumtype, tp) then
        return false
    end
    mg:Remove(Card.IsType, nil, TYPE_XYZ, sc, sumtype, tp)
    return mg:IsExists(Card.IsType, 1, nil, TYPE_PENDULUM, sc, sumtype, tp)
end

function s.pe2filter(c) return c:IsFaceup() and c:GetFlagEffect(id) ~= 0 end

function s.pe2con(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.GetAttacker()
    local bc = Duel.GetAttackTarget()

    if not ac or not bc then return false end
    return ac:IsFaceup() and ac:IsControler(tp) and
               ac:IsAttribute(ATTRIBUTE_DARK) and ac:IsType(TYPE_PENDULUM) and
               ac:IsRace(RACE_DRAGON)
end

function s.pe2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local ac = Duel.GetAttacker()
    if chk == 0 then
        return Duel.GetMatchingGroupCount(s.pe2filter, tp, 0xff, 0xff, ac) == 0
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_OATH + EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EFFECT_CANNOT_ATTACK)
    ec1:SetTargetRange(LOCATION_MZONE, 0)
    ec1:SetLabel(ac:GetFieldID())
    ec1:SetTarget(function(e, c) return e:GetLabel() ~= c:GetFieldID() end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local ac = Duel.GetAttacker()
    if not ac or not ac:IsRelateToBattle() or not ac:IsControler(tp) or
        ac:IsFacedown() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
    ec1:SetValue(ac:GetAttack() * 2)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    ac:RegisterEffect(ec1)
end

function s.me1val(e, re, rp)
    local rc = re:GetHandler()
    return rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER) and
               rc:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ)
end

function s.me4filter(c, tp)
    return c:IsControler(1 - tp) and c:IsPreviousLocation(LOCATION_DECK)
end

function s.me4con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() ~= PHASE_DRAW
end

function s.me4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = eg:Filter(s.me4filter, nil, tp)
    if chk == 0 then return #g > 0 end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.me4op(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(s.me4filter, nil, tp)
    if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
end

function s.me5con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetBattleTarget() ~= nil
end

function s.me5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
    ec1:SetValue(c:GetAttack() * 2)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end
