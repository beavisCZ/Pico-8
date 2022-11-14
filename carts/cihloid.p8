pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- cihloid
-- by beaviscz

-- finished tutorial 17
-- todo:
-- 1. sticky paddle DONE
-- 2. angle control DONE
-- 3. combos DONE
-- 4. levels
    --patters DONE
    --level finish detection DONE
    --load next level DONE
-- 5. different bricks
-- 6. powerups
-- 7. juiciness 
    --arrow animation 
    --text blinking
    --particles
    --screen shakes
-- 8. high score


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
        end
    end

    pad_x+=pad_dx
    pad_x=mid(0,pad_x,127-pad_w)    
    
    if sticky then 
        ball_x=pad_x+flr(pad_w/2)
        ball_y=pad_y-ball_r-1
    else
        nextx=ball_x+ball_dx
        nexty=ball_y+ball_dy

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
                    sfx(3+combo)
                    score+=10+(combo*10)
                    combo=mid(0,combo+1,6)
                    brick_v[i]=false
                    break
                end
            end
        end

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

        if levelfinished() then 
            levelover()
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
    levelnum=1
    levels={}
    levels[1]="bhisppsihb"
    levels[2]="b9/b9/b2x3b2/bbx5bb/b2x3b2/b9/b9"
    buildbricks(levels[levelnum])
    serveball()

    slowmo=0

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
    levelnum+=1
    if levelnum > #levels then
        --we won game
    else
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
    ball_dx=1
    ball_dy=-1
    sticky=true
    combo=0
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

function addbrick(_x,_y,_t)
    add(brick_x, 5+(_x-1)*(brick_w+2))
    add(brick_y, 20+(_y-1)*(brick_h+2))
    add(brick_v, true)
    add(brick_t, _t)
end

function levelfinished()
    if #brick_v==0 then return true end
    for i=1, #brick_v do
        if brick_v[i]==true then
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
                brickcol=red
            elseif brick_t[i] == "p" then
                brickcol=blue
            end
            rectfill(brick_x[i], brick_y[i], brick_x[i]+brick_w, brick_y[i]+brick_h, brickcol)
            --spr(1,brick_x[i], brick_y[i])
        end      
    end

    rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,pad_c)
    
    rectfill(0,0,128,6,black)
    if debug!="" then
        print(debug,1,1,white)
    else
        print("lives:"..lives,1,1,white)
        print("score:"..score,80,1,white)
        print("c:"..combo,45,1,red)
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700ffffffffaaaaaaaaaaaaaaaa666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000feeeeeedabbbbbb3a9999998644444456cccccc100000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000feeeeeedabbbbbb3a9999998644444456cccccc100000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700dddddddd3333333388888888555555551111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000016330163301632016320163101631020300203001f3001a000170001700018400174001640016400164001b40023400264002c4002d4001f0001f0002100021000220002300036000320002c00029000
000100002233022330223202232022310223100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000283502835028350253501e350143301433017350193500f3400c340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100002175023750237403030032300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100002375024750247403030032300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100002475026750267403030032300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100002675028750287403030032300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100002875029750297403030032300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010000297502b7502b7403030032300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002b7502d7502d7403030032300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
