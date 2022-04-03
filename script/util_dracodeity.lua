-- init
if not aux.UtilityDracodeityProcedure then aux.UtilityDracodeityProcedure = {} end
if not UtilityDracodeity then UtilityDracodeity = aux.UtilityDracodeityProcedure end

-- function
function UtilityDracodeity.RegisterSummon(c, attribute)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_DRAGON), 3,
                      nil, function(g, sc, sumtype, tp)
        return g:IsExists(Card.IsAttribute, 1, nil, attribute, sc, sumtype, tp)
    end)
end

function UtilityDracodeity.RegisterEffect(c, id)
    c:SetUniqueOnField(1, 0, id)

    -- summon cannot be negated
    local summon_safe = Effect.CreateEffect(c)
    summon_safe:SetType(EFFECT_TYPE_SINGLE)
    summon_safe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    summon_safe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    summon_safe:SetCondition(function(e)
        return e:GetHandler():GetSummonType() == SUMMON_TYPE_LINK
    end)
    c:RegisterEffect(summon_safe)

    -- cannot switch control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noswitch:SetRange(LOCATION_MZONE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    c:RegisterEffect(noswitch)

    -- cannot be tributed, or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc)
        return tc and tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(nomaterial)
end
