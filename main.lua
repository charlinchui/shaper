Push = require("lib.push")
Object = require("lib.classic")
Shape = require("shape")

W_WIDTH, W_HEIGHT = love.window.getDesktopDimensions()
W_WIDTH, W_HEIGHT = W_WIDTH * .8, W_HEIGHT * .8

WIDTH = 1920
HEIGHT = 1080

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	background = love.graphics.newImage("sprites/bg.png")
	character = love.graphics.newImage("sprites/character.png")
	chh = character:getHeight()
	chw = character:getWidth()
	speed = 100

	cooldown = 0
	cd_time = 1.5
	
	shapes = {}

	triangle = love.graphics.newImage("sprites/triangle-good.png")

	spawnPos = {
		x= chw + 170,
		y=HEIGHT/2 - 64
	}
	
	Push:setupScreen(WIDTH, HEIGHT, W_WIDTH, W_HEIGHT, {
		fullscreen = false, 
		vsync = true,
		resizable = true
	})
end

function love.draw()
	Push:start()
		love.graphics.draw(background, 0, 0)
		love.graphics.draw(character, 150, HEIGHT / 2 - chh/2)
		for i, shape in ipairs(shapes) do
			shape:draw()
		end
	Push:finish()
end

function love.update(dt)
	for i, shape in ipairs(shapes) do
		shape:update(dt)
	end
	if cooldown > 0 then 
		cooldown = cooldown - dt
	end
end

function love.keypressed(keycode)
	if cooldown <=0 then
		if keycode=="a" then
			loadShape(spawnPos.x, spawnPos.y, 'sprites/triangle-good.png', shapes)
		elseif keycode=="s" then
			loadShape(spawnPos.x, spawnPos.y, 'sprites/circle-good.png', shapes)
		elseif keycode=="d" then
			loadShape(spawnPos.x, spawnPos.y, 'sprites/square-good.png', shapes)
		end
			
		cooldown = cd_time
	end
end


function love.resize(w, h)
	Push:resize(w, h)
end


function loadShape(x, y, shape, tb)
	shape = Shape(x, y, love.graphics.newImage(shape), speed)
	table.insert(tb, shape)
end


