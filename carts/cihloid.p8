pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- cihloid
-- by beaviscz

-- finished tutorial 45

-- 8. high score
-- 9. UI
    -- powerup messages
    -- powerup percentage bar
-- 10. better collision detection
-- 11. gameplay tweaks 
    --smaller paddle
-- 12. level design
-- 13. sound
    -- level over fanfare
    -- start screen music
    -- high score music


function _init()
    cls()
    left,right,up,down,fire1,fire2=0,1,2,3,4,5
    black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
  
    mode="start"
    debug=""

    --highscore
    cartdata("cihloid")
    hs={}
    hs1={}
    hs2={}
    hs3={}
    hschars={"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"}

    --reseths()
    loadhs()
--    addhs(8000,1,1,1)
--    addhs(1888,2,2,2)

    
    --juicyness
    shake=0
    blinkframe=0
    blinkspeed=7
    blinkgreen=green
    blinkgreen_i=1
    blinkred=red
    blinkred_i=1
    fadeperc=0
    fadelength=40
    startcountdown=-1

    arrowframe=0
    arrowmult=1
    arrowmult2=1

    --particles
    part={}
    lasthitx=0
    lasthity=0

   
end

function _update60()
    doblink()
    updateparts()
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
    elseif (mode=="gameoverwait") then
        update_gameoverwait()
    elseif (mode=="levelover") then
        update_levelover()
    end
end

function update_start()
    if startcountdown<0 then
        if (btn(fire2)) then
            sfx(13)
            startcountdown=fadelength
            blinkspeed=1
            --fadeperc=0
        end
    else
        startcountdown-=1
        fadeperc=(fadelength-startcountdown)/fadelength
        if startcountdown<1 then
            startgame()
            blinkspeed=7
            startcountdown=-1
            --fadeperc=0
        end
    end
end

function update_gameoverwait()
    govercountdown-=1
    if govercountdown<=0 then 
        govercountdown= -1
        mode="gameover"
    end
end

function update_gameover()
    if startcountdown<0 then
        if (btn(fire2)) then
            sfx(13)
            startcountdown=fadelength
            blinkspeed=1
            --fadeperc=0
        end
    else
        startcountdown-=1
        fadeperc=(fadelength-startcountdown)/fadelength
        if startcountdown<1 then
            startgame()
            blinkspeed=7
            startcountdown=-1
            --fadeperc=0
        end
    end   
end

function update_levelover()
    if startcountdown<0 then
        if (btn(fire2)) then
            sfx(13)
            startcountdown=fadelength
            blinkspeed=1
            --fadeperc=0
        end
    else
        startcountdown-=1
        fadeperc=(fadelength-startcountdown)/fadelength
        if startcountdown<1 then
            nextlevel()
            blinkspeed=7
            startcountdown=-1
            --fadeperc=0
        end
    end 
end

function update_game()  
    local buttpress=false
    local nextx, nexty

    --fade in game
    if fadeperc!=0 then
        fadeperc-=0.05
        if fadeperc<0 then fadeperc=0 end
    end
    --******powerups*******
    --speed down powerup
    if timer_slow>0 then
        ball_speed=0.5
        timer_slow-=1
    else
        ball_speed=1
    end

    if timer_expand>0 then
        pad_w=flr(pad_wo*1.5)
        timer_expand-=1
    elseif timer_reduce>0 then
        pad_w=flr(pad_wo*0.5)
        timer_reduce-=1    
    else
        pad_w=pad_wo
    end

    --megaball
    if timer_megaball>0 then
        ball_c=red
        timer_megaball-=1
    else
        ball_c=yellow
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
            spawnpillsmoke(pill[i].x, pill[i].y,pill[i].t)
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

    --animate bricks
    animatebricks()

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
            spawnsmoke(nextx, nexty)
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
            spawnsmoke(nextx, nexty)
            
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
                    lasthitx=myball.dx
                    lasthity=myball.dy

                    if (timer_megaball<=0) or (timer_megaball>0 and brick[i].t=="i")  then
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
        
        --trail particle
        spawntrail(nextx, nexty)


        if (nexty>127) then
            sfx(2)
            spawndeath(myball.x, myball.y)
            if #ball==1 then 
                shake+=0.4
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
    if _p==1 then 
        --slowdown
        timer_slow = 300
    elseif _p==2 then
        --life
        lives+=1
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
        timer_expand=300
        timer_reduce=0
    elseif _p==5 then
        --reduce
        timer_expand=0
        timer_reduce=300
    elseif _p==6 then
        --megaball
        timer_megaball=200
    elseif _p==7 then
        --multiball
        multiball()
    end
