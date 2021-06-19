-- Genesis Omega Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {950000001}

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)

    -- pendulum summon
    Pendulum.AddProcedure(c)
    Utility.PlaceToPZoneWhenDestroyed(c)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.penlimit)
    c:RegisterEffect(splimit)

    -- special summon rule
    local spr = Effect.CreateEffect(c)
    spr:SetType(EFFECT_TYPE_FIELD)
    spr:SetCode(EFFECT_SPSUMMON_PROC)
    spr:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    spr:SetRange(LOCATION_HAND + LOCATION_EXTRA)
    spr:SetCondition(s.sprcon)
    spr:SetTarget(s.sprtg)
    spr:SetOperation(s.sprop)
    c:RegisterEffect(spr)

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

    -- predraw
    local predraw = Effect.CreateEffect(c)
    predraw:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    predraw:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    predraw:SetCode(EVENT_PREDRAW)
    predraw:SetRange(LOCATION_ALL)
    predraw:SetCountLimit(1)
    predraw:SetTarget(s.predrawtg)
    predraw:SetOperation(s.predrawop)
    c:RegisterEffect(predraw)

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

    -- cannot be switch control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

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

    -- chain attack
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 0))
    pe2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    pe2:SetCode(EVENT_DAMAGE_STEP_END)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1)
    pe2:SetCondition(s.pe2con)
    pe2:SetCost(s.pe2cost)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- unstoppable attack
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    me1:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    me1:SetRange(LOCATION_MZONE)
    c:RegisterEffect(me1)

    -- attack all monsters
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_SINGLE)
    me2:SetCode(EFFECT_ATTACK_ALL)
    me2:SetValue(1)
    c:RegisterEffect(me2)

    -- double ATK
    local me3 = Effect.CreateEffect(c)
    me3:SetDescription(aux.Stringid(id, 2))
    me3:SetCategory(CATEGORY_ATKCHANGE)
    me3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    me3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    me3:SetRange(LOCATION_MZONE)
    me3:SetCountLimit(1)
    me3:SetCondition(s.me3con)
    me3:SetOperation(s.me3op)
    c:RegisterEffect(me3)
end

function s.predrawfilter(c) return c:IsCode(950000001) and c:IsAbleToHand() end

function s.predrawtoextracheck(e)
    local c = e:GetHandler()
    return c:IsLocation(LOCATION_HAND + LOCATION_EXTRA) and not c:IsForbidden()
end

function s.predrawsearchcheck(tp)
    return Duel.IsExistingMatchingCard(s.predrawfilter, tp,
                                       LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
end

function s.predrawtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return s.predrawtoextracheck(e) or s.predrawsearchcheck(tp)
    end

    if s.predrawsearchcheck(tp) then
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                              LOCATION_DECK + LOCATION_GRAVE)
    end
end

function s.predrawop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    if c:IsLocation(LOCATION_HAND + LOCATION_DECK) then
        Duel.SendtoExtraP(c, tp, REASON_EFFECT)
    end

    if Duel.IsTurnPlayer(tp) then
        local g = Duel.GetMatchingGroup(s.predrawfilter, tp,
                                        LOCATION_DECK + LOCATION_GRAVE, 0, nil)
        if #g > 1 then g = g:Select(tp, 1, 1, nil) end
        if #g > 0 then
            Utility.HintCard(id)
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    end
end

function s.sprfilter(c)
    return c:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ + TYPE_PENDULUM) and
               c:IsRace(RACE_DRAGON)
end

