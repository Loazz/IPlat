--[[
By Loaz
]]

love.graphics.setDefaultFilter("nearest", "nearest")
local Player = require("player")
local Coin = require("coin")
local GUI = require("gui")
local Spike = require("spike")
local Camera = require("camera")
local Map = require("map")
local MapBack = require("mapBack")
local Sound = require("sound")
local Title = require("title")

function wait(time)
    local duration = os.time() + time
    while os.time() < duration do end
end

function love.load()
    backgroundMusic = love.audio.newSource("assets/sfx/backgroundMusic.mp3", "stream")
    backgroundMusic:setLooping(true)
    backgroundMusic:setVolume(0.006)

    Title:load()

    Map:load()
    background = love.graphics.newImage("assets/background.jpg")

    Sound.loadAll()

    GUI:load()
    Player:load()
end

function love.update(dt)
    if currentTitle == true then
        Title:update(dt)
    else
        World:update(dt)
        Player:update(dt)
        Coin.updateAll(dt)
        Spike.updateAll(dt)
        GUI:update(dt)
        Camera:setPosition(Player.x, 0)
        Map:update(dt)
        MapBack:update(dt)
        Sound:update()
    end
end

function love.draw()
    if currentTitle == true then
        Title:draw()
    else
        love.graphics.draw(background, 0, -435)
        Map.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)

        Camera:apply()
        Player:draw()
        Coin.drawAll()
        Spike.drawAll()
        Camera:clear()

        love.audio.play(backgroundMusic)

        GUI:draw()
    end
end

function beginContact(a, b, collision)
    if Coin.beginContact(a, b, collision) then return end
    if Spike.beginContact(a, b, collision) then return end
    Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
    Player:endContact(a, b, collision)
end

function love.keypressed(key)
    Player:jump(key)
end
