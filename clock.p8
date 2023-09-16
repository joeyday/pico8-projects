pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- main
function _init()
	front={}
	front[-1]={}
	front[0]={}
	front[1]={}
	back={}
	back[-1]={}
	back[0]={}
	back[1]={}
 pins={true,true,true,true}

	scramble()

 flipped=false

 dirty=true

	cls(13)
	
end

function _update()
 if btnp(❎) then
 	flipped=not flipped
 	dirty=true
 end
end

function _draw()
	if dirty then
		draw_puzzle(flipped)
		dirty=false
	end
end


-->8
-- dials
--[[ for r=0,1 do
 	for c=-1,0 do
		 circfill(64+r*d, 64+c*d, 12, dialcol)
			drawhand(t,64+r*d,64+c*d)
		end
	end ]]
	
function draw_dial(v,x,y)
	circfill(x,y,9,0)
	sspr(c[v].sx,0,21,21,x-10,y-10,21,21,c[v].fx,c[v].fy)
end
-->8
-- pins

-->8
-- constants

c={}

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

-->8
-- helper functions
function solve()
	for row=-1,1 do
		for col=-1,1 do
			front[row][col]=12
			back[row][col]=12
		end
	end
end

function scramble()
	for row=-1,1 do
		for col=-1,1 do
			front[col][row]=flr(rnd(12))+1
			if row!=0 and col!=0 then
				back[col][row]=front[col][row]
			else
				back[col][row]=flr(rnd(12))+1
			end
		end
	end
	
	for i=1,#pins do
		pins[i]=true
		if flr(rnd(2))==0 then
			pins[i]=false
		end
	end
end
-->8
-- draw functions
function draw_puzzle(flipped)
	-- adjust size
	d=25

	-- invert colors
	pal()
	if flipped then
		pal(7,0)
		pal(6,5)
		pal(5,6)
		pal(0,7)
	end

	-- draw shadow
	fillp(▒)
	circfill(69, 69, d*1.825, 1)
	for row=-1,1,2 do
		for col=-1,1,2 do
		 local x = 69+col*d
		 local y = 69+row*d
		 circfill(x, y, d/2+1, 1)
		end
	end
	fillp()
	
	-- draw clock
	circfill(64, 64, d*1.825, 7)
	for row=-1,1,2 do
		for col=-1,1,2 do
		 local x = 64+col*d
		 local y = 64+row*d
		 circfill(x, y, d/2+2, 7)
		end
	end

	-- draw dials
 local co=-1
 local cn=1
 
	for row=-1,1 do
 	for col=co,cn do
			draw_dial(
				ceil(rnd(12)),
				64+col*d,
				64+row*d
			)
		end
	end

	-- draw time ticks
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

end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008880000000000000
00000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000
00700000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000575000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000676000000000000000000000000077000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700000000000000777000000000000000000000000776000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000005777500000000000000000000007775000000000000000000000005677000000000000000000000000000000000000000000000000000000
00000000000000006777600000000000000000000067770000000000000000000005677770000000000000000000000000000000000000000000000000000000
00000000000000000575000000000000000000000007760000000000000000000000777700000000000000000000065000000000000000000000000000000000
00000000000000000575000000000000000000000576050000000000000000000576777000000000000000000575577765000000000000000000000000000000
00000000000000000707000000000000000000000707000000000000000000000707060000000000000000000707777777760000000000000000000000000000
00000000000000000575000000000000000000000575000000000000000000000575000000000000000000000575577765000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000065000000000000000000000000000000000
