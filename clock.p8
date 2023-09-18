pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--clock
--by joey day

--[[
todo
 - test for win condition
 	- win screen
 - main menu
	- about screen
 - timer
 - best times list
 - best averages list?
 - tommy cherry endorsement?
	- whimsy!
		- scramble animation?
		- animated background?
		- animated cursor?
		- sound fx
		- music
]]

function _init()
	ct=make_ct()		--clocks table
	pt=make_pt()		--pins table
	make_graph(ct,pt)
	
	scramble()
	
	cur_x=1							--cursor x
	cur_y=1							--cursor y
	cur_z=1							--cursor z (flipped)
	cur_color=10
	cur_move_color=11
	cur_mode="select"

	c=make_c()				--useful constants
	t=1											--touch counter
	dirty=true		 	--flag to redraw
	
	menuitem(1,"new scramble",
		function ()
			scramble()
			dirty=true
		end
	)
end

function _update()
	local up=btnp(⬆️)
	local down=btnp(⬇️)
	local right=btnp(➡️)
	local left=btnp(⬅️)
	if cur_z==2 then
		right=btnp(⬅️)
		left=btnp(➡️)
	end
	
	if (left or right) and not btn(🅾️) then
		local delta=2
		if (left) delta=-2
		cur_x+=delta
		if (cur_x<1) cur_x=1
		if (cur_x>3) cur_x=3
		dirty=true
	end
	
	if (up or down) and not btn(🅾️) then
		local delta=2
		if (up) delta=-2
		cur_y+=delta
		if (cur_y<1) cur_y=1
		if (cur_y>3) cur_y=3
		dirty=true
	end
	
	if cur_mode=="move" and not btn(🅾️) then
		cur_mode="select"
		dirty=true
	end
	
	if cur_mode=="select" and btn(🅾️) then
		cur_mode="move"
		dirty=true
	end
	
	if btn(🅾️) and (left or right) then
		t+=1
		local delta=1
		if (left) delta=-1
		ct[cur_x][cur_y][cur_z].update(delta,t)
		dirty=true
	end
	
	if btn(🅾️) and (up or down) then
		pt[cur_x][cur_y].toggle()
		dirty=true
	end
	
	if btnp(❎) and not btn(🅾️) then
		if cur_z==1 then
			cur_z=2
		else
			cur_z=1
		end
		dirty=true
	end
end

function _draw()
	if (not dirty) return

	--adjust size
	local d=25
	local r=1.8

	--invert colors
	pal()
	if cur_z==2 then
		pal(7,0)
		pal(6,5)
		pal(5,6)
		pal(0,7)
	end
	
	--background color
	cls(13)

	--shadow
	fillp(▒)
		draw_shape(69,63,d,r,1)
	fillp()

	--draw dial cursor
	if cur_mode=="move" then
		pal(cur_color,cur_move_color)
	end
	local draw_cur_x=cur_x
	if cur_z==2 then
		if (cur_x==1) draw_cur_x=3
		if (cur_x==3) draw_cur_x=1
	end
	fillp(▒)
	circfill(
		64-25+(draw_cur_x-1)*25,
		58-25+(cur_y-1)*25,
		21,
		cur_color
	)
	fillp()

	--puzzle
	draw_shape(64,58,d,r,7)

	--clocks
	for x=1,3 do
 	for y=1,3 do
			local clock=ct[x][y][cur_z]
			clock.draw(64,58,d,cur_z)
		end
	end
	
	--pins
	for x=1,3,2 do
		for y=1,3,2 do
			local pin=pt[x][y]
			pin.draw(64,58,d,cur_z)
		end
	end

	-- draw ticks
	for row=-1,1 do
		for col=-1,1 do
			for t=1,12 do
				if t==12 then
					spr(14,64+col*d-1,58+row*d-11)
				else
					pset(
						64.5+col*d+c[t].dx*11,
						58.5+row*d+c[t].dy*11,
						6
					)
				end
			end
		end
	end
	
	--draw pin cursor
	circ(
		64-12.5+(draw_cur_x-1)*12.5,
		58-12.5+(cur_y-1)*12.5,
		5,
		cur_color
	)
	
	--draw controls
	if not btn(🅾️) then
		print("⬆️",14,112,1)
		btnfill(14,112,1)
		print("⬆️",13,111,cur_color)
		print("⬅️  ➡️ select",6,115,1)
		btnfill(6,115,1)
		btnfill(22,115,1)
		print("⬅️  ➡️ select",5,114,cur_color)
		print("⬇️",14,118,1)
		btnfill(14,118,1)
		print("⬇️",13,117,cur_color)
		
		print("🅾️ move (hold)",70,111,1)
		btnfill(70,111,1)
		print("🅾️ move (hold)",69,110,cur_color)
		
		print("❎ flip",70,119,1)
		btnfill(70,119,1)
		print("❎ flip",69,118,cur_color)
	else
		print("⬆️",7,112,1)
		btnfill(7,112,1)
		print("⬆️",6,111,cur_color)
		print("   toggle pin",7,115,1)
		print("   toggle pin",6,114,cur_color)
		print("⬇️",7,118,1)
		btnfill(7,118,1)
		print("⬇️",6,117,cur_color)
		
		print("⬅️➡️ turn dial",70,115,1)
		btnfill(70,115,1)
		btnfill(78,115,1)
		print("⬅️➡️ turn dial",69,114,cur_color)
	end
	
	dirty=false
