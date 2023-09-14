pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- main
function _init()
	cls(0)
	
	particles = {}
	
	for i = 1, 200 do
		add(particles, star(delstar))
	end
	
	for i = 1, 30 do
		add(particles, laser(dellaser))
	end
end

function _update()
	for p in all(particles) do
		p:update()
	end
end

function _draw()
	cls(0)
	
	for p in all(particles) do
		p:draw()
	end
end

-- delete functions
function delstar(s)
	del(particles, s)
	add(particles, star(delstar, -1))
end

function dellaser(l)
	del(particles, l)
	add(particles, laser(dellaser))
end
-->8
-- lasers
function laser(delfn)
	-- speed and direction
	local velocity = rnd(2.5) + 0.5
	local angle = rnd(1)
	local l = 6

	-- position
	local x1 = x or 64
	local y1 = y or 64
	local x2 = x1 + l * cos(angle)
	local y2 = y1 + l * sin(angle)

	-- convert vector to horiz.
	-- and vert. components
	local	dx = velocity * cos(angle)
	local	dy = velocity * sin(angle)
 
	-- color
	local	c = flr(rnd(15) + 1)

	-- return table
	return {
		update = function (_)
			x1 += dx
			y1 += dy
			x2 += dx
			y2 += dy
			
			if x1 <= -1 or x1 >= 128 or y1 <= -1 or y1 >= 128 then
				delfn(_)
			end
		end,

		draw = function (_)
			line(x1, y1, x2, y2, c)
		end
	}
end
-->8
-- stars
function star(delfn, y)
	-- position
	local	x = rnd(128)
	local	y = y or rnd(128)

	-- velocity
	local dy = rnd(2.5) + 0.5

	-- color
	local colors = { 1, 5, 7, 7 }
	local	c = colors[ceil(dy * 1.3)]
 
	return {
		update = function (_)
			y += dy
			
			if y >= 128 then
				delfn(_)
			end
		end,

		draw = function (_)
			pset(x, y, c)
		end
	}
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
