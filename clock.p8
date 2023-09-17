pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--main
function _init()
	ct=make_ct()	--clocks table
	pt=make_pt()	--pins table
	make_graph(ct,pt)
	
	cur_x=1						--cursor x
	cur_y=1						--cursor y
	cur_z=1						--cursor z (flipped)

	c=make_c()			--useful constants
	t=1										--touch counter
	d=true							--draw flag
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

	if (right or left) and not btn(❎) then
		local delta=2
		if (left) delta=-2
		cur_x+=delta
		if (cur_x<1) cur_x=1
		if (cur_x>3) cur_x=3
		d=true
	end
	
	if (up or down) and not btn(❎) then
		local delta=2
		if (up) delta=-2
		cur_y+=delta
		if (cur_y<1) cur_y=1
		if (cur_y>3) cur_y=3
		d=true
	end
	
	if btn(❎) and (right or left) then
		t+=1
		local delta=1
		if (left) delta=-1
		ct[cur_x][cur_y][cur_z].update(delta,t)
		d=true
	end
	
	if btnp(🅾️) then
		if cur_z==1 then
			cur_z=2
		else
			cur_z=1
		end
		d=true
	end
end

function _draw()
	if (not d) return

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
		draw_shape(69,69,d,r,1)
	fillp()

	--puzzle
	draw_shape(64,64,d,r,7)

	--clocks
	for x=1,3 do
 	for y=1,3 do
			local clock=ct[x][y][cur_z]
			clock.draw(64,64,d,cur_z)
		end
	end

	-- draw ticks
	for row=-1,1 do
		for col=-1,1 do
			for t=1,12 do
				if t==12 then
					spr(14,64+col*d-1,64+row*d-11)
				else
					pset(
						64.5+col*d+c[t].dx*11,
						64.5+row*d+c[t].dy*11,
						6
					)
				end
			end
		end
	end
	
	--draw cursor
	local draw_cur_x=cur_x
	if cur_z==2 then
		if (cur_x==1) draw_cur_x=3
		if (cur_x==3) draw_cur_x=1
	end
	circfill(
		(draw_cur_x-1)*54+10,
		(cur_y-1)*54+10,
		3,
		11
	)
	
	d=false
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
		end
	}
end
-->8
--pins
function make_pt()
	local pt={{},true,{}}

	for x=1,3,2 do
		for y=1,3,2 do
			pt[x][y] = new_p()
		end
	end

	return pt
end

function new_p(x,y)
	--private properties
	local z=flr(rnd(2))+1	--position
	local ct={{},{}}	--linked clocks table
	local lt=0							--last touch

	--public interface
	return {
		read=function ()
			return z
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