end
-->8
--clocks
function make_ct()
	local ct={{{},{},{}},{{},{},{}},{{},{},{}}}

	for x=1,3 do
		for y=1,3 do
			for z=1,2 do
				if x==2 or y==2 then
					--centers and edges
					ct[x][y][z]=new_c(x,y,z)
				elseif z==1 then
					--corners, exploiting
					-- pass-by-reference
					ct[x][y][1]=new_c(x,y,0)
					ct[x][y][2]=ct[x][y][1]
				end
			end
		end
	end

	return ct
end

function new_c(x,y,z)
	--private properties
	local o=12		--orientation
	local	pt={}	--linked pins table
	local lt=0		--last touch

	--public props and methods
	return {
		read=function ()
			return o
		end,
		update=function (d,t)
			if (t<=lt) return
			lt=t
			o+=d
			if (o<=0) o=12
			if (o>=13) o=1
			for p in all(pt) do
				p.update(d,t,z)
			end
		end,
		add_p=function (p)
			add(pt,p)
		end,
		draw=function (input_x,input_y,d,cur_z)
			local local_x=x
			local local_y=y
			if (cur_z==2) then
				if (x==1) local_x=3
				if (x==3) local_x=1
			end
			draw_x=input_x-d+(local_x-1)*d
			draw_y=input_y-d+(local_y-1)*d
			circfill(draw_x,draw_y,9,0)
			local fx=c[o].fx
			if cur_z==2 then
				fx=not c[o].fx
			end
			sspr(c[o].sx,0,21,21,draw_x-10,draw_y-10,21,21,fx,c[o].fy)
		end,
		scramble=function ()
			o=flr(rnd(12))+1
		end
	}
end
-->8
--pins
function make_pt()
	local pt={{},true,{}}

	for x=1,3,2 do
		for y=1,3,2 do
			pt[x][y] = new_p(x,y)
		end
	end

	return pt
end

function new_p(x,y)
	--private properties
	local z=1	--position
	local ct={{},{}}	--linked clocks table
	local lt=0							--last touch

	--public interface
	return {
		read=function ()
			return z
		end,
		toggle=function ()
			if z==1 then
				z=2
			else
				z=1
			end
		end,
		update=function (d,t,cz)
			if (t<=lt) return
			lt=t
			if (cz!=z and cz!=0) return
			for c in all(ct[z]) do
				c.update(d,t)
			end
		end,
		add_c=function (c,z)
			add(ct[z],c)
		end,
		draw=function (input_x,input_y,d,cur_z)
			local local_x=x
			local local_y=y
			if (cur_z==2) then
				if (x==1) local_x=3
				if (x==3) local_x=1
			end
			draw_x=input_x-d/2+(local_x-1)*d/2
			draw_y=input_y-d/2+(local_y-1)*d/2
			circ(draw_x,draw_y,3,6)
			if cur_z==z then
				--fillp(▒)
				--circfill(draw_x+2,draw_y+2,2,6)
				--fillp()
				circfill(draw_x,draw_y,2,0)
			end
		end,
		scramble=function ()
			z=flr(rnd(2))+1
		end
	}
end

