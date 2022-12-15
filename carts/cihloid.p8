pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- cihloid
-- by beaviscz

-- finished tutorial 24
-- todo:

-- 6. powerups
--  speed down
--  megaball
--  multiball

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
        ball_speed=0.7
    else
        ball_speed=1
    end

    if (btn(left)) then
        buttpress=true
        pad_dx=-2.5
        if sticky then
            ball_dx=-1
        end
    end
    if (btn(right)) then
        buttpress=true
        pad_dx=2.5
        if sticky then
            ball_dx=1
        end
    end
    if not (buttpress) then
        pad_dx=pad_dx/1.4
    end

    --btnp for not pressed last frame - eliminates button press from start menu
    if btnp(fire2) then
        if sticky then
            sticky=false
            ball_x=mid(3,ball_x,124)
        end
    end

    pad_x+=pad_dx
    pad_x=mid(0,pad_x,127-pad_w)    
    
    if sticky then 
        ball_x=pad_x+sticky_dx
        ball_y=pad_y-ball_r-1
    else
        nextx=ball_x+ball_dx*ball_speed
        nexty=ball_y+ball_dy*ball_speed

        --ball bouncing
        if nextx<2 or nextx>125 then
            nextx=mid(2,nextx,125)
            ball_dx=-ball_dx
            sfx(0)
        end
        if nexty<8  then
            nexty=8
            ball_dy=-ball_dy
            sfx(0)
        end
        --check if ball hits pad
        if (ball_box(nextx, nexty, pad_x, pad_y, pad_w, pad_h)) then
            --deal with collision
            if (deflx_ball_box(ball_x, ball_y, ball_dx, ball_dy, pad_x, pad_y, pad_w, pad_h)) then
                --hit from side
                ball_dx=-ball_dx
                if ball_x<pad_x+pad_w/2 then
                    nextx=pad_x-ball_r
                else
                    nextx=pad_x+pad_w+ball_r
                end
            else
                --hit from top or bottom
                ball_dy=-ball_dy
                if ball_y>pad_y then
                    --bottom
                    nexty=pad_y+pad_h+ball_r
                else
                    --top
                    nexty=pad_y-ball_r
                    --if pad is moving fast enough then change angle
                    if abs(pad_dx)>2 then
                        if sign(pad_dx)==sign(ball_dx) then
                            --flatten angle
                            setangle(mid(0,ball_ang-1,2))                                
                        else
                            --raise angle
                            if ball_ang==2 then
                                --flip dir
                                ball_dx=-ball_dx
                            else                                
                                setangle(mid(0,ball_ang+1,2))                                
                            end
                        end
                    end
                end
            end
            sfx(1)
            --score+=1
            combo=0
            
            --catch powerup
            if powerup==3 and ball_dy<0 then
                sticky_dx=ball_x-pad_x
                sticky=true
            end
    
        end

        --check if ball hits brick
        for i=1,#brick_x do
            if (brick_v[i]) then
                if (ball_box(nextx, nexty, brick_x[i], brick_y[i], brick_w, brick_h)) then
                    if (deflx_ball_box(ball_x, ball_y, ball_dx, ball_dy, brick_x[i], brick_y[i], brick_w, brick_h)) then
                        ball_dx=-ball_dx
                    else
                        ball_dy=-ball_dy
                    end
                    hitbrick(i, true)
                    break
                end
            end
        end

        --move ball
        ball_x=nextx
        ball_y=nexty

        if (nexty>127) then
            sfx(2)
            lives-=1
            if lives>0 then
                serveball()
            else
                gameover()
            end
        end   
    end

    --move pills
    for i=1, #pills_x do
        if pills_v[i] then
            pills_y[i]+=0.5
            if pills_y[i] > 128 then
                pills_v[i]=false
            end
            if box_box(pad_x, pad_y, pad_w, pad_h, pills_x[i], pills_y[i], 8, 6) then
                powerupget(pills_t[i])
                pills_v[i]=false
                sfx(11)
            end
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

function powerupget(_p)
    powerup=_p
    powerup_t=0

    if _p==1 then 
        --slowdown
        powerup_t=600
    elseif _p==2 then
        --life
        lives+=1
        powerup=0
    elseif _p==3 then
        --catch
        powerup_t=600
    elseif _p==4 then
        --expand
        powerup_t=600
    elseif _p==5 then
        --reduce
        powerup_t=600
    elseif _p==6 then
        --megaball
    elseif _p==7 then
        --multiball
    end
end

function hitbrick(_i, _combo)
    if (brick_t[_i]=="b") then
        sfx(3+combo)
        score+=10+(combo*10)
        if _combo then combo=mid(0,combo+1,6) end
        brick_v[_i]=false
    elseif (brick_t[_i]=="i") then
        sfx(10)
    elseif (brick_t[_i]=="h") then
        sfx(10)
        score+=10+(combo*10)
        if _combo then combo=mid(0,combo+1,6) end
        brick_t[_i]="b"
    elseif (brick_t[_i]=="p") then
        sfx(3+combo)
        score+=10+(combo*10)
        if _combo then combo=mid(0,combo+1,6) end
        brick_v[_i]=false
        --TODO trigger power up
        spawnpill(brick_x[_i]+1, brick_y[_i])
    elseif (brick_t[_i]=="s") then
        sfx(3+combo)
        score+=10+(combo*10)
        if _combo then combo=mid(0,combo+1,6) end
        brick_t[_i]="zz"
    end
