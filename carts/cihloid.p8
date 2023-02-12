pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- cihloid
-- by beaviscz

-- finished tutorial 31
-- todo:
-- 6. --slow, expand, reduce on timer, megaball timer, multiball release sticky
      --split random ball

-- 7. juiciness 
    --arrow animation 
    --text blinking
    --particles
    --screen shakes

-- 8. high score
-- 9. better collision detection
-- 10. gameplay tweaks 
    --smaller paddle


function _init()
    cls()
    left,right,up,down,fire1,fire2=0,1,2,3,4,5
    black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
  
    mode="start"
    debug=""
end

function _update60()
    if (mode=="game") then
        update_game()   
    --        slowmo=slowmo+1
    --        if slowmo==10 then 
    --            update_game()       
    --            slowmo=0
    --        end
    elseif (mode=="start") then
        update_start()
    elseif (mode=="gameover") then
        update_gameover()
    elseif (mode=="levelover") then
        update_levelover()
    end
end

function update_start()
    if (btn(fire2)) then
        startgame()
    end
end

function update_gameover()
    if (btn(fire2)) then
        startgame()
    end
end

function update_levelover()
    if (btn(fire2)) then
        nextlevel()
    end
end

function update_game()  
    local buttpress=false
    local nextx, nexty

    --expand pad powerup
    if powerup==4 then
        pad_w=flr(pad_wo*1.5)
    elseif powerup==5 then --shorten pad powerup
        pad_w=flr(pad_wo*0.5)
    else
        pad_w=pad_wo
    end

    --speed down powerup
    if powerup==1 then
        ball_speed=0.5
    else
        ball_speed=1
    end

    --megaball
    if powerup==6 then
        ball_c=8
    else
        ball_c=10
    end


    if (btn(left)) then
        buttpress=true
        pad_dx=-2.5
        pointstuck(-1)
    end
    if (btn(right)) then
        buttpress=true
        pad_dx=2.5
        pointstuck(1)
    end
    if not (buttpress) then
        pad_dx=pad_dx/1.4
    end

    --btnp for not pressed last frame - eliminates button press from start menu
    if btnp(fire2) then
        releasestuck()
    end

    pad_x+=pad_dx
    pad_x=mid(0,pad_x,127-pad_w)    
    
    -- big ball loop
    for bi=#ball, 1, -1 do
        update_ball(bi)
    end

    --move pills
    for i=1, #pill do
        --debug=i
        pill[i].y+=0.5
        if pill[i].y > 128 then
            del(pill,pill[i])
            break --must break from loop, array changed
        elseif box_box(pad_x, pad_y, pad_w, pad_h, pill[i].x, pill[i].y, 8, 6) then
            powerupget(pill[i].t)
            del(pill,pill[i])
            break --must break from loop, array changed
            sfx(11)
        end
    end

    explosioncheckt+=1
    if explosioncheckt>5 then
        checkexplosions()
        explosioncheckt=0
    end

    if levelfinished() then 
        levelover()
    end           

    if powerup!=0 then
        powerup_t-=1
        --debug=powerup_t
        if powerup_t<=0 then
            powerup=0
        end
    end
end