-->8
--graph
function make_graph(ct,pt)
	--link pins to clocks
	for x=1,3 do
		for y=1,3 do
			for z=1,2 do
				if x==2 or y==2 or z==1 then
					if x<3 and y<3 then
						ct[x][y][z].add_p(pt[1][1])
					end
					if x<3 and y>1 then
						ct[x][y][z].add_p(pt[1][3])
					end
					if x>1 and y<3 then
						ct[x][y][z].add_p(pt[3][1])
					end
					if x>1 and y>1 then
						ct[x][y][z].add_p(pt[3][3])
					end
				end
				--no else needed here
				--since corners already
				--have their pins
			end
		end
	end

	--link clocks to pins
	for z=1,2 do
		for x=1,2 do
			for y=1,2 do
				pt[1][1].add_c(ct[x][y][z],z)
			end
		end

		for x=1,2 do
			for y=2,3 do
				pt[1][3].add_c(ct[x][y][z],z)
			end
		end

		for x=2,3 do
			for y=1,2 do
				pt[3][1].add_c(ct[x][y][z],z)
			end
		end

		for x=2,3 do
			for y=2,3 do
				pt[3][3].add_c(ct[x][y][z],z)
			end
		end
	end
end
-->8
--constants
function make_c()
	local c={}

	a=0.16666 --starting angle

	for i=1,12 do
		local const={}

		-- useful trig values
		const.a=a
		const.dx=cos(a)
		const.dy=sin(a)

		-- sprite defaults
		const.sx=8
		const.fx=false
		const.fy=false

		-- sprite x coord
		if i==1 or i==5 or i==7 or i==11 then
			const.sx=32
		elseif i==2 or i==4 or i==8 or i==10 then
			const.sx=56
		elseif i==3 or i==9 then
			const.sx=80
		end

		-- sprite flipping
		if i>=7 and i<=11 then
			const.fx=true
		end
		if i>=4 and i<=8 then
			const.fy=true
		end

		add(c, const)

		-- decrement angle (clockwise)
		a-=0.08333
		if a<0 then
			a=0.91666
		end
	end

	return c
end
-->8
--scramble and solve
function scramble()
	for x=1,3 do
		for y=1,3 do
			for z=1,2 do
				ct[x][y][z].scramble()
			end
		end
	end
	
	for x=1,3,2 do
		for y=1,3,2 do
			pt[x][y].scramble()
		end
	end
end
-->8
--helpers
function draw_shape(x,y,d,r,c)
	--x,y is center of shape
	circfill(x,y,d*r,c)
	for i=0,2,2 do
		for j=0,2,2 do
		 local cx=x-d+i*d
		 local cy=y-d+j*d
		 circfill(cx,cy,d/2+2,c)
		end
	end
end

function btnfill(x,y,c)
	rectfill(x+1,y,x+5,y+4,c)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008880000000000000
