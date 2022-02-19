local DataFetcher = require 'scripts.composer.data-fetcher'
local Decoder = require 'scripts.composer.decoder'
local Assembler = require 'scripts.composer.assembler'
local Printer = require 'scripts.composer.printer'
local Logs = require 'lib.logs'
local Config = require 'scripts.config'
local CardDataFetcher = require 'scripts.make.data-fetcher'
local CardParser = require 'scripts.make.parser'
local insert = table.insert

local Composer = {}

local modes = { anime = true, proxy = true }
local function check_mode(mode)
  return modes[mode]
end

local function check_folders(imgfolder, outfolder)
  Logs.assert(imgfolder ~= outfolder, 1, "Artwork folder cannot be the same as ",
    "output folder")
end

function Composer.compose(mode, imgfolder, cdbfp, outfolder, options)
  local files = {}
  local expansions = Config.get_all('expansion')
  for _, expansion in pairs(expansions) do
    for _, file in ipairs(expansion.recipe) do
      insert(files, file)
    end
  end
  local _, cards = CardParser.parse(CardDataFetcher.get(files))

  Logs.assert(check_mode(mode), 1, "unknown mode \"", mode, '"')
  check_folders(imgfolder, outfolder)
  local data = DataFetcher.get(imgfolder, cdbfp)
  local metalayers_set, n = {}, 0
  Decoder.configure(mode, options)
  for _, d in ipairs(data) do
    local card
    for _, c in pairs(cards) do
      if tostring(c.id) == d.id then
        card = c
        break
      end
    end

    local metalayers, msg = Decoder.decode(d, card)
    if metalayers then
      metalayers_set[d.id] = metalayers
      n = n + 1
    else
      Logs.warning(("Failed at decoding %s: "):format(data.id), msg)
    end
  end
  Assembler.configure(mode, options)
  Printer.configure(outfolder, options)
  local bar = Logs.bar(n)
  bar:print()
  for id, metalayers in pairs(metalayers_set) do
    bar:update("Generating " .. id .. "...")
    local img, field = Assembler.assemble(metalayers)
    Printer.print(id, img)
    if field then
      Printer.print_field(id, field)
    end
  end
  bar:finish("Done!")
end

return Composer