function update_ball(bi)
    myball=ball[bi]
    if myball.stuck then 
        myball.x=pad_x+sticky_dx
        myball.y=pad_y-ball_r-1
    else
        --regular physics
        nextx=myball.x+myball.dx*ball_speed
        nexty=myball.y+myball.dy*ball_speed

        --ball bouncing
        if nextx<2 or nextx>125 then
            nextx=mid(2,nextx,125)
            myball.dx=-myball.dx
            sfx(0)
        end
        if nexty<8  then
            nexty=8
            myball.dy=-myball.dy
            sfx(0)
        end
        --check if ball hits pad
        if (ball_box(nextx, nexty, pad_x, pad_y, pad_w, pad_h)) then
            --deal with collision
            if (deflx_ball_box(myball.x, myball.y, myball.dx, myball.dy, pad_x, pad_y, pad_w, pad_h)) then
                --hit from side
                myball.dx=-myball.dx
                if myball.x<pad_x+pad_w/2 then
                    nextx=pad_x-ball_r
                else
                    nextx=pad_x+pad_w+ball_r
                end
            else
                --hit from top or bottom
                myball.dy=-myball.dy
                if myball.y>pad_y then
                    --bottom
                    nexty=pad_y+pad_h+ball_r
                else
                    --top
                    nexty=pad_y-ball_r
                    --if pad is moving fast enough then change angle
                    if abs(pad_dx)>2 then
                        if sign(pad_dx)==sign(myball.dx) then
                            --flatten angle
                            setangle(myball,mid(0,myball.ang-1,2))                                
                        else
                            --raise angle
                            if myball.ang==2 then
                                --flip dir
                                myball.dx=-myball.dx
                            else                                
                                setangle(myball,mid(0,myball.ang+1,2))                                
                            end
                        end
                    end
                end
            end
            sfx(1)
            combo=0
            
            --catch powerup
            if sticky and myball.dy<0 then
                releasestuck()
                sticky=false
                myball.stuck=true
                sticky_dx=myball.x-pad_x
            end
--            if powerup==3 and myball.dy<0 then
--                sticky_dx=myball.x-pad_x
 --               sticky=true
 --           end
    
        end

        --check if ball hits brick
        for i=1,#brick do
            if brick[i].v then
                if (ball_box(nextx, nexty, brick[i].x, brick[i].y, brick_w, brick_h)) then
                    if (powerup!=6) or (powerup==6 and brick[i].t=="i")  then
                        if (deflx_ball_box(myball.x, myball.y, myball.dx, myball.dy, brick[i].x, brick[i].y, brick_w, brick_h)) then
                            myball.dx=-myball.dx
                        else
                            myball.dy=-myball.dy
                        end
                    end
                    hitbrick(i, true)
                    break
                end
            end
        end

        --move ball
        myball.x=nextx
        myball.y=nexty

        if (nexty>127) then
            if #ball==1 then 
                sfx(2)
                lives-=1
                if lives>0 then
                    serveball()
                else
                    gameover()
                end
            else
                del(ball, ball[bi])
            end
        end   
    end
end

function releasestuck()
    for i=1, #ball do
        if ball[i].stuck then
            ball[i].x=mid(3,ball[i].x,124)
            ball[i].stuck=false
        end
    end
end

function pointstuck(sign)
    for i=1, #ball do
        if ball[i].stuck then
            ball[i].dx=abs(ball[i].dx)*sign
        end
    end
end

function powerupget(_p)
    powerup=_p
    powerup_t=0

    if _p==1 then 
        --slowdown
        powerup_t=900
    elseif _p==2 then
        --life
        lives+=1
        powerup=0
    elseif _p==3 then
        --catch
        hasstuck=false
        for i=1, #ball do
            if ball[i].stuck then
                hasstuck=true
            end
        end
        if hasstuck==false then
            sticky=true
        end
    elseif _p==4 then
        --expand
        powerup_t=900
    elseif _p==5 then
        --reduce
        powerup_t=900
    elseif _p==6 then
        --megaball
        powerup_t=900
    elseif _p==7 then
        --multiball
        releasestuck()
        multiball()
        powerup=0
    end
end

