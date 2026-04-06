Push = require("lib.push")
Object = require("lib.classic")
Shape = require("shape")

W_WIDTH, W_HEIGHT = love.window.getDesktopDimensions()
W_WIDTH, W_HEIGHT = W_WIDTH * .8, W_HEIGHT * .8

WIDTH = 1920
HEIGHT = 1080

local world = love.physics.newWorld(0, 0, true)

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	background = love.graphics.newImage("sprites/bg.png")
	character = love.graphics.newImage("sprites/character.png")
	chh = character:getHeight()
	chw = character:getWidth()

	player = {
		body=love.physics.newBody(world, 150, HEIGHT/2 + chh/2),
		shape=love.physics.newRectangleShape(chw, chh),
		score=0,
		health=3
	}
	player.fixture = love.physics.newFixture(player.body, player.shape)
	player.body:setFixedRotation(true)
	

	love.graphics.setColor(0.2, 0.2, 0.2)

	enemy_list = {
		{"sprites/triangle-bad.png", "triangle"},
		{"sprites/square-bad.png", "square"},
		{"sprites/circle-bad.png", "circle"}
	}

	last_shape = {}
	times_repeated = 0

	next_shape = enemy_list[math.random(1, 3)]
	speed = 100.0

	score_per_enemy = 10
	next_level = 100

	cooldown = 0
	cd_time = 1.5
	enemy_spawn_rate = 5
	enemy_spawn = 0
	
	shapes = {}
	enemies = {}

	spawnPos = {
		x= chw + 170,
		y=HEIGHT/2 - 64
	}

	enemySpawnPos = {
		x=WIDTH-200,
		y=HEIGHT/2 - 64
	}
	
	font = love.graphics.newFont(30)

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
		for i, shape in ipairs(enemies) do 
			shape:draw()
		end

		love.graphics.setFont(font)
		love.graphics.setColor(0.2, 0.2, 0.2)
		love.graphics.print("score: " .. player.score, WIDTH/2, 50)
	Push:finish()
end

function love.update(dt)
	world:update(dt)
	for i, shape in ipairs(shapes) do
		shape:update(dt)
	end

	for i, shape in ipairs(enemies) do 
			shape:update()
	end
	if cooldown > 0 then 
		cooldown = cooldown - dt
	end
	
	if enemy_spawn > 0 then
		enemy_spawn = enemy_spawn - dt
	else 
		loadShape(enemySpawnPos.x, enemySpawnPos.y, next_shape[1], shapes, world, next_shape[2], "enemy", -speed)
		next_shape = enemy_list[math.random(1, 3)]
		enemy_spawn = enemy_spawn_rate
	end

	if player.score > next_level then
		enemy_spawn_rate = enemy_spawn_rate * .95
		score_per_enemy = math.floor(score_per_enemy * 1.2 + 0.5)
		next_level = math.floor(next_level * 1.2 + 0.5)
		if enemy_spawn < 1.5 then enemy_spawn = 1.5 end
	end
	if player.health <= 0 then
		love.event.push("quit", "restart")
	end
end

function love.keypressed(keycode)
	if cooldown <=0 then
		if keycode=="a" then
			loadShape(spawnPos.x, spawnPos.y, 'sprites/triangle-good.png', shapes, world, "triangle", "ally")
		elseif keycode=="s" then
			loadShape(spawnPos.x, spawnPos.y, 'sprites/circle-good.png', shapes, world, "circle", "ally")
		elseif keycode=="d" then
			loadShape(spawnPos.x, spawnPos.y, 'sprites/square-good.png', shapes, world, "square", "ally")
		end
		cooldown = cd_time
	end
end


function love.resize(w, h)
	Push:resize(w, h)
end

function loadShape(x, y, shape, tb, world, s, team, --[[optional]] spd)
	spd = spd or speed
	shape = Shape(x, y, shape, spd, world, s, team)
	table.insert(tb, shape)
end

function OnCollisionEnter(a, b, contact)
	if a == player.fixture or b == player.fixture then
		local other = a == player.fixture and b or a
		other:destroy()
		ud = other:getUserData()
		ud.state = "ded"
		player.health = player.health - 1
		return
	end

	ad = a:getUserData()
	bd = b:getUserData()
	if ad.s == bd.s then
		if ad.team == bd.team then return end
		ad.state = "ded"
		a:destroy()

		bd.state = "ded"
		b:destroy()

		player.score = player.score + score_per_enemy
	else
		if ad.team == "ally" then
			ad.state = "ded"
			a:destroy()
		end 
		if bd.team == "ally" then
			bd.state = "ded"
			b:destroy()
		end
	end
end

function onCollisionExit(a, b, contact)
	print("ok")
end

world:setCallbacks(OnCollisionEnter, OnCollisionExit)