end

function hitbrick(_i, _combo)  
    local flashtime=14
    if (brick[_i].t=="b") then
        --base brick
        sfx(3+combo)
        score+=10+(combo*10)
        if _combo then combo=mid(0,combo+1,6) end
        brick[_i].flash=flashtime
        brick[_i].v=false
        --spawn particles
        shatterbrick(brick[_i], lasthitx, lasthity)
    elseif (brick[_i].t=="i") then
        --indestructible brick
        sfx(10)
    elseif (brick[_i].t=="h") then
        --hardened brick
        sfx(10)
        score+=10+(combo*10)
        if _combo then combo=mid(0,combo+1,6) end
        if powerup!=6 then
            --brick[_i].flash=flashtime
            brick[_i].t="b"
        else
            brick[_i].flash=flashtime
            brick[_i].v=false
            shatterbrick(brick[_i], lasthitx, lasthity)
        end
    elseif (brick[_i].t=="p") then
        --powerup brick
        sfx(3+combo)
        score+=10+(combo*10)
        if _combo then combo=mid(0,combo+1,6) end
        spawnpill(brick[_i].x+1, brick[_i].y)
        brick[_i].flash=flashtime
        brick[_i].v=false
        --spawn particles
        shatterbrick(brick[_i], lasthitx, lasthity)
    elseif (brick[_i].t=="s") then
        --explosion brick
        sfx(3+combo)
        score+=10+(combo*10)
        if _combo then combo=mid(0,combo+1,6) end
        brick[_i].t="zz"
        --spawn particles
        shatterbrick(brick[_i], lasthitx, lasthity)
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
    shake+=0.15 
    sfx(12)
    spawnexplosion(brick[_i].x, brick[_i].y)
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
    ball_c=yellow

    pad_x=52
    pad_dx=0
    pad_y=120
    pad_w=24
    pad_wo=24 --original pad width
    pad_h=3
    pad_c=white
    
    
    brick={}
    brick_w=9.6
    brick_h=4

    mode="game"
    lives=3
    score=0
    sticky_dx=flr(pad_w/2)
    levelnum=1
    
    levels={}
    --levels[1]="x/i9i/b9b/bbsbbsbbsbb/h9h/p9p/p9p/p9p"
    levels[1]="x/x/x/x/x/sbbpsbspsbs"
    --levels[1]="x/x/x/x/x/x4b3/s9s2"
    levels[2]="i9i/b2ibbib2b/bsbibbibsbb/bpbibbibpbb/b3hhb3b/s9s"
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
    sfx(14)
    mode="gameoverwait"
    govercountdown=60
    blinkspeed=16
end

