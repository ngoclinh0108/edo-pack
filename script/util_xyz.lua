-- init
if not aux.UtilXyzProcedure then aux.UtilXyzProcedure = {} end
if not UtilXyz then UtilXyz = aux.UtilXyzProcedure end

-- function
function UtilXyz.Overlay(sc, tg, attach_overlay)
    if type(tg) == "Card" then tg = Group.FromCards(tg) end
    for tc in aux.Next(tg) do
        local og = tc:GetOverlayGroup()
        if #og > 0 then
            if attach_overlay then
                Duel.Overlay(sc, og)
            else
                Duel.SendtoGrave(og, REASON_RULE)
            end
        end
    end
    Duel.Overlay(sc, tg)
end