00000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000
00700700000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000575000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000676000000000000000000000000077000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000777000000000000000000000000776000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000005777500000000000000000000007775000000000000000000000005677000000000000000000000000000000000000000000000000000000
00000000000000006777600000000000000000000067770000000000000000000005677770000000000000000000000000000000000000000000000000000000
00000000000000000575000000000000000000000007760000000000000000000000777700000000000000000000065000000000000000000000000000000000
00000000000000000575000000000000000000000576050000000000000000000576777000000000000000000575577765000000000000000000000000000000
00000000000000000707000000000000000000000707000000000000000000000707060000000000000000000707777777760000000000000000000000000000
00000000000000000575000000000000000000000575000000000000000000000575000000000000000000000575577765000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000065000000000000000000000000000000000
__label__
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddadadadaddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddadadadadadadadddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddadadadadadadadadadaddddddddd7777777777777ddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddadadadadadadadadadadaddd77777777777777777777777dddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddadadadadadadadadadadad77777777777777777777777777777ddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddadadadadadadadadadadad77777777777777777777777777777777777dddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddadadadadadadadadadada777777777777777777777777777777777777777dddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddadadadadadada777777777777777777777777777777777777777777777777777777777ddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddadadadada777777777777777777777777777777777777777777777777777777777777777dddddddddddddddddddddddddddddddd
dddddddddddddddddddddddadadadada77777777777777777777777777777777777777777777777777777777777777777ddddddddddddddddddddddddddddddd
ddddddddddddddddddddddadadadad777777778887777777777777777777777888777777777777777777777788877777777ddddddddddddddddddddddddddddd
dddddddddddddddddddddadadadad77776777778777767777777777777677777877776777777777777767777787777677777dddddddddddddddddddddddddddd
ddddddddddddddddddddadadadad7777777770000077777777777777777777000007777777777777777777700600777777777ddddddddddddddddddddddddddd
dddddddddddddddddddddadadada7777777000000000777777777777777700000000077777777777777770000700007777777ddddddddddddddddddddddddddd
ddddddddddddddddddddadadada777777000000000000077777777777700000000000007777777777770000057500000777777dddddddddddddddddddddddddd
dddddddddddddddddddadadada777777000000000000000777777777700000000000000077777777770000006760000007777771dddddddddddddddddddddddd
ddddddddddddddddddddadadad77767700000000000000077677776770000000000000007767777677000000777000000776777d1ddddddddddddddddddddddd
dddddddddddddddddddadadada777770000000000005677077777777000000000000000007777777700000057775000000777771d1dddddddddddddddddddddd
ddddddddddddddddddadadada77777700000000056777700777777770000000000000000077777777000000677760000007777771ddddddddddddddddddddddd
dddddddddddddddddddadadad7777700000000000777700007777770000000000000000000777777000000005750000000077777d1dddddddddddddddddddddd
ddddddddddddddddddadadada77777000000005767770000077777700000000575000000007777770000000057500000000777771d1ddddddddddddddddddddd
dddddddddddddddddddadadad7776700000000707060000007677670000000070700000000767767000000007070000000076777d1d1dddddddddddddddddddd
ddddddddddddddddddadadada77777000000005750000000077777700000050675000000007777770000000057500000000777771d1ddddddddddddddddddddd
dddddddddddddddddddadadad7777700000000000000000007777770000006770000000000777777000000000000000000077777d1d1dddddddddddddddddddd
ddddddddddddddddddadadada77777700000000000000000777777770000077760000000077777777000000000000000007777771d1d1ddddddddddddddddddd
dddddddddddddddddddadadad7777770000000000000000077777777000057770000000007777777700000000000000000777777d1d1dddddddddddddddddddd
ddddddddddddddddddddadada77777770000000000000007767777777000677000000000776777777700000000000000077677771d1d1ddddddddddddddddddd
dddddddddddddddddddadada7777767700000000000000077777776770007700000000007777777677000000000000000777777771d1dddddddddddddddddddd
ddddddddddddddddddddadad7777777770000000000000777aaaaa777700700000000007777777777770000000000000777777777d1d1ddddddddddddddddddd
dddddddddddddddddddddad7777777777770000000007777a77777a777770000000007777777777777777000000000777777777777d1dddddddddddddddddddd
ddddddddddddddddddddada777777777777770000077777a7766677a777777000007777777766677777777700000777777777777771d1ddddddddddddddddddd
dddddddddddddddddddddad77777777777677777777767a776777677a7767777777776777760006777776777777777677777777777d1dddddddddddddddddddd
dddddddddddddddddddddd777777777777777776777777a767777767a77777776777777776000006777777777677777777777777777d1ddddddddddddddddddd
dddddddddddddddddddddd777777777777777777777777a767777767a777777777777777760000067777777777777777777777777771d1dddddddddddddddddd
dddddddddddddddddddddd777777777777777777777777a767777767a77777777777777776000006777777777777777777777777777d1d1ddddddddddddddddd
ddddddddddddddddddddd7777777777777777788877777a776777677a777777888777777776000677777777788877777777777777777d1dddddddddddddddddd
ddddddddddddddddddddd77777777777767777787777677a7766677a77677777877776777776667777767777787777677777777777771d1ddddddddddddddddd
ddddddddddddddddddddd777777777777777700000777777a77777a77777770000077777777777777777777000007777777777777777d1d1dddddddddddddddd
ddddddddddddddddddddd7777777777777700000000077777aaaaa7777770000000007777777777777777000000000777777777777771d1ddddddddddddddddd
ddddddddddddddddddddd777777777777000000000000077777777777700000000000007777777777770070000000000777777777777d1d1dddddddddddddddd
dddddddddddddddddddd77777777777700000000000000077777777770000000000000007777777777000770000000000777777777777d1d1ddddddddddddddd
dddddddddddddddddddd777777777677000000000000000776777767700000000000000077677776770006770000000007767777777771d1dddddddddddddddd
dddddddddddddddddddd77777777777000000000000000007777777700000000000000000777777770000577700000000077777777777d1d1ddddddddddddddd
dddddddddddddddddddd777777777770000000000000000077777777000000000000000007777777700000777600000000777777777771d1dddddddddddddddd
dddddddddddddddddddd77777777770000000000000000000777777000000000000000000077777700000067700000000007777777777d1d1ddddddddddddddd
dddddddddddddddddddd777777777700000000575000000007777770000000057500000000777777000000506750000000077777777771d1d1dddddddddddddd
dddddddddddddddddddd77777777670000000070700000000767767000000007070000000076776700000000707000000007677777777d1d1ddddddddddddddd
dddddddddddddddddddd777777777700000000575000000007777770000000057605000000777777000000005750000000077777777771d1d1dddddddddddddd
dddddddddddddddddddd77777777770000000057500000000777777000000000077600000077777700000000000000000007777777777d1d1ddddddddddddddd
dddddddddddddddddddd777777777770000006777600000077777777000000006777000007777777700000000000000000777777777771d1d1dddddddddddddd
dddddddddddddddddddd77777777777000000577750000007777777700000000077750000777777770000000000000000077777777777d1d1ddddddddddddddd
dddddddddddddddddddd777777777777000000777000000776777777700000000077600077677777770000000000000007767777777771d1d1dddddddddddddd
dddddddddddddddddddd77777777767700000067600000077777776770000000000770007777777677000000000000000777777777777d1d1ddddddddddddddd
ddddddddddddddddddddd777777777777000005750000077777777777700000000007007777777777770000000000000777777777777d1d1d1dddddddddddddd
ddddddddddddddddddddd7777777777777700007000077777777777777770000000007777777777777777000000000777777777777771d1d1ddddddddddddddd
ddddddddddddddddddddd777777777777777700600777777776667777777770000077777777666777777777000007777777777777777d1d1d1dddddddddddddd
ddddddddddddddddddddd7777777777777677777777767777600067777767777777776777767776777776777777777677777777777771d1d1ddddddddddddddd
ddddddddddddddddddddd777777777777777777677777777600000677777777767777777767777767777777776777777777777777777d1d1d1dddddddddddddd
dddddddddddddddddddddd7777777777777777777777777760000067777777777777777776777776777777777777777777777777777d1d1d1ddddddddddddddd
dddddddddddddddddddddd77777777777777777777777777600000677777777777777777767777767777777777777777777777777771d1d1dddddddddddddddd
dddddddddddddddddddddd7777777777777777888777777776000677777777788877777777677767777777778887777777777777777d1d1d1ddddddddddddddd
ddddddddddddddddddddddd77777777776777778777767777766677777677777877776777776667777767777787777677777777777d1d1d1dddddddddddddddd
ddddddddddddddddddddddd777777777777770000077777777777777777777000007777777777777777777700000777777777777771d1d1d1ddddddddddddddd
ddddddddddddddddddddddd77777777777700000000077777777777777770000000007777777777777777000000000777777777777d1d1d1dddddddddddddddd
dddddddddddddddddddddddd777777777000000000000077777777777700000000000007777777777770000000000000777777777d1d1d1ddddddddddddddddd
dddddddddddddddddddddddd7777777700000000000000077777777770000000000000007777777777000000000000000777777771d1d1d1dddddddddddddddd
ddddddddddddddddddddddddd77776770000000000000007767777677000000000000000776777767700000000000000077677771d1d1d1ddddddddddddddddd
ddddddddddddddddddddddddd7777770000000000000000077777777000000000000000007777777707765000000000000777777d1d1d1dddddddddddddddddd
ddddddddddddddddddddddddd77777700000000000000000777777770000000000000000077777777007777650000000007777771d1d1d1ddddddddddddddddd
ddddddddddddddddddddddddd7777700000000000000000007777770000000000000000000777777000077770000000000077777d1d1d1dddddddddddddddddd
ddddddddddddddddddddddddd77777000000005750000000077777700000000575000000007777770000077767500000000777771d1d1ddddddddddddddddddd
ddddddddddddddddddddddddd7776700000000707000000007677670000000070700000000767767000000607070000000076777d1d1dddddddddddddddddddd
ddddddddddddddddddddddddd77777000000005750000000077777700000000576050000007777770000000057500000000777771d1d1ddddddddddddddddddd
ddddddddddddddddddddddddd7777700000000575000000007777770000000000776000000777777000000000000000000077777d1d1dddddddddddddddddddd
ddddddddddddddddddddddddd77777700000067776000000777777770000000067770000077777777000000000000000007777771d1d1ddddddddddddddddddd
dddddddddddddddddddddddddd777770000005777500000077777777000000000777500007777777700000000000000000777771d1d1dddddddddddddddddddd
dddddddddddddddddddddddddd77777700000077700000077677777770000000007760007767777777000000000000000776777d1d1d1ddddddddddddddddddd
dddddddddddddddddddddddddd777677000000676000000777777767700000000007700077777776770000000000000007777771d1d1dddddddddddddddddddd
ddddddddddddddddddddddddddd7777770000057500000777777777777000000000070077777777777700000000000007777771d1d1d1ddddddddddddddddddd
dddddddddddddddddddddddddddd77777770000700007777777777777777000000000777777777777777700000000077777771d1d1d1dddddddddddddddddddd
dddddddddddddddddddddddddddd7777777770060077777777777777777777000007777777777777777777700000777777777d1d1d1ddddddddddddddddddddd
ddddddddddddddddddddddddddddd77777677777777767777777777777767777777776777777777777776777777777677777d1d1d1d1dddddddddddddddddddd
dddddddddddddddddddddddddddddd777777777677777777777777777777777767777777777777777777777776777777777d1d1d1d1ddddddddddddddddddddd
dddddddddddddddddddddddddddddddd777777777777777777777777777777777777777777777777777777777777777771d1d1d1d1dddddddddddddddddddddd
ddddddddddddddddddddddddddddddddd7777777777777777777777777777777777777777777777777777777777777771d1d1d1d1ddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddd1d17777777777777777777777777777777777777777777777777777777771d1d1d1d1d1d1dddddddddddddddddddddd
dddddddddddddddddddddddddddddddddd1d1d1d1d1d17777777777777777777777777777777777777771d1d1d1d1d1d1d1d1d1d1ddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddd1d1d1d1d1d1d77777777777777777777777777777777777d1d1d1d1d1d1d1d1d1d1d1dddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddd1d1d1d1d1d1d77777777777777777777777777777d1d1d1d1d1d1d1d1d1d1d1ddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddd1d1d1d1d1d1d1d77777777777777777777777d1d1d1d1d1d1d1d1d1d1d1d1dddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddd1d1d1d1d1d1d1d1d7777777777777d1d1d1d1d1d1d1d1d1d1d1d1d1ddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddd1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1dddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddd1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1ddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddd1d1d1d1d1d1d1d1d1d1d1d1d1d1d1dddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1d1d1d1d1d1d1d1d1d1d1d1ddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1d1d1d1d1d1d1dddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddaaaaaddddddaaaddaadadadaaaddddddaddadaddaadadddaadddaddddd
ddddddddddddddaaaaaddddddddddddddddddddddddddddddddddddddddddddddddddaa111aadddddaaa1ada1a1a1a111ddddad1da1a1ada1a1dda1adddadddd
dddddddddddddaaa1aaadddddddddddddddddddddddddddddddddddddddddddddddddaa1a1aa1dddda1a1a1a1a1a1aadddddda1ddaaa1a1a1a1dda1a1dda1ddd
dddddddddddddaa111aa1ddddddddddddddddddddddddddddddddddddddddddddddddaa111aa1dddda1a1a1a1aaa1a11ddddda1dda1a1a1a1a1dda1a1dda1ddd
ddddddaaaaaddaa111aa1daaaaadddddddaadaaadadddaaaddaadaaaddddddddddddddaaaaa11dddda1a1aad1da11aaaddddddadda1a1aad1aaadaaa1dad1ddd
dddddaaa11aaddaaaaa11aa11aaadddddad11a111a1dda111ad11da11dddddddddddddd11111dddddd1d1d11ddd1dd111dddddd1dd1d1d11dd111d111dd1dddd
dddddaa111aa1dd11111daa111aa1ddddaaadaadda1ddaadda1ddda1dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddaaa11aa1daaaaaddaa11aaa1ddddd1a1a11da1dda11da1ddda1dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddaaaaa11aa111aaddaaaaa11ddddaad1aaadaaadaaaddaadda1ddddddddddddddaaaaaddddddaaadadddaaadaaadddddddddddddddddddddddddddddddd
ddddddd11111daa111aa1dd11111dddddd11dd111d111d111dd11dd1dddddddddddddaa1a1aaddddda111a1ddda11a1a1ddddddddddddddddddddddddddddddd
dddddddddddddaaa1aaa1ddddddddddddddddddddddddddddddddddddddddddddddddaaa1aaa1ddddaadda1ddda1daaa1ddddddddddddddddddddddddddddddd
ddddddddddddddaaaaa11ddddddddddddddddddddddddddddddddddddddddddddddddaa1a1aa1dddda11da1ddda1da111ddddddddddddddddddddddddddddddd
ddddddddddddddd11111ddddddddddddddddddddddddddddddddddddddddddddddddddaaaaa11dddda1ddaaadaaada1ddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd11111dddddd1ddd111d111d1ddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd

