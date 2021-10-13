local Map = {}
local STI = require("sti")
local Coin = require("coin")
local Spike = require("spike")
local Player = require("player")

function Map:load()
    self.currentLevel = 1
    World = love.physics.newWorld(0, 0)
    World:setCallbacks(beginContact, endContact)

    self:init()
end

function Map:init()
    self.level = STI("map/level"..self.currentLevel..".lua", {"box2d"})
    self.level:box2d_init(World)

    self.solidLayer = self.level.layers.solid
    self.entityLayer = self.level.layers.entity

    self.solidLayer.visible = false
    self.entityLayer.visible = false
    MapWidth = self.level.layers.ground.width * 16

    self:spawnEntities()
end

function Map:next()
    self:clean()
    self.currentLevel = self.currentLevel + 1
    self:init()
    Player:resetPosition()
end


function Map:update(dt)
    if Player.x > MapWidth - 16 then
        self:next()
    end
end

function Map:clean()
    self.level:box2d_removeLayer("solid")
    Coin.removeAll()
    Spike.removeAll()
end

function Map:spawnEntities()
    for i,v in ipairs(self.entityLayer.objects) do
        if v.type == "spikes" then
            Spike.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "coin" then
            Coin.new(v.x, v.y)
        end
    end
end

return Map
