-- Vicious Fusion
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_FUSION}

function s.initial_effect(c)
    -- fusion summon
    local e1 = Fusion.CreateSummonEff {
        handler = c,
        fusfilter = function(c) return c.dark_calling end,
        matfilter = Fusion.InHandMat(Card.IsAbleToRemove),
        extrafil = function(e, tp, mg)
            return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove), tp, LOCATION_MZONE + LOCATION_GRAVE, 0, nil)
        end,
        extraop = Fusion.BanishMaterial,
        extratg = function(e, tp, eg, ep, ev, re, r, rp, chk)
            if chk == 0 then return true end
            Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE)
        end,
        chkf = FUSPROC_NOLIMIT
    }
    c:RegisterEffect(e1)
end