function levelover()
    mode="levelover" 
    lovercountdown=60
    blinkspeed=16
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
    timer_slow=0
    timer_reduce=0
    timer_expand=0
    timer_megaball=0
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
    local ballnum = flr(rnd(#ball))+1
    local ball2 = copyball(ball[ballnum])
    local ball3 = copyball(ball[ballnum])
    ball2.stuck=false
    ball3.stuck=false
    if ball[ballnum].ang==0 then
        setangle(ball2,1)
        setangle(ball3,2)
    elseif ball[ballnum].ang==1 then
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
    _b.x=1+(_x-1)*(brick_w+2)
    _b.y=20+(_y-1)*(brick_h+2)
    _b.t=_t
    _b.v=true
    _b.flash=0
    _b.ox=0 --offset for bouncing
    _b.oy=-(128+rnd(128))
    _b.dx=0 --speed
    _b.dy=rnd(50)
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
    doshake()
    if (mode=="game") then
        draw_game()       
    elseif (mode=="start") then
        draw_start()
    elseif (mode=="gameover") then
        draw_gameover()
    elseif (mode=="levelover") then
        draw_game()
        draw_levelover()
--    elseif (mode=="leveloverwait") then
--        draw_game()
    elseif (mode=="gameoverwait") then
        draw_game()
    end
    pal()
    if fadeperc!=0 then fadepal(fadeperc) end
end

function draw_start()
    cls()
    rectfill(0,0,127,127,orange)
    print("cihloid",50,10,white)   
    prinths(40)
    print("press ❎ to start ",30,80, blinkred)
end

function draw_gameover()
    cls()
    rectfill(0,0,127,127,orange)
    print("game over",45,40,white)
    print("press ❎ to start ",30,60, blinkred)
end

function draw_levelover()
    rectfill(0,60,128,75,0)
    print("stage clear!",45,62,white)
    print("press ❎ to continue ",27,69, blinkred)
end

function draw_game()
    cls()
    rectfill(0,0,127,127,dark_blue) --black border when screen shaking instead of cls

    --draw bricks
    for i=1,#brick do
        local _b=brick[i]
        if _b.v or _b.flash>0 then
            if _b.flash>0 then
                brickcol=white
                _b.flash-=1
            elseif _b.t == "b" then
                brickcol=pink
            elseif _b.t == "i" then
                brickcol=dark_gray
            elseif _b.t == "h" then
                brickcol=light_gray
            elseif _b.t == "s" then
                brickcol=yellow
            elseif _b.t == "z" then
                brickcol=red
            elseif _b.t == "zz" then
                brickcol=orange
            elseif _b.t == "p" then
                brickcol=blue
            end
            local _bx=_b.x+_b.ox
            local _by=_b.y+_b.oy
            rectfill(_bx, _by, _bx+brick_w, _by+brick_h, brickcol)
        end
    end

    --particles
    drawparts()

    for i=1, #pill do
        if pill[i].t==5 then
            palt(0,false)
            palt(15,true)
        end
        spr(pill[i].t,pill[i].x, pill[i].y)
        palt()
    end

    for i=1,#ball do
        circfill(ball[i].x,ball[i].y,ball_r,ball_c)   
        if ball[i].stuck then
            pset(ball[i].x+ball[i].dx*4*arrowmult, ball[i].y+ball[i].dy*4*arrowmult,10)
            pset(ball[i].x+ball[i].dx*4*arrowmult2, ball[i].y+ball[i].dy*4*arrowmult2,10)
            --line(ball[i].x+ball[i].dx*4*arrowmult, 
            --ball[i].y+ball[i].dy*4*arrowmult, 
            --ball[i].x+ball[i].dx*6*arrowmult, 
            --ball[i].y+ball[i].dy*6*arrowmult, 10)          
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

-------juicy stuff---------
--shake screen
function doshake()
    local shakex=(16-rnd(32))*shake
    local shakey=(16-rnd(32))*shake
    camera(shakex, shakey)
    shake=shake*0.95
    if shake<0.05 then shake=0 end
end

--blinking text
function doblink()
    local green_seq = {dark_green, green, white, green}
    local red_seq={dark_purple,red,pink,red}

    --txt blinking
    blinkframe+=1
    if blinkframe>blinkspeed then 
        blinkframe=0
        blinkgreen=green_seq[blinkgreen_i]
        blinkred=red_seq[blinkred_i]
        blinkgreen_i+=1
        blinkred_i+=1
        if blinkgreen_i>#green_seq then blinkgreen_i=1 end
        if blinkred_i>#red_seq then blinkred_i=1 end
    end

    --ball trajectory anim
    --first point
    arrowframe+=1
    if arrowframe>30 then
        arrowframe=0
    end
    arrowmult=1+(2*(arrowframe/30))
    --second point
    local tmpf=arrowframe+15
    if tmpf>30 then tmpf=tmpf-30 end
    arrowmult2=1+(2*(tmpf/30))
end 

--fading
function fadepal(_perc)
    local p=flr(mid(0,_perc*100,100))
    local kmax, col, dpal, j, k
    dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14}
    for j=1,15 do
        col=j
        kmax=(p+(j*1.46))/22
        for k=1,kmax do
            col=dpal[col]
        end
        pal(j,col,1)
    end 
end

--particle stuff
--add a partice
--type 0 - static pixel
--type 1 - gravity pixel
--type 2 - ball of smoke 
--type 3 - rotating sprite
function addpart(_x, _y, _dx, _dy, _type, _maxage, _colors, _size)
    local _p = {}
    _p.x=_x
    _p.y=_y
    _p.dx=_dx
    _p.dy=_dy
    _p.type=_type
    _p.maxage=_maxage
    _p.age=0
    _p.color=_colors[1]
    _p.colarray=_colors
    _p.rotation=0
    _p.rottimer=0
    _p.size=_size
    _p.originalsize=_size
    add(part,_p)
end

--spawn a trail particle
function spawntrail(_x, _y)
    if rnd()<0.7 then
        local _ang = rnd()
        local _ox = sin(_ang)*ball_r*0.6
        local _oy = cos(_ang)*ball_r*0.6
        if ball_c==yellow then           
            addpart(_x+_ox, _y+_oy, 0, 0, 0, 15+rnd(15),{yellow, orange, brown},0)
        else
            addpart(_x+_ox, _y+_oy, 0, 0, 0, 15+rnd(15),{red, dark_purple},0)
        end
    end
end

--spawn smoke
function spawnsmoke(_x, _y)
    for i=0,5 do
        local _ang = rnd()
        local _dx = sin(_ang)*1.5
        local _dy = cos(_ang)*1.5     
        addpart(_x, _y, _dx, _dy, 2, 20+rnd(15),{white, light_gray, dark_gray}, 2+rnd(1.5))
    end
end

--spawn pill smoke
function spawnpillsmoke(_x, _y, _pill)

    local _mycol 
    if _pill == 1 then
        --slowdown orange
        _mycol = {9,9,4,4,0}
    elseif _pill == 2 then
        --life white
        _mycol = {7,7,6,5,0}
    elseif _pill == 3 then
        --catch green
        _mycol = {11,11,3,3,0}
    elseif _pill == 4 then
        --expand blue
        _mycol = {12,12,2,2,0}
    elseif _pill == 5 then
        --reduce black
        _mycol = {0,0,5,5,6}
    elseif _pill == 6 then
        --megaball pink
        _mycol = {14,14,13,2,0}
    else
        --multiball red
        _mycol = {8,8,8,4,2,0}
    end

    for i=0,20 do
        local _ang = rnd()
        local _dx = sin(_ang)*1.8
        local _dy = cos(_ang)*1.8 

        --pos, speed, type, time to live, color, size
        addpart(_x, _y, _dx, _dy, 2, 30+rnd(15),_mycol, 3+rnd(1.5))
    end
end

--spawn death particles
function spawndeath(_x, _y)

    local _mycol = {10,10,9,4,0}

    for i=0,20 do
        local _ang = rnd()
        
        --speed
        local _dx = sin(_ang)*(1.5+rnd(1.5))
        local _dy = cos(_ang)*(1.5+rnd(1.5))
        
        --pos, speed, type, time to live, color, size
        addpart(_x, _y, _dx, _dy, 2, 40+rnd(40),_mycol, 4+rnd(2))
    end
end

--spawn explosion particles
function spawnexplosion(_x, _y)

    local _mycol = {0,0,5,5,6}

    --first smoke
    for i=0,20 do
        local _ang = rnd()
        
        --speed
        local _dx = sin(_ang)*(1.8+rnd(1.8))
        local _dy = cos(_ang)*(1.8+rnd(1.8))
        
        --pos, speed, type, time to live, color, size
        addpart(_x, _y, _dx, _dy, 2, 80+rnd(40),_mycol, 3+rnd(6))
    end

    --second fire
    _mycol = {7,10,10,9,8}
    for i=0,30 do
        local _ang = rnd()
        
        --speed
        local _dx = sin(_ang)*(1.5+rnd(1.5))
        local _dy = cos(_ang)*(1.5+rnd(1.5))
        
        --pos, speed, type, time to live, color, size
        addpart(_x, _y, _dx, _dy, 2, 30+rnd(15),_mycol, 2+rnd(4))
    end    
end

--shatter brick
function shatterbrick(_b, _vx, _vy)
    if shake<0.2 then
        shake+=0.07
    end
        sfx(15)
    --bump brick
    _b.dx= _vx*0.7
    _b.dy= _vy*0.7

    for i=0,10 do
        local _ang = rnd()
        local _dx = sin(_ang)*rnd(1)+_vx*0.5
        local _dy = cos(_ang)*rnd(1)+_vy*0.5
        addpart(_b.x+brick_w/2, _b.y+brick_h/2, 
        _dx, 
        _dy, 
        1, 120,{white,light_gray, dark_gray},0)      
    end
 
    --chunks
    local chunks=2+flr(rnd(5))
    for i=1,chunks do
        local _ang = rnd()
        local _dx = sin(_ang)*rnd(1)+_vx*0.5
        local _dy = cos(_ang)*rnd(1)+_vy*0.5
        addpart(_b.x+brick_w/2, _b.y+brick_h/2, 
        _dx, 
        _dy, 
        3, 120,{flr(rnd(8)+16)},0)      
    end
 
 -- break every pixel of brick
--    for ly=0, brick_h do
--        for lx=0, brick_w do
--            local _ang = rnd()
--            local _dx = sin(_ang)*0.5
--            local _dy = cos(_ang)*0.5
--            addpart(_b.x+lx, _b.y+ly, 
--            _dx, 
--            _dy, 
--            1, 60,{white,light_gray, dark_gray})          
--        end
--    end
end

function updateparts()
    local _p
    for i=#part,1,-1 do
        _p=part[i]
        _p.age+=1
        if _p.age>=_p.maxage then
            del(part, part[i])
        elseif _p.x<-20 or _p.x>148 then
            del(part, part[i])
        elseif _p.y<-20 or _p.y>148 then
            del(part, part[i])
        else
            --change colors
            if #_p.colarray>1 then
                local _ci = _p.age/_p.maxage
                _ci=flr(_ci*#_p.colarray)+1
                _p.color=_p.colarray[_ci]
            end
        end

        --move particles
        _p.x+=_p.dx
        _p.y+=_p.dy

        --add gravity
        if _p.type==1 or _p.type==3 then
            _p.dy+=0.02
        end

        --rotate
        if _p.type==3 then
            _p.rottimer+=1
            if _p.rottimer>=10 then
                _p.rotation+=1
                _p.rottimer=0
                if _p.rotation>=4 then
                    _p.rotation=0
                end
            end
        end 
        
        --shrink
        if _p.type==2 then
            local _ci =1- (_p.age/_p.maxage)
            _p.size = _ci*_p.originalsize
        end

        --friction
        if _p.type==2 then
            _p.dx=_p.dx/1.2
            _p.dy=_p.dy/1.2
        end
    end
end

function drawparts()
    local _p
    for i=1, #part do
        _p=part[i]
        --pixel particle
        if _p.type==0 or _p.type==1 then
            pset(_p.x, _p.y, _p.color)
        elseif _p.type==2 then
            circfill(_p.x, _p.y, _p.size, _p.color)
        elseif _p.type==3 then
            local _fx, _fy
            if _p.rotation==1 then
                _fx=false
                _fy=true
            elseif _p.rotation==2 then
                _fx=true
                _fy=true
            elseif _p.rotation==3 then
                _fx=true
                _fy=false
            else
                _fx=false
                _fy=false
            end
            spr(_p.color, _p.x, _p.y, 1, 1, _fx, _fy)
        end        
    end 
end

--rebound bumped bricks
function animatebricks()
    for i=1, #brick do
        local _b=brick[i]
        if (_b.v or _b.flash>0) then
            --is brick moving or off default position
            if (_b.ox!=0 or _b.oy!=0 or _b.dx!=0 or _b.dy!=0) then
                --apply speed
                _b.ox+=_b.dx
                _b.oy+=_b.dy

                --decrease speed
                _b.dx-=_b.ox/10
                _b.dy-=_b.oy/10

                --damping
                if abs(_b.dx)>abs(_b.ox) then
                    _b.dx=_b.dx/1.4
                end
                if abs(_b.dy)>abs(_b.oy) then
                    _b.dy=_b.dy/1.4
                end

                --stabilisation
                if abs(_b.ox)<=0.05 and abs(_b.dx)<=0.05 then
                    _b.ox=0
                    _b.dx=0
                end
                if abs(_b.oy)<=0.05 and abs(_b.dy)<=0.05 then
                    _b.oy=0
                    _b.dy=0
                end
            end
        end
    end
end

--resets hiscore
function reseths()
    hs={10000,5000,2000,1000,500}
    --pat, mat, god, ass, bam
    hs1={16,13, 7,1,2}
    hs2={1,  1,15,19,1}
    hs3={20,20, 4,19,13}
    sorths()
    savehs()
end

--load hiscore
function loadhs()
    local _slot=0
    if dget(0)==1 then
        for i=1, 5 do
            _slot+=1
            hs[i]=dget(_slot)
            _slot+=1
            hs1[i]=dget(_slot)
            _slot+=1
            hs2[i]=dget(_slot)
            _slot+=1
            hs3[i]=dget(_slot)
        end 
        sorths()
        --debug=hs[1]
    else
        --file is empty
        reseths()
        --debug="data created"
    end
end

--save hiscore
function savehs()
    local _slot=0
    dset(0,1) --flag that save exists
    for i=1, #hs do
        _slot+=1
        dset(_slot,hs[i])
        _slot+=1
        dset(_slot,hs1[i])
        _slot+=1
        dset(_slot,hs2[i])
        _slot+=1
        dset(_slot,hs3[i])
    end  
end

function addhs(_score, _c1, _c2, _c3)
    add(hs,_score)
    add(hs1,_c1)
    add(hs2,_c2)
    add(hs3,_c3)
    sorths()
end

function prinths(_x)
    local _hsyoffset =25
    rectfill(_x-4,_hsyoffset-2, _x+47, _hsyoffset+6, 8)
    print ("high score", _x+2, _hsyoffset, white)
    for i=1, 5 do
        --rank and name
        local _name=hschars[hs1[i]]..hschars[hs2[i]]..hschars[hs3[i]]
        print (i..".", _x, _hsyoffset+i*7+4, light_gray)
        print (_name, _x+10, _hsyoffset+i*7+4, white)

        --score
        local _score=" "..hs[i]
        print (_score, _x-#_score*4+45, _hsyoffset+i*7+4, white)

    end
end

--sort highscore
function sorths()
    for i=1, #hs do
        local j = i
        while j > 1 and hs[j-1] < hs[j] do
            hs[j], hs[j-1] = hs[j-1], hs[j]
            hs1[j], hs1[j-1] = hs1[j-1], hs1[j]
            hs2[j], hs2[j-1] = hs2[j-1], hs2[j]
            hs3[j], hs3[j-1] = hs3[j-1], hs3[j]
            j = j-1
        end
    end
end

-->8
--test
__gfx__
0000000006777760067777600677776006777760f677776f06777760067777600000000000000000000000000000000000000000000000000000000000000000
00000000559949955577777555b33bb555ccccc55500000555eeaee5558888850000000000000000000000000000000000000000000000000000000000000000
00700700559499955577877555b3bbb555c1c1c55580008555eaaae5558a88850000000000000000000000000000000000000000000000000000000000000000
00077000559949955578887555b3bbb5551ccc155508080555eeaee555888a850000000000000000000000000000000000000000000000000000000000000000
00077000559499955577877555b33bb555c1c1c55580008555eaeae5558a88850000000000000000000000000000000000000000000000000000000000000000
00700700059999500577775005bbbb5005cccc50f500005f05eeee50058888500000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007000000000000007000000000000000770000000000000700000000007000000000000000000000000000000000000000000000000000000000000000000
00077700000700000007700000770000007770000000700000070000000777000000000000000000000000000000000000000000000000000000000000000000
00077000000777000077000000077000007000000007700000770000000770000000000000000000000000000000000000000000000000000000000000000000
00000000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000800002465019650126500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00001c7501d750207501d7501e750000002070021700000000000029700000002a7002f700000003370000000367003470000000000000000036700000000000000000000000000000000000000000000000
00100000107500f750000000f750000000c750000000b750000000675000000047500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
530200003e630386302e630236301b63416625126240f6250c6140c61500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
