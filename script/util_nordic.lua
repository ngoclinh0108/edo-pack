-- init
if not aux.UtilNordicProcedure then aux.UtilNordicProcedure = {} end
if not UtilNordic then UtilNordic = aux.UtilNordicProcedure end

-- constant
UtilNordic.ASCENDANT_TOKEN = 930000038
UtilNordic.EINHERJAR_TOKEN = 40844553
UtilNordic.BEAST_TOKEN = 15394084
UtilNordic.MALUS_TOKEN = 42671152

-- function
function UtilNordic.NordicGodEffect(c, sumtype, reborn)
    local id = c:GetOriginalCodeRule()

    -- summon cannot be negated
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    sumsafe:SetCondition(function(e)
        return e:GetHandler():GetSummonType() == sumtype
    end)
    c:RegisterEffect(sumsafe)

    -- cannot be tributed or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(
        EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE +
            EFFECT_FLAG_UNCOPYABLE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetTargetRange(1, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(1)
    c:RegisterEffect(nomaterial)

    if (reborn) then
        -- register the fact it was destroyed and sent to GY
        local desreg = Effect.CreateEffect(c)
        desreg:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
        desreg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        desreg:SetCode(EVENT_TO_GRAVE)
        desreg:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local c = e:GetHandler()
            if not c:IsReason(REASON_DESTROY) or
                not c:IsPreviousLocation(LOCATION_ONFIELD) then
                return
            end
            c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 1)
        end)
        c:RegisterEffect(desreg)

        -- special summon itself from GY
        local reborn = Effect.CreateEffect(c)
        reborn:SetCategory(CATEGORY_SPECIAL_SUMMON)
        reborn:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
        reborn:SetRange(LOCATION_GRAVE)
        reborn:SetCode(EVENT_PHASE + PHASE_END)
        reborn:SetCountLimit(1)
        reborn:SetCondition(function(e)
            return e:GetHandler():GetFlagEffect(id) ~= 0
        end)
        reborn:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
            local c = e:GetHandler()
            local tp = c:GetControler()
            if chk == 0 then
                return c:IsCanBeSpecialSummoned(e, 1, tp, false, false) and
                           Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            end
            Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
        end)
        reborn:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local c = e:GetHandler()
            if not c:IsRelateToEffect(e) then return end
            Duel.SpecialSummon(c, 1, tp, tp, false, false, POS_FACEUP)
        end)
        c:RegisterEffect(reborn)
    end
end

function UtilNordic.RebornCondition(e)
    return e:GetHandler():GetSummonType() == SUMMON_TYPE_SPECIAL + 1
end

function UtilNordic.AesirGodEffect(c)
    UtilNordic.NordicGodEffect(c, SUMMON_TYPE_SYNCHRO, true)
end
