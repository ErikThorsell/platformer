--! file: player.lua

local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'
local anim8 = require 'libs.anim8.anim8'

local player = Class{
    __includes = Entity -- Player class inherits our Entity class
}

function player:init(world, x, y)

    self.img = love.graphics.newImage("assets/img/purple.png")
    Entity.init(self, world, x, y, self.img:getWidth(), self.img:getHeight())

    -- Add our unique player values
    self.xVelocity = 0  -- current velocity on x, y axes
    self.yVelocity = 0
    self.maxSpeed = 700 -- the top speed
    self.acc = 150      -- the acceleration of our player
    self.friction = 20  -- slow our player down - we could toggle this situationally to create icy or slick platforms
    self.gravity = 9.81 -- we will accelerate towards the bottom
    self.mass = 8       -- how much do we weigh?

    -- These are values applying specifically to jumping
    self.isJumping = false -- are we in the process of jumping?
    self.isGrounded = false -- are we on the ground?
    self.hasReachedMax = false  -- is this as high as we can go?
    self.jumpAcc = 400 -- how fast do we accelerate towards the top
    self.jumpMaxSpeed = 12 -- our speed limit while jumping

    self.world:add(self, self:getRect())

end

function player:collisionFilter(other)

    local x, y, w, h = self.world:getRect(other)
    local otherBottom = y + h
    local otherTop = y
    local otherRightSide = x + w
    local otherLeftSide = x

    local playerBottom = self.y + self.h
    local playerTop = self.y
    local playerRightSide = self.x + self.w
    local playerLeftSide = self.x

    if playerBottom <= otherTop or
        playerRightSide >= otherLeftSide or
        playerLeftSide <= otherRightSide then
        return 'slide'
    end

end

function player:update(dt)

    print("yVelocity: " .. self.yVelocity)

    -- Apply Friction
    self.xVelocity = self.xVelocity * (1 - math.min(dt * self.friction, 1))

    -- Apply gravity
    self.yVelocity = self.yVelocity + (self.gravity * self.mass * dt)

    if love.keyboard.isDown("left", "h") and self.xVelocity > -self.maxSpeed then
        if self.x > 0 then
            self.xVelocity = self.xVelocity - self.acc * dt
        end
    elseif love.keyboard.isDown("right", "s") and self.xVelocity < self.maxSpeed then
        self.xVelocity = self.xVelocity + self.acc * dt
    end

    -- The Jump code gets a lttle bit crazy.  Bare with me.
    if love.keyboard.isDown("up", "space") then
        if math.abs(self.yVelocity) < self.jumpMaxSpeed and not self.hasReachedMax then
            self.yVelocity = self.yVelocity - self.jumpAcc * dt
        elseif math.abs(self.yVelocity) > self.jumpMaxSpeed then
            self.hasReachedMax = true
        end
        self.isGrounded = false
    end

    -- these store the location the player will arrive at
    local goalX = self.x + self.xVelocity
    local goalY = self.y + self.yVelocity

    -- Move the player while testing for collisions
    self.x, self.y, collisions = self.world:move(self, goalX, goalY, self.collisionFilter)

    -- Loop through those collisions to see if anything important is happening
    for i, coll in ipairs(collisions) do
        if coll.touch.y > goalY then
            self.hasReachedMax = true
            self.isGrounded = false
        elseif coll.normal.y < 0 then
            self.hasReachedMax = false
            self.isGrounded = true
            self.yVelocity = 0
        end
    end
end

function player:draw()
    love.graphics.draw(self.img, self.x, self.y)
end

return player
