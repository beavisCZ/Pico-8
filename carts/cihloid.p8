pico-8 cartridge // http://www.pico-8.com
version 36
__lua__

left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

function _init()
    cls()
    ball_x=1
    ball_dx=2
    ball_y=64
    ball_dy=2
    ball_r=2
    
    pad_x=52
    pad_dx=0
    pad_y=120
    pad_w=24
    pad_h=3
    pad_c=white
end

function _update()
    local buttpress=false

    if (btn(left)) then
        buttpress=true
        pad_dx=-5
    end
    if (btn(right)) then
        buttpress=true
        pad_dx=5
    end
    if not (buttpress) then
        pad_dx=pad_dx/1.7
     end

    pad_x+=pad_dx
      
     ball_x+=ball_dx
    ball_y+=ball_dy
 
    --ball bouncing
    if ball_x<0 or ball_x>127 then
        ball_dx=-ball_dx
        sfx(0)
    end
    if ball_y<0 or ball_y>127 then
        ball_dy=-ball_dy
        sfx(0)
    end

    --check if ball hits pad
    pad_c=white;
    if (ball_box(pad_x, pad_y, pad_w, pad_h)) then
        pad_c=red;
    end
end

function _draw()
    cls(dark_blue)
    circfill(ball_x,ball_y,ball_r,10)
    rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,pad_c)
end

--check collision between ball and any zone
function ball_box(box_x, box_y, box_w, box_h)
    if (ball_y-ball_r>box_y+box_h) then
        return false       
    end
    if (ball_y+ball_r<box_y) then
        return false       
    end

    if (ball_x-ball_r>box_x+box_w) then
        return false       
    end
    if (ball_x+ball_r<box_x) then
        return false       
    end
    
    return true
end


__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000016350163501634016330163201631020300203001f3001a000170001700018400174001640016400164001b40023400264002c4002d4001f0001f0002100021000220002300036000320002c00029000
