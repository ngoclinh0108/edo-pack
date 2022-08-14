-- init
if not aux.SignerDragonProcedure then
    aux.SignerDragonProcedure = {}
end
if not SignerDragon then SignerDragon = aux.SignerDragonProcedure end

-- constant
SignerDragon.CARD_MAJESTIC_DRAGON = 21159309

-- function
function SignerDragon.AddMajesticSynchro(c, s, card_code)
    Synchro.AddMajesticProcedure(c, aux.FilterBoolFunction(Card.IsCode, SignerDragon.CARD_MAJESTIC_DRAGON), true,
        aux.FilterBoolFunction(Card.IsCode, card_code), true, Synchro.NonTuner(nil), false)

    s.material = {SignerDragon.CARD_MAJESTIC_DRAGON, card_code}
    s.listed_names = {SignerDragon.CARD_MAJESTIC_DRAGON, card_code}
    s.synchro_nt_required = 1
end