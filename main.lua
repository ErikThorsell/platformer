--! file: main.lua

-- Gaming stuff and Hot swap files
lume = require 'libs.lume.lume'

-- Pull in Gamestate from the HUMP library
Gamestate = require 'libs.hump.gamestate'

-- Pull in each of our game states
local mainMenu = require 'gamestates.mainmenu'
local gameLevel1 = require 'gamestates.gameLevel1'
local pause = require 'gamestates.pause'

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(gameLevel1)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.push("quit")
  end
end