function s.sprcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local rg = Duel.GetReleaseGroup(tp):Filter(s.sprfilter, nil)
    local g1 = rg:Filter(Card.IsType, nil, TYPE_FUSION)
    local g2 = rg:Filter(Card.IsType, nil, TYPE_SYNCHRO)
    local g3 = rg:Filter(Card.IsType, nil, TYPE_XYZ)
    local g4 = rg:Filter(Card.IsType, nil, TYPE_PENDULUM)

    if #g4 == 1 then
        if #g1 == 1 and g1:FilterCount(Card.IsType, nil, TYPE_PENDULUM) == 1 then
            return false
        end
        if #g2 == 1 and g2:FilterCount(Card.IsType, nil, TYPE_PENDULUM) == 1 then
            return false
        end
        if #g3 == 1 and g3:FilterCount(Card.IsType, nil, TYPE_PENDULUM) == 1 then
            return false
        end
    end

    return Duel.GetLocationCount(tp, LOCATION_MZONE) > -4 and #g1 > 0 and #g2 >
               0 and #g3 > 0 and #g4 > 0 and
               aux.SelectUnselectGroup(g1, e, tp, 1, 1, aux.ChkfMMZ(1), 0) and
               aux.SelectUnselectGroup(g2, e, tp, 1, 1, aux.ChkfMMZ(1), 0) and
               aux.SelectUnselectGroup(g3, e, tp, 1, 1, aux.ChkfMMZ(1), 0) and
               aux.SelectUnselectGroup(g4, e, tp, 1, 1, aux.ChkfMMZ(1), 0)
end

function s.sprtg(e, tp, eg, ep, ev, re, r, rp, c)
    local rg = Duel.GetReleaseGroup(tp):Filter(s.sprfilter, nil)
    local mg = aux.SelectUnselectGroup(rg:Filter(Card.IsType, nil, TYPE_FUSION),
                                       e, tp, 1, 1, aux.ChkfMMZ(1), 1, tp,
                                       HINTMSG_RELEASE, nil, nil, true)
    if #mg > 0 then
        mg:Merge(aux.SelectUnselectGroup(
                     rg:Filter(Card.IsType, nil, TYPE_SYNCHRO), e, tp, 1, 1,
                     aux.ChkfMMZ(1), 1, tp, HINTMSG_RELEASE, nil, nil, true))
        if #mg > 1 then
            mg:Merge(aux.SelectUnselectGroup(
                         rg:Filter(Card.IsType, nil, TYPE_XYZ), e, tp, 1, 1,
                         aux.ChkfMMZ(1), 1, tp, HINTMSG_RELEASE, nil, nil, true))
            if #mg > 2 then
                local pg = rg:Filter(Card.IsType, nil, TYPE_PENDULUM)
                pg = pg:Filter(function(c)
                    return not mg:IsContains(c)
                end, nil)
                mg:Merge(aux.SelectUnselectGroup(pg, e, tp, 1, 1,
                                                 aux.ChkfMMZ(1), 1, tp,
                                                 HINTMSG_RELEASE, nil, nil, true))
            end
        end
    end

    if #mg == 4 then
        mg:KeepAlive()
        e:SetLabelObject(mg)
        return true
    end
    return false
end

function s.sprop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.Release(g, REASON_COST + REASON_MATERIAL)
    g:DeleteGroup()
end

function s.pe2filter1(c) return
    c:IsType(TYPE_PENDULUM) and c:IsRace(RACE_DRAGON) end

function s.pe2filter2(c) return c:IsFaceup() and c:GetFlagEffect(id) ~= 0 end

function s.pe2con(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.GetAttacker()
    return ac and ac:IsFaceup() and ac:IsControler(tp) and s.pe2filter1(ac) and
               Duel.GetAttackTarget() ~= nil and ac:CanChainAttack()
end

function s.pe2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local ac = Duel.GetAttacker()
    if chk == 0 then
        return Duel.GetMatchingGroupCount(s.pe2filter2, tp, 0xff, 0xff, ac) == 0
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

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local ac = Duel.GetAttacker()
    if chk == 0 then return ac and ac:CanChainAttack() end
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.GetAttacker()
    if ac and ac:IsRelateToBattle() and ac:IsControler(tp) then
        Duel.ChainAttack()
    end
end

function s.me3con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetBattleTarget() ~= nil
end

function s.me3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
    ec1:SetValue(c:GetAttack() * 2)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end
