-- Supreme King Dragon Venowurm
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x10f8, 0x20f8}

function s.initial_effect(c)
    -- pendulum summon
    Pendulum.AddProcedure(c)

    -- scale
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_SINGLE)
    pe1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    pe1:SetCode(EFFECT_CHANGE_LSCALE)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCondition(s.pe1con)
    pe1:SetValue(4)
    c:RegisterEffect(pe1)
    local pe1b = pe1:Clone()
    pe1b:SetCode(EFFECT_CHANGE_RSCALE)
    c:RegisterEffect(pe1b)

    -- fusion summon (pendulum zone)
    local pe2params = {aux.FilterBoolFunction(Card.IsRace, RACE_DRAGON)}
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(1170)
    pe2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    pe2:SetType(EFFECT_TYPE_IGNITION)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1)
    pe2:SetTarget(Fusion.SummonEffTG(table.unpack(pe2params)))
    pe2:SetOperation(Fusion.SummonEffOP(table.unpack(pe2params)))
    c:RegisterEffect(pe2)

    -- fusion substitute
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetCode(EFFECT_FUSION_SUBSTITUTE)
    me1:SetCondition(function(e)
        return e:GetHandler():IsLocation(
                   LOCATION_HAND + LOCATION_ONFIELD + LOCATION_GRAVE)
    end)
    c:RegisterEffect(me1)

    -- fusion limit
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_SINGLE)
    me2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    me2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    me2:SetValue(function(e, c)
        if not c then return false end
        return not c:IsRace(RACE_DRAGON)
    end)
    c:RegisterEffect(me2)

    -- fusion summon (monster zone)
    local me3params = {
        nil, Fusion.CheckWithHandler(Fusion.OnFieldMat), function(e, tp, mg)
            return Duel.GetMatchingGroup(Card.IsAbleToGrave, tp, LOCATION_PZONE,
                                         0, nil)
        end, nil, Fusion.ForcedHandler
    }
    local me3 = Effect.CreateEffect(c)
    me3:SetDescription(1170)
    me3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    me3:SetType(EFFECT_TYPE_IGNITION)
    me3:SetRange(LOCATION_MZONE)
    me3:SetCountLimit(1)
    me3:SetTarget(Fusion.SummonEffTG(table.unpack(me3params)))
    me3:SetOperation(Fusion.SummonEffOP(table.unpack(me3params)))
    c:RegisterEffect(me3)

    -- effect gain
    local me4 = Effect.CreateEffect(c)
    me4:SetDescription(aux.Stringid(id, 0))
    me4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me4:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    me4:SetCode(EVENT_BE_MATERIAL)
    me4:SetCondition(s.me4con)
    me4:SetTarget(s.me4tg)
    me4:SetOperation(s.me4op)
    c:RegisterEffect(me4)
end

function s.pe1con(e)
    return not Duel.IsExistingMatchingCard(function(c)
        return c:IsSetCard(0x98) or c:IsSetCard(0x10f8) or c:IsSetCard(0x20f8)
    end, e:GetHandlerPlayer(), LOCATION_PZONE, 0, 1, e:GetHandler())
end

function s.me4filter(c, sc)
    return
        c:IsAbleToGrave() and c:HasLevel() and c:GetLevel() < sc:GetLevel() and
            c:IsAttribute(ATTRIBUTE_DARK)
end

function s.me4con(e, tp, eg, ep, ev, re, r, rp) return (r & REASON_FUSION) ~= 0 end

function s.me4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local tc = c:GetReasonCard()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.me4filter, tp, LOCATION_HAND +
                                               LOCATION_DECK + LOCATION_EXTRA,
                                           0, 1, nil, tc)
    end
end

function s.me4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetReasonCard()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.me4filter, tp, LOCATION_HAND +
                                          LOCATION_DECK + LOCATION_EXTRA, 0, 1,
                                      3, nil, tc)
    if #g > 0 then Duel.SendtoGrave(g, REASON_EFFECT) end
end
