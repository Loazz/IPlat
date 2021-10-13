local MapBack = {}
local Player = require("player")
local Map = require("map")
local Coin = require("coin")

function MapBack:back()
    Map:clean()
    Map.currentLevel = Map.currentLevel - 1
    Map:init()
    Player:backPos()
end

function MapBack:update(dt)
    if Player.x < 5 then
        MapBack:back()

        Coin.removeAll()
    end
end

return MapBack
