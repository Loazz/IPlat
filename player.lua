local Player = {}
local Sound = require("sound")

function Player:load()
    self.x = 20
    self.y = 435
    self.startX = self.x
    self.startY = self.y

    self.backPosX = 1260
    self.backPosY = 435

    self.width = 37
    self.height = 50
    self.xVel = 0
    self.yVel = 0
    self.maxSpeed = 190
    self.acceleration = 4000
    self.friction = 3500
    self.gravity = 1400
    self.jumpAmount = -460

    self.health = {current = 1, max = 1}

    self.coins = 0

    self.color = {
        red = 1,
        green = 1,
        blue = 1,
        speed = 3,
    }

    self.direction = "right"
    self.state = "idle"

    self.grounded = false
    self.alive = true

    self.maxJumpN = 2
    self.jumpN = 0

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.width * 0.6, self.height * 0.6)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)

    self:loadAssets()
end

function Player:moreHPmax()
    self.health.max = self.health.max + 1
    self.health.current = self.health.current + 1
end

function Player:backPos()
    self.physics.body:setPosition(self.backPosX, self.backPosY)
end

function Player:giveMoreHPmax()
    if self.coins == 25 then
        self.coins = 0
        self:moreHPmax()
    end
end

function Player:respawn()
    if not self.alive then
        Sound:play("playerDie", "default", 0.006, 1)
        self:resetPosition()
        self.health.current = self.health.max
        self.alive = true
    end
end

function Player:resetPosition()
    self.physics.body:setPosition(self.startX, self.startY)
end

function Player:takeDamage(amount)
    self:tintRed()
    if self.health.current - amount > 0 then
        self.health.current = self.health.current - amount
    else
        self.health.current = 0
        self:die()
    end
end

function Player:die()
    self.alive = false
end

function Player:incrementCoins()
    self.coins = self.coins + 1
end

function Player:loadAssets()
    self.animation = {timer = 0, rate = 0.1}
    self.animation.run = {total = 5, current = 1, img = {}}

    for i=0, self.animation.run.total do
        self.animation.run.img[i] = love.graphics.newImage("assets/playerAssets/Individual Sprites/adventurer-run-0"..i..".png")
    end

    self.animation.idle = {total = 3, current = 1, img = {}}

    for i=0, self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/playerAssets/Individual Sprites/adventurer-idle-0"..i..".png")
    end

    self.animation.air = {total = 2, current = 1, img = {}}

    for i=0, self.animation.air.total do
        self.animation.air.img[i] = love.graphics.newImage("assets/playerAssets/Individual Sprites/adventurer-smrslt-0"..i..".png")
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function Player:tintRed()
    self.color.green = 0
    self.color.blue = 0
end

function Player:unTint(dt)
    self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
    self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
    self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

function Player:setDirection()
    if self.xVel < 0 then
        self.direction = "left"
    elseif self.xVel > 0 then
        self.direction = "right"
    end
end

function Player:setState()
    if not self.grounded then
        self.state = "air"
    elseif self.xVel == 0 then
        self.state = "idle"
    else
        self.state = "run"
    end
end

function Player:animate(dt)
    self.animation.timer = self.animation.timer + dt

    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function Player:setNewFrame()
    local anim = self.animation[self.state]

    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Player:update(dt)
    self:unTint(dt)
    self:respawn()
    self:setState()
    self:setDirection()
    self:animate(dt)
    self:syncPhysics()
    self:move(dt)
    self:applyGravity(dt)
    self:giveMoreHPmax()
end

function Player:applyGravity(dt)
    if not self.grounded then
        self.yVel = self.yVel + self.gravity * dt
    end
end

function Player:move(dt)
   if love.keyboard.isDown("d", "right") then
      if self.xVel < self.maxSpeed then
         if self.xVel + self.acceleration * dt < self.maxSpeed then
            self.xVel = self.xVel + self.acceleration * dt
         else
            self.xVel = self.maxSpeed
         end
      end
  elseif love.keyboard.isDown("q", "left") then
      if self.xVel > -self.maxSpeed then
         if self.xVel - self.acceleration * dt > -self.maxSpeed then
            self.xVel = self.xVel - self.acceleration * dt
         else
            self.xVel = -self.maxSpeed
         end
      end
   else
      self:applyFriction(dt)
   end
end

function Player:applyFriction(dt)
   if self.xVel > 0 then
      if self.xVel - self.friction * dt > 0 then
         self.xVel = self.xVel - self.friction * dt
      else
         self.xVel = 0
      end
   elseif self.xVel < 0 then
      if self.xVel + self.friction * dt < 0 then
         self.xVel = self.xVel + self.friction * dt
      else
         self.xVel = 0
      end
   end
end

function Player:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Player:beginContact (a, b, collision)
    if self.grounded then return end

    self.jumpN = 0

    local nx, ny = collision:getNormal()
    if a == self.physics.fixture then
        if ny > 0 then
            self:land(collision)
        elseif ny < 0 then
            self.yVel = 0
        end
    elseif b == self.physics.fixture then
        if ny < 0 then
            self:land(collision)
        elseif ny > 0 then
            self.yVel = 0
        end
    end
end

function Player:land(collision)
    self.currentGroundCollision = collision
    self.yVel = 0
    self.grounded = true
end

function Player:jump(key)
    if (key == "z" or key == "up") and self.jumpN ~= self.maxJumpN  then
        if self.jumpN == 0 and self.grounded == false then
            self.jumpN = 1
            self.jumpN = self.jumpN + 1
            self.yVel = self.jumpAmount
        else
            self.jumpN = self.jumpN + 1
            self.yVel = self.jumpAmount
        end

        if self.JumpN == self.maxJumpN then
            self.grounded = false
        end

        Sound:play("jump", "default", 0.006, 1)
    end
end

function Player:endContact(a, b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then
        if self.currentGroundCollision == collision then
            self.grounded = false
        end
    end
end

function Player:draw()
    local scaleX = 1.35

    if self.direction == "left" then
        scaleX = -1.35
    end
    love.graphics.setColor(self.color.red, self.color.green,  self.color.blue)
    love.graphics.draw(self.animation.draw, self.x, self.y, 0, scaleX, 1.35, self.animation.width / 2, self.animation.height / 2)
    love.graphics.setColor(1, 1, 1, 1)
end

return Player