function hitbrick(_i, _combo)
    if (brick[_i].t=="b") then
        sfx(3+combo)
        score+=10+(combo*10)
        if _combo then combo=mid(0,combo+1,6) end
        brick[_i].v=false
    elseif (brick[_i].t=="i") then
        sfx(10)
    elseif (brick[_i].t=="h") then
        sfx(10)
        score+=10+(combo*10)
        if _combo then combo=mid(0,combo+1,6) end
        if powerup!=6 then
            brick[_i].t="b"
        else
            brick[_i].v=false
        end
    elseif (brick[_i].t=="p") then
        sfx(3+combo)
        score+=10+(combo*10)
        if _combo then combo=mid(0,combo+1,6) end
        --TODO trigger power up
        spawnpill(brick[_i].x+1, brick[_i].y)
        brick[_i].v=false
    elseif (brick[_i].t=="s") then
        sfx(3+combo)
        score+=10+(combo*10)
        if _combo then combo=mid(0,combo+1,6) end
        brick[_i].t="zz"
    end
end

function spawnpill(_x,_y)
    local _t
    local _pill
    _t=flr(rnd(7))+1
    --if _t<3 then _t=3 else _t=7 end
    --_t=7
    
    _pill={}
    _pill.x=_x
    _pill.y=_y
    _pill.t=_t
    add(pill,_pill)
end

function checkexplosions()
    for i=1, #brick do
        if brick[i].t=="z" and brick[i].v then
            explodebrick(i)
        end
    end
    for i=1, #brick do
        if brick[i].t=="zz" and brick[i].v then
            brick[i].t="z"
        end
    end
end

function explodebrick(_i)  
    for i=1, #brick do
        if i!=_i
        and abs(brick[i].x-brick[_i].x)<=brick_w+2
        and abs(brick[i].y-brick[_i].y)<=brick_h+2 then
            hitbrick(i, false)
        end
    end
    brick[_i].v=false
end

function startgame()
    --ball radius
    ball_r=2
    ball_c=10

    pad_x=52
    pad_dx=0
    pad_y=120
    pad_w=24
    pad_wo=24 --original pad width
    pad_h=3
    pad_c=white
    
    
    brick={}
    brick_w=10
    brick_h=4

    mode="game"
    lives=3
    score=0
    sticky_dx=flr(pad_w/2)
    levelnum=1
    
    levels={}
    levels[1]="x/i9/b9/b9/h9/p9/p9/p9"
    --levels[1]="x/x/x/x/x/xxxxbbbxxx"
    levels[2]="i9/b2ibbib2/bsbibbibsb/bpbibbibpb/b3hhb3/s9"
    levels[3]="b9/b9/b2x3b2/bbx5bb/b2x3b2/b9/b9"
    pill={}
    buildbricks(levels[levelnum])
    serveball()

    slowmo=0
    explosioncheckt=0

end

function nextlevel()
    pad_x=52
    pad_dx=0
    pad_y=120

    brick={}

    mode="game"

    sticky_dx=flr(pad_w/2)
    sticky=false

    levelnum+=1
    if levelnum > #levels then
        --we won game
    else
        pill={}
        buildbricks(levels[levelnum])
        serveball()
    end
end

function gameover()
    mode="gameover"
end

function levelover()
    draw_game()
    mode="levelover" 
end

function serveball()
    ball={}
    ball[1]=newball()
    
    ball[1].x=pad_x+flr(pad_w/2)
    ball[1].y=pad_y-ball_r-1
    ball[1].dx=1
    ball[1].dy=-1
    --ball angles 0=flat angle (67 degree), 1=45 degree,  2=sharp angle (22 degree)
    ball[1].ang=1
    ball[1].stuck=true
    sticky=false
    sticky_dx=flr(pad_w/2)
    ball_speed=1

    pill={}
    combo=0
    powerup=0
    powerup_t=0
end

function newball()
    b = {}
    b.x = 0
    b.y = 0
    b.dx = 0
    b.dy = 0
    b.ang = 1
    b.stuck = false
    return b
end

function copyball(originalball)
    b={}
    b.x=originalball.x
    b.y=originalball.y
    b.dx=originalball.dx
    b.dy=originalball.dy
    b.ang=originalball.ang
    b.stuck=originalball.stuck
    return b
end