end

function spawnpill(_x,_y)
    local _t
    _t=flr(rnd(7))+1
    _t=1
    add(pills_x,_x)
    add(pills_y,_y)
    add(pills_t,_t)
    add(pills_v,true)
end

function checkexplosions()
    for i=1, #brick_t do
        if brick_t[i]=="z" and brick_v[i] then
            explodebrick(i)
        end
    end
    for i=1, #brick_t do
        if brick_t[i]=="zz" and brick_v[i] then
            brick_t[i]="z"
        end
    end
end

function explodebrick(_i)  
    brick_v[_i]=false    
    for i=1, #brick_x do
        if i!=_i and brick_v[i]==true 
        and abs(brick_x[i]-brick_x[_i])<=brick_w+2
        and abs(brick_y[i]-brick_y[_i])<=brick_h+2 then
            hitbrick(i, false)
        end
    end
end

function startgame()
    --ball radius
    ball_r=2


    pad_x=52
    pad_dx=0
    pad_y=120
    pad_w=24
    pad_wo=24 --original pad width
    pad_h=3
    pad_c=white
    
    brick_x={}
    brick_y={}
    brick_v={}
    brick_w=10
    brick_h=4

    mode="game"
    lives=3
    score=0
    sticky=true
    sticky_dx=flr(pad_w/2)
    levelnum=1
    
    levels={}
    levels[1]="x/b9/x/p9/p9"
    levels[2]="i9/b2ihhib2/b2ihhib2/b2ihhib2/b3hhb3/s9"
    levels[3]="b9/b9/b2x3b2/bbx5bb/b2x3b2/b9/b9"
    resetpills()
    buildbricks(levels[levelnum])
    serveball()

    slowmo=0
    explosioncheckt=0

end

function nextlevel()
    pad_x=52
    pad_dx=0
    pad_y=120

    brick_x={}
    brick_y={}
    brick_v={}

    mode="game"
    sticky=true
    sticky_dx=flr(pad_w/2)

    levelnum+=1
    if levelnum > #levels then
        --we won game
    else
        resetpills()
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
    ball_x=pad_x+flr(pad_w/2)
    ball_y=pad_y-ball_r-1
    ball_speed=1
    ball_dx=1
    ball_dy=-1
    sticky=true
    sticky_dx=flr(pad_w/2)

    resetpills()
    combo=0
    powerup=0
    powerup_t=0
    --ball angles 0=flat angle (67 degree), 1=45 degree,  2=sharp angle (22 degree)
    ball_ang=1
end

function setangle(ang)
    ball_ang=ang
    if ang==2 then
        ball_dx=0.5*sign(ball_dx)
        ball_dy=1.3*sign(ball_dy)
    elseif ang==0 then
        ball_dx=1.3*sign(ball_dx)
        ball_dy=0.5*sign(ball_dy)
    else
        ball_dx=1*sign(ball_dx)
        ball_dy=1*sign(ball_dy)
    end
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
    brick_x={}
    brick_y={}
    brick_v={}
    brick_t={}

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

function resetpills()
    pills_x={}
    pills_y={}
    pills_v={}
    pills_t={}
end    

function addbrick(_x,_y,_t)
    add(brick_x, 5+(_x-1)*(brick_w+2))
    add(brick_y, 20+(_y-1)*(brick_h+2))
    add(brick_v, true)
    add(brick_t, _t)
end

function levelfinished()
    if #brick_v==0 then return true end
    for i=1, #brick_v do
        if brick_v[i]==true and brick_t[i]!="i" then
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
    circfill(ball_x,ball_y,ball_r,10)
    if sticky then
        --serve direction preview
        line(ball_x+ball_dx*4, ball_y+ball_dy*4, ball_x+ball_dx*6, ball_y+ball_dy*6, 10)   
    end
    
    --draw bricks
    for i=1,#brick_x do
        if (brick_v[i]) then
            if brick_t[i] == "b" then
                brickcol=pink
            elseif brick_t[i] == "i" then
                brickcol=dark_gray
            elseif brick_t[i] == "h" then
                brickcol=light_gray
            elseif brick_t[i] == "s" then
                brickcol=yellow
            elseif brick_t[i] == "z" then
                brickcol=red
            elseif brick_t[i] == "zz" then
                brickcol=orange
            elseif brick_t[i] == "p" then
                brickcol=blue
            end
            rectfill(brick_x[i], brick_y[i], brick_x[i]+brick_w, brick_y[i]+brick_h, brickcol)
            --spr(1,brick_x[i], brick_y[i])
        end      
    end

    for i=1, #pills_x do
        if pills_v[i] then
            if pills_t[i]==5 then
                palt(0,false)
                palt(15,true)
            end
            spr(pills_t[i],pills_x[i], pills_y[i])
            palt()
        end
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
00000000559949955578777555b33bb555c1c1c55508800555e222e5558888850000000000000000000000000000000000000000000000000000000000000000
00700700559499955578777555b3bbb555cc1cc55508080555e222e5558a88850000000000000000000000000000000000000000000000000000000000000000
00077000559949955578777555b3bbb555cc1cc55508800555e2e2e555888a850000000000000000000000000000000000000000000000000000000000000000
00077000559499955578877555b33bb555c1c1c55508080555e2e2e5558a88850000000000000000000000000000000000000000000000000000000000000000
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
