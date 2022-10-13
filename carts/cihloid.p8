pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
-- cihloid
-- by beaviscz

-- finished tutorial 12
-- todo:
-- 1. sticky paddle
-- 2. angle control
-- 3. combos
-- 4. levels
-- 5. different bricks
-- 6. powerups
-- 7. juiciness (particles/screen shakes)
-- 8. high score


function _init()
    cls()
    left,right,up,down,fire1,fire2=0,1,2,3,4,5
    black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
  
    mode="start"

    ball_x=10
    ball_dx=1
    ball_y=90
    ball_dy=1
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

    lives=3
    score=0
end

function _update60()
    if (mode=="game") then
        update_game()       
    elseif (mode=="start") then
        update_start()
    elseif (mode=="gameover") then
        update_gameover()
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

function update_game()
    local buttpress=false
    local nextx, nexty

    if (btn(left)) then
        buttpress=true
        pad_dx=-2.5
    end
    if (btn(right)) then
        buttpress=true
        pad_dx=2.5
    end
    if not (buttpress) then
        pad_dx=pad_dx/1.4
     end

    pad_x+=pad_dx
    pad_x=mid(0,pad_x,127-pad_w)    
    
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
        if (deflx_ball_box(ball_x, ball_y, ball_dx, ball_dy, pad_x, pad_y, pad_w, pad_h)) then
            ball_dx=-ball_dx
            if ball_x<pad_x+pad_w/2 then
                nextx=pad_x-ball_r
            else
                nextx=pad_x+pad_w+ball_r
            end
        else
            ball_dy=-ball_dy
            if ball_y>pad_y then
                nexty=pad_y+pad_h+ball_r
            else
                nexty=pad_y-ball_r
            end
        end
        sfx(1)
        score+=1
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
                sfx(1)
                score+=10
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
end

function startgame()
    mode="game"
    lives=3
    score=0
    buildbricks()
    serveball()
end

function gameover()
    mode="gameover"
end

function serveball()
    ball_x=10
    ball_dx=1
    ball_y=70
    ball_dy=1
end

function buildbricks()
    local i
    brick_x={}
    brick_y={}
    brick_v={}
    for j=1, 6 do
        for i=1, 10 do
            add(brick_x, 5+(i-1)*(brick_w+2)) 
            add(brick_y, 20+(j-1)*(brick_h+2)) 
            add(brick_v, true) 
        end
    end
end

function _draw()
    if (mode=="game") then
        draw_game()       
    elseif (mode=="start") then
        draw_start()
    elseif (mode=="gameover") then
        draw_gameover()
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

function draw_game()
    cls(dark_blue)
    circfill(ball_x,ball_y,ball_r,10)
    
    --draw bricks
    for i=1,#brick_x do
        if (brick_v[i]) then
            rectfill(brick_x[i], brick_y[i], brick_x[i]+brick_w, brick_y[i]+brick_h, orange)
        end      
    end

    rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,pad_c)
    
    rectfill(0,0,128,6,black)
    print("lives:"..lives,1,1,white)
    print("score:"..score,90,1,white)
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


__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000016330163301632016320163101631020300203001f3001a000170001700018400174001640016400164001b40023400264002c4002d4001f0001f0002100021000220002300036000320002c00029000
000100002233022330223202232022310223100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000283502835028350253501e350143301433017350193500f3400c340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