function setangle(bl, ang)
    bl.ang=ang
    if ang==2 then
        bl.dx=0.5*sign(bl.dx)
        bl.dy=1.3*sign(bl.dy)
    elseif ang==0 then
        bl.dx=1.3*sign(bl.dx)
        bl.dy=0.5*sign(bl.dy)
    else
        bl.dx=1*sign(bl.dx)
        bl.dy=1*sign(bl.dy)
    end
end

function multiball()
    ball2 = copyball(ball[1])
    ball3 = copyball(ball[1])
    if ball[1].ang==0 then
        setangle(ball2,1)
        setangle(ball3,2)
    elseif ball[1].ang==1 then
        setangle(ball2,0)
        setangle(ball3,2)
    else
        setangle(ball2,0)
        setangle(ball3,1)
    end
    add(ball, ball2)
    add(ball, ball3)
end

function sign(n)
    if n<0 then
        return -1
    elseif n>0 then
        return 1
    else 
        return 0
    end
end

function buildbricks(lvl)
    local i, j, x, y, chr, last
    brick={}
    x=0
    y=1
  --b normal brick, x empty space, / line breaker, i indestrictuble brick, h hardened brick, s exploding brick, p power up brick 

    for i=1, #lvl do
        x+=1
        chr=sub(lvl,i,i)
        if chr=="b" or chr=="i" or chr=="h" or chr=="s" or chr=="p" then
            last=chr
            addbrick(x,y,chr)
        elseif chr=="/" then
            x=0
            y+=1
        elseif chr>="1" and chr<="9" then
            for j=1, chr+0 do
                if last=="b" then
                    addbrick(x,y,"b")
                elseif last=="i" then
                    addbrick(x,y,"i")
                elseif last=="h" then
                    addbrick(x,y,"h")
                elseif last=="s" then
                    addbrick(x,y,"s")
                elseif last=="p" then
                    addbrick(x,y,"p")
                elseif last=="x" then
                end
                if j<chr+0 then
                    x+=1
                end
            end
        elseif chr=="x" then
            last="x"
        end
    end
end

function addbrick(_x,_y,_t)
    local _b
    _b={}
    _b.x=5+(_x-1)*(brick_w+2)
    _b.y=20+(_y-1)*(brick_h+2)
    _b.t=_t
    _b.v=true
    add(brick,_b)
end

function levelfinished()
    if #brick==0 then return true end
    for i=1, #brick do
        if brick[i].t!="i" and brick[i].v  then
            return false
        end
    end
    return true
end

function _draw()
    if (mode=="game") then
        draw_game()       
    elseif (mode=="start") then
        draw_start()
    elseif (mode=="gameover") then
        draw_gameover()
    elseif (mode=="levelover") then
        draw_levelover()
    end
end

function draw_start()
    cls(orange)
    print("cihloid",50,40,white)
    print("press ❎ to start ",30,60, red)
end

function draw_gameover()
    cls(orange)
    print("game over",45,40,white)
    print("press ❎ to start ",30,60, red)
end

function draw_levelover()
    rectfill(0,60,128,75,0)
    print("stage clear!",45,62,white)
    print("press ❎ to continue ",27,69, light_gray)
end

