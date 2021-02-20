-- Red-Eyes Polymerization
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_REDEYES_B_DRAGON}
s.listed_series = {0x3b}

function s.initial_effect(c)
    -- activate
    local e1 = Fusion.CreateSummonEff(c, aux.FilterBoolFunction(
                                          aux.IsMaterialListSetCard, 0x3b), nil,
                                      s.e1fusextra, nil, nil, s.e1op)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(function() return Duel.IsMainPhase() end)
    e1:SetCost(s.e1cost)
    c:RegisterEffect(e1)
    if not AshBlossomTable then AshBlossomTable = {} end
    table.insert(AshBlossomTable, e1)
    Duel.AddCustomActivityCounter(id, ACTIVITY_SUMMON, s.e1counterfilter)
    Duel.AddCustomActivityCounter(id, ACTIVITY_SPSUMMON, s.e1counterfilter)
end

function s.e1counterfilter(c) return c:IsSetCard(0x3b) end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetCustomActivityCount(id, tp, ACTIVITY_SUMMON) == 0 and
                   Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON) == 0
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH +
                        EFFECT_FLAG_CLIENT_HINT)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_CANNOT_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetLabelObject(e)
    ec1:SetTarget(s.e1sumlimit)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    Duel.RegisterEffect(ec1b, tp)
end

function s.e1sumlimit(e, c, sump, sumtype, sumpos, targetp, se)
    return se ~= e:GetLabelObject() and not c:IsSetCard(0x3b)
end

function s.e1fusextra(e, tp, mg, sumtype)
    return
        Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave), tp,
                              LOCATION_DECK, 0, nil), s.e1fuscheck
end

function s.e1fuscheck(tp, sg, fc, sumtype, tp)
    return sg:IsExists(s.e1fusfilter, 1, nil, fc, sumtype, tp)
end

function s.e1fusfilter(c, fc, sumtype, tp)
    local mat = fc.material
    local set = fc.material_setcode
    local res

    if mat then
        for _, code in ipairs(mat) do
            res = res or
                      (c:IsSummonCode(nil, SUMMON_TYPE_FUSION, PLAYER_NONE, code) and
                          c:IsSetCard(0x3b, fc, sumtype, tp))
        end
    elseif set then
        res = res or
                  (c:IsSetCard(0x3b, fc, sumtype, tp) and
                      aux.IsMaterialListSetCard(fc, 0x3b))
    else
        return false
    end

    return res
end

function s.e1op(e, tc, tp, mg, chk)
    local c = e:GetHandler()
    if chk == 1 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_CHANGE_CODE)
        ec1:SetValue(CARD_REDEYES_B_DRAGON)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
    end
end