function draw_game()
    cls(dark_blue)
    for i=1,#ball do
        circfill(ball[i].x,ball[i].y,ball_r,ball_c)   
        if ball[i].stuck then
            line(ball[i].x+ball[i].dx*4, ball[i].y+ball[i].dy*4, ball[i].x+ball[i].dx*6, ball[i].y+ball[i].dy*6, 10)          
        end
    end

    --draw bricks
    for i=1,#brick do
        if brick[i].v then
            if brick[i].t == "b" then
                brickcol=pink
            elseif brick[i].t == "i" then
                brickcol=dark_gray
            elseif brick[i].t == "h" then
                brickcol=light_gray
            elseif brick[i].t == "s" then
                brickcol=yellow
            elseif brick[i].t == "z" then
                brickcol=red
            elseif brick[i].t == "zz" then
                brickcol=orange
            elseif brick[i].t == "p" then
                brickcol=blue
            end
            rectfill(brick[i].x, brick[i].y, brick[i].x+brick_w, brick[i].y+brick_h, brickcol)
        end
    end

    for i=1, #pill do
        if pill[i].t==5 then
            palt(0,false)
            palt(15,true)
        end
        spr(pill[i].t,pill[i].x, pill[i].y)
        palt()
    end

    rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,pad_c)
    
    rectfill(0,0,128,6,black)
    if debug!="" then
        print(debug,1,1,white)
    else
        print("lives:"..lives,1,1,white)
        print("score:"..score,80,1,white)
        --print("c:"..combo,45,1,red)
    end
end

--check collision between ball and any zone
function ball_box(bx, by, box_x, box_y, box_w, box_h)
    if (by-ball_r>box_y+box_h) then return false end
    if (by+ball_r<box_y) then return false end
    if (bx-ball_r>box_x+box_w) then return false end
    if (bx+ball_r<box_x) then return false end    
    return true
end

--check collision between any two zones
function box_box(bx1, by1, bw1, bh1, bx2, by2, bw2, bh2)
    if (by1>by2+bh2) then return false end
    if (by1+bh1<by2) then return false end
    if (bx1>bx2+bw2) then return false end
    if (bx1+bw1<bx2) then return false end
    return true
end


--calculate where to deflect
--bx-bdy ball positon and speed, tx-th target position and size 
function deflx_ball_box(bx, by, bdx, bdy, tx, ty, tw, th)
    local slp = bdy/bdx
    local cx, cy
    if bdx==0 then 
        return false
    elseif bdy==0 then
            return true
    elseif slp>0 and bdx>0 then
        cx=tx-bx
        cy=ty-by
        return cx>0 and cy/cx<slp
    elseif slp<0 and bdx>0 then
        cx=tx-bx
        cy=ty+th-by
        return cx>0 and cy/cx>=slp
    elseif slp>0 and bdx<0 then
        cx=tx+tw-bx
        cy=ty+th-by
        return cx<0 and cy/cx<=slp
    elseif slp<0 and bdx<0 then
        cx=tx+tw-bx
        cy=ty-by
        return cx<0 and cy/cx>=slp
    end
    return false
end


-->8
--test
__gfx__
0000000006777760067777600677776006777760f677776f06777760067777600000000000000000000000000000000000000000000000000000000000000000
00000000559949955577777555b33bb555ccccc55500000555e222e5558888850000000000000000000000000000000000000000000000000000000000000000
00700700559499955577877555b3bbb555c1c1c55580008555e222e5558a88850000000000000000000000000000000000000000000000000000000000000000
00077000559949955578887555b3bbb5551ccc155508080555e2e2e555888a850000000000000000000000000000000000000000000000000000000000000000
00077000559499955577877555b33bb555c1c1c55580008555e2e2e5558a88850000000000000000000000000000000000000000000000000000000000000000
00700700059999500577775005bbbb5005cccc50f500005f05eeee50058888500000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffaaaaaaaaaaaaaaaa66666666666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
feeeeeedabbbbbb3a9999998644444456cccccc10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
feeeeeedabbbbbb3a9999998644444456cccccc10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd333333338888888855555555111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000016330163301632016320163101631020300203001f3001a000170001700018400174001640016400164001b40023400264002c4002d4001f0001f0002100021000220002300036000320002c00029000
000100002233022330223202232022310223100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000283502835028350253501e350143301433017350193500f3400c340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002175023750237403030032300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002375024750247403030032300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002475026750267403030032300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002675028750287403030032300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002875029750297403030032300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000297502b7502b7403030032300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002b7502d7502d7403030032300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002b0502a050013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002f750290002400021000210003575028000290002200039750250002c0003200033000310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
