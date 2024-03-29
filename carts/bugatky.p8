pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- bugatky
-- by beaviscz

left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

function _init()
    mode="splash" --splash, menu, game
    car1={
        x=32,
        y=50,
        spd=0,
        dir=0, --0 north, 4 east, 8 south, 12 west (0-15)
        maxspd=0.75,
        isbraking=0
    }
end

function _update60()
    if mode=="splash" then
        updatesplash()
    end
    if mode=="game" then
        updategame()
    end
end

function updatesplash()
    if btn(fire2) then
        mode="game"
        music(0)
    end
end

function updategame()
    local p1gasspressed=false

    --pridavani rychlosti
    if btn(up) then
        p1gasspressed=true
        car1.spd=car1.spd+0.01
        if car1.spd>car1.maxspd then car1.spd=car1.maxspd end
        mode="game"
    end

    --kdyz neni zmackly plyn tak pomalu snizovat rychlost
    if not p1gasspressed then
        car1.spd=car1.spd/1.01
    end

    if btn(down) then
        p1gasspressed=true
        car1.spd=car1.spd-0.02
        if car1.spd<0 then car1.spd=0 end
        car1.isbraking=1
    else
        car1.isbraking=0    
    end


    --zvuk motoru
    if car1.spd>0.03 then
      sfx(4,3,car1.spd*40)
    else
        sfx(-1,3)
    end
    --if car1.spd>0.03 and car1.spd<car1.maxspd/3 then sfx(0,3) --pokud na kanale 0 nic nehraje a auto jede prehraj efekt 0 na kanale 3
    --elseif car1.spd>=car1.maxspd/3 and car1.spd<car1.maxspd/1.5 then sfx(1,3)
    --elseif car1.spd>=car1.maxspd/1.5 then sfx(2,3) end
    
    --tocka
    if btn(right) and car1.spd>0 then 
        car1.dir=car1.dir+0.3
        if car1.dir>15 then car1.dir=0 end
    end

    if btn(left) and car1.spd>0 then 
        car1.dir=car1.dir-0.3
        if car1.dir<0 then car1.dir=15 end
    end


    --jizda - pro kazdy ze 16 spritu smeru je nutny vypocet pohybu x a y, lepsi zpusob mne nenapadl v pascalu a ani dnes
    --delky pro posun auta v uhlech
    
    -- svisle a vodorovne
    a1=1.414

    --45st sikmo
    a2=1

    --23st. sikmo
    a3=0.541
    b3=1.306

    oldx1=car1.x
    oldy1=car1.y

    if flr(car1.dir)==0 then
        car1.x+=0*car1.spd
        car1.y+=-a1*car1.spd
    elseif flr(car1.dir)==1 then
        car1.x+=a3*car1.spd
        car1.y+=-b3*car1.spd
    elseif flr(car1.dir)==2 then
        car1.x+=a2*car1.spd
        car1.y+=-a2*car1.spd
    elseif flr(car1.dir)==3 then
        car1.x+=b3*car1.spd
        car1.y+=-a3*car1.spd
    elseif flr(car1.dir)==4 then
        car1.x+=a1*car1.spd
        car1.y+=0*car1.spd
    elseif flr(car1.dir)==5 then
        car1.x+=b3*car1.spd
        car1.y+=a3*car1.spd
    elseif flr(car1.dir)==6 then
        car1.x+=a2*car1.spd
        car1.y+=a2*car1.spd
    elseif flr(car1.dir)==7 then
        car1.x+=a3*car1.spd
        car1.y+=b3*car1.spd
    elseif flr(car1.dir)==8 then
        car1.x+=0*car1.spd
        car1.y+=a1*car1.spd
    elseif flr(car1.dir)==9 then
        car1.x+=-a3*car1.spd
        car1.y+=b3*car1.spd
    elseif flr(car1.dir)==10 then
        car1.x+=-a2*car1.spd
        car1.y+=a2*car1.spd
    elseif flr(car1.dir)==11 then
        car1.x+=-b3*car1.spd
        car1.y+=a3*car1.spd
    elseif flr(car1.dir)==12 then
        car1.x+=-a1*car1.spd
        car1.y+=0*car1.spd
    elseif flr(car1.dir)==13 then
        car1.x+=-b3*car1.spd
        car1.y+=-a3*car1.spd
    elseif flr(car1.dir)==14 then
        car1.x+=-a2*car1.spd
        car1.y+=-a2*car1.spd
    elseif flr(car1.dir)==15 then
        car1.x+=-a3*car1.spd
        car1.y+=-b3*car1.spd
    end

    --kolize
    spratek=mget(flr((car1.x+4)/8),flr((car1.y+4)/8)) --cislo sprajtu kde jsem s autem
    if fget(spratek,0) then --na sprajtu je zaskrtly prvni flag - oznaceni kolizniho spratka
        --vratit na pozici pred kolizi
        car1.x=oldx1
        car1.y=oldy1
        car1.spd=0
        sfx(0,2)  
    end

end


function _draw()
    if mode=="splash" then
        drawsplash()
    elseif mode=="game" then
        drawgame()
    end
end

function drawsplash()
    cls(light_gray)
    cprint("bugatky", 64, 40, black)
    cprint("remake of my first", 64, 58, dark_gray)
    cprint("game from 1996", 64, 64, dark_gray)
    cprint("code by beaviscz", 64, 80, dark_gray)
    cprint("gfx by ovanula hyzda", 64, 86, dark_gray)
    cprint("press ❎ to continue...", 64, 100, dark_gray)
end

function drawgame()
    cls(dark_gray)
    map(0,0,0,0,16,16)
    
    --efekt brzdeni, nahradi cervenou ve spritu na oranzovou
    if car1.isbraking==1 then
        pal(red,orange)
    end
    spr(64+flr(car1.dir),car1.x,car1.y)
    pal()
    --print(flr(car1.x),0,0,red)
    --print(flr(car1.y),10,0,red)
    --print(flr(car1.x/8),0,6,red)
    --print(flr(car1.y/8),10,6,red)
    --spratek=mget(flr((car1.x+4)/8),flr((car1.y+4)/8)) --cislo sprajtu kde jsem s autem
    --flag=fget(spratek,0)
    --print(flag,0,12,red)
end



function cprint (txt, x, y, col)
    print(txt,x-#txt*2,y,col)
end
__gfx__
0000000000000000bb7555555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000
0000000000000000bb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000
0000000000000000bb7555556555557bbbbbbbbb87878787878787878787878787878787bbbbbbbbbbbbbbbbbbb3bbbb00000000000000000000000000000000
0000000000000000bb8555555555558bbbbbbb875555555555555555555555555555555587bbbbbbbb3bbbbbbb3bbbbb00000000000000000000000000000000
0000000000000000bb7555556555557bbbbbb75555555555555555555555555555555555558bbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000
0000000000000000bb8555556555558bbbbb8555555555555555555555555555555555555557bbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000
0000000000000000bb7555555555557bbbb755555555555555555555555555555555555555558bbbbbbbb3bbbbbbbb3b00000000000000000000000000000000
0000000000000000bb8555556555558bbbb855555555555555555555555555555555555555557bbbbbbb3bbbbbbbb3bb00000000000000000000000000000000
0000000000000000bb7555556555557bbb75555555566666566566566566566566666555555558bbbbbbbbbbbbbbbbbb00000000000000000000000000000000
0000000000000000bb8555555555558bbb85555555655555555555555555555555555655555557bbbbbbbbbbbbbbbbbb00000000000000000000000000000000
0000000000000000bb7555556555557bbb75555556555555555555555555555555555565555558bbbbbbbbbbbbbbbbbb00000000000000000000000000000000
0000000000000000bb8555556555558bbb85555565555555555555555555555555555556555557bbbbbbbbbbb3bbbbbb00000000000000000000000000000000
0000000000000000bb7555555555557bbb75555565555555555555555555555555555556555558bbbbbbbbbbb3bbbbbb00000000000000000000000000000000
0000000000000000bb8555556555558bbb85555565555555555555555555555555555556555557bbbbbbbbbb3bbbbb3b00000000000000000000000000000000
0000000000000000bb7555556555557bbb75555565555557878787878787878785555556555558bbbbb3bbbbbbbbb3bb00000000000000000000000000000000
0000000000000000bb8555555555558bbb8555556555558bbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbb00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbb7555556555557bb8555556555558bb000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb85555565555558778555555555558775555556555557bb000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbb75555565555555555555556555555555555556555558bb000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbb3bbbbbbb3bbbbbbb85555565555555555555556555556555555556555557bb000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb75555565555555555555555555556555555556555558bb000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb85555556555555555555556555556555555565555557bb000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbb3bbbbbbbb3bbb75555555655555555555556555556555555655555558bb000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbb3bbbbbbbb3bbbb85555555566666665555555555556666666555555557bb000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb755555555555556555555655555555555555555558bbb000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb855555555555556555555655555555555555555557bbb000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbb665bbbbbbb7555555555555655555555555555555555555558bbbb000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbb65550bbbbbbb85555555555565555556555555555555555557bbbbb000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbb6555550bbbbbbb785555555555555555655555555555555578bbbbbb000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbb650000bbbbbbbbbb78787878778555555555558778787878bbbbbbbb000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbb3bbbbbbbbb3bbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000
000cc0000000cc000000000000000400000000000000000000804000000000000000000000000000000408000000000000000000004000000004080000cc0000
00acca00000acca00040ac000040cca0004004000040000000cc0000008cc800008cc800008cc8000000cc0000000400004004000acc04000000cc000acca000
04cccc40004cccc4000cccc008cc1ccc08cccca008cc04008cccc04004cccc4004cccc4004cccc40040cccc80040cc800acccc80ccc1cc80040cccc84cccc400
00c11c00000c11c040c1cca00ccc1ccc0ccc1ccc0ccccca00ccc1c0000cccc0000cccc0000cccc0000c1ccc00accccc0ccc1ccc0ccc1ccc000c1ccc00c11c000
00cccc0000cccc000ccc1c000ccccca00ccc1ccc0ccc1ccc40c1cca0000c11c000c11c000c11c0000acc1c04ccc1ccc0ccc1ccc00accccc00acc1c0400cccc00
04cccc4004cccc408cccc04008cc040008cccca008cc1ccc000cccc0004cccc404cccc404cccc4000cccc000ccc1cc800acccc800040cc800cccc00004cccc40
008cc800008cc80000cc000000400000004004000040cca00040ac00000acca000acca000acca00000ca04000acc0400004004000000040000ca0400008cc800
000000000000000000804000000000000000000000000400000000000000cc00000cc00000cc0000000000000040000000000000000000000000000000000000
__label__
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb8787878787878787bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbb
bbbbbbbbbbbbbb87555555555555555587bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbb3bbbbbbbbbbbbb
bbbbbbbbbbbbb7555555555555555555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbb855555555555555555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbb75555555555555555555555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbb3bbbbbbbbb
bbbbbbbbbbb85555555555555555555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbb3bbbbbbbbbb
bbbbbbbbbb7555555556666666666555555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbb8555555565555555555655555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbb7555555655555555555565555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbb8555556555555555555556555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbb
bbbbbbbbbb7555556555555555555556555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbb
bbbbbbbbbb8555556555555555555556555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbb3bbbbbbbbb
bbbbbbbbbb7555556555555785555556555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbb3bbbbbbbbbb
bbbbbbbbbb8555556555558bb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbb7555556555557bbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbb855555655555587785555555555587bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbb75555565555555555555556555555587878787878787878787878787878787878787878787878787878787bbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbb
bbbbbbbbbb8555556555555555555555655555655555555555555555555555555555555555555555555555555555555587bbbbbbbbbbbbbbbb3bbbbbbb3bbbbb
bbbbbbbbbb75555565555555555555555555556555555555555555555555555555555555555555555555555555555555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbb855555565555555555555565555565555555555555555555555555555555555555555555555555555555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbb7555555565555555555555655555655555555555555555555555555555555555555555555555555555555555558bbbbbbbbbbbbbbbb3bbbbbbbb3b
bbbbbbbbbb8555555556666666555555555555665555555555555555555555555555555555555555555555555555555555557bbbbbbbbbbbbbbb3bbbbbbbb3bb
bbbbbbbbbbb7555555555555565555556555555556656656656656655665665665665665566566566566566566666555555558bbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbb8555555555555565555556555555555555555555555555555555555555555555555555555555555555655555557bbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbb755555555555565555555555555555555555555555555555555555555555555555555555555555555565555558bbbbbbbbbbbbb3bbbbbbb3bbbb
bbbbbbbbbbbbb85555555555565555556555555555555555555555555555555555555555555555555555555555555556555557bbbb3bbbbbbb3bbbbbbb3bbbbb
bbbbbbbbbbbbbb7855555555555555556555555555555555555555555555555555555555555555555555555555555556555558bbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb78787878778555555555558755555555555555555555555555555555555555555555555555555556555557bbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557b87878787878787878787878787878787878787878787878785555556555558bbbbbbb3bbbbbbbb3bbbbbbb3b
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbb3bbbbbbbb3bbbbbbb3bb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7555555555557bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555555555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbb3bbbbbbbbbbbbbb7555556555557bbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbb
bb3bbbbbbb3bbbbbbbbbbbbbbb8555556555558bbb3bbbbbbb3bbbbbbbbbbbbbbbbbbbbbbb3bbbbbbb3bbbbbbb8555555555558bbbbbbbbbb3bbbbbbb3bbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbb3bbbbbbb3bbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbb3bbbbb3b3bbbbb3b
bbbbb3bbbbbbbb3bbbbbbbbbbb7555556555557bbbbbb3bbbbbbbb3bbbbbbbbbbbbbbbbbbbbbb3bbbbbbbb3bbb7555555555557bbbb3bbbbbbbbb3bbbbbbb3bb
bbbb3bbbbbbbb3bbbbbbbbbbbb8555555555558bbbbb3bbbbbbbb3bbbbbbbbbbbbbbbbbbbbbb3bbbbbbbb3bbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8555555555558bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbb3bbbbbbb3bbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbb3bbbbbbbbbbbbbbbb8555555555558bbbbbbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbb3bbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbb3bbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbb7555555555557bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb3bbbbb3bbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbb3bbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbb
bbb3bbbbbbbbb3bbbbbbbbbbbb7555555555557bbbb3bbbbbbbbb3bbbbbbbb3bbbbbbb3bbbb3bbbbbbbbb3bbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbb3bbbbbbbb3bbbbbbb3bbbbbbbbbbbbbbbbbbbb8555555555558bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7555555555557bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbb665bbbbbbbbbbbbbb3bbbbbbb3bbbbbb7555556555557bbbbbbbbbbbb3bbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555555555558bbb3bbbbbbbbbbbbbb65555bbbb3bbbbbbb3bbbbbbb3bbbbbbb8555555555558bbb3bbbbbbb3bbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbb6555555bbbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbb655555bbbbbbbbbbbbbbbbbbbbbbbbbbbb855558cc85558bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555555555557bbbbbb3bbbbb3bbbbbbbbb3bbbbbbb3bbbbbbbb3bbbbbbb3bbb75554cccc4557bbbbbb3bbbbbbbb3bbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbb3bbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbb3bbbbbbb3bbbb85555cccc5558bbbbb3bbbbbbbb3bbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb755555c11c557bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555555555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb855554cccc458bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb755555acca557bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbb3bbbbbbb3bbbbbbbbbbbbbb3bbbbbbb3bbbbbbbb8555556cc5558bbbbbbbbbb3bbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbb3bbbbbbbb7555555555557bbbbbbbbbb3bbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbb3b3bbbbb3bbb8555556555558bbbbbbbbb3bbbbb3bbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbb3bbbbbbbbb3bbbbbbbb3bbbb3bbbbbbbbb3bbbbbbb3bbbb7555556555557bbbb3bbbbbbbbb3bbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555555555558bbbbbbbbbbbbb3bbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbb8555555555558bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7555555555557bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbb3bbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555555555558bbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbb8555555555558bbb3bbbbbbb3bbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbb3bbbbb3bbbbbbbbb3bbbbb3bbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555555555557bbbbbbbbbbbb3bbbbbbbbb3bbbbb3bbbbbbbbb3bbbbbbbbbbbb7555555555557bbbbbb3bbbbbbbb3bbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbb3bbbbbbbb3bbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555555555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8555555555558bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbb3bbbbbbbbbbbbbb7555556555557bbbbbbbbbbb665bbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbbb8555556555558bbbbbbbbbb65555bbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7555555555557bbbbbbbbb6555555bbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbb655555bbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbb3bbbbbbb3bbbbbbbb3bbbbbb3bbbbbbbb3bbbbbbbbbbb7555556555557bbbb3bbbbbbbbb3bbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555555555558bbbbb3bbbbbbb3bbbbbbbb3bbbbbb3bbbbbbbb3bbbbbbbbbbbb8555555555558bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7555555555557bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb665bbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbb3bbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555555555558bbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbb65555bbbbbbbbbbbb8555555555558bbbbbbbbbbb3bbbbbbb3bbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbb6555555bbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbb3bbbbb3bbbbbbbbb655555bbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555555555557bbbb3bbbbbbb3bbbbbbbbb3bbbbb3bbbbbbbbb3bbbbbbbbbbbb7555555555557bbbbbbbbbbbbbb3bbbbbbbb3b
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbb3bbbbbbbb3bb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555555555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8555555555558bbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbb3bbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbb3bbbbbbbbbbbb
bb3bbbbbbb3bbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbb8555556555558bbb3bbbbbbb3bbbbbb3bbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbb7555555555557bbbbbbbbbbbbbbbbbb3bbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbb3bbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbb3bbbbb3b
bbbbb3bbbbbbbb3bbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbb3bbbbbbbbbbbb7555556555557bbbbbb3bbbbbbbb3bbbbbb3bb
bbbb3bbbbbbbb3bbbbbbbbbbbb8555555555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8555555555558bbbbb3bbbbbbbb3bbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb7555556555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8555556555558bbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbb85555565555558bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb75555556555557bbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbb3bbbbbb7555556555555587878787878787878787878787878787878787878787878755555556555558bbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbb3bbbbbbbb3bbbbbbb8555556555555555555555555555555555555555555555555555555555555555555556555557bbbbbbbbbbb3bbbbbbbbbbbbbb
bbbbbbbbb3bbbbbbbbbbbbbbbb7555556555555555555555555555555555555555555555555555555555555555555556555558bbbbbbbbbbb3bbbbbbbbbbbbbb
bbbbbbbb3bbbbb3bbbbbbbbbbb8555555655555555555555555555555555555555555555555555555555555555555565555557bbbbbbbbbb3bbbbb3bbbbbbbbb
bbb3bbbbbbbbb3bbbbbbbb3bbb7555555565555555555555555555555555555555555555555555555555555555555655555558bbbbb3bbbbbbbbb3bbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbb3bbbb8555555556666655555555555555555555555555555555555555555555555566666555555557bbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbb75555555555555665665665665665566566565665665665665665566566565555555555558bbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbb85555555555555555555555555555555555555555555555555555555555555555555555557bbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbb755555555555555555555555555555555555555555555555555555555555555555555558bbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbb3bbbbbbbbbbb8555555555555555555555555555555555555555555555555555555555555555555557bbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbb3bbbbbbbbbbbb78555555555555555555555555555555555555555555555555555555555555555578bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb3bbbbb3bbbbbbbbb7878787855555555555555555555555555555555555555555555555578787878bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbb3bbbbbbbbb3bbbbbbbbbbbbbbbbbb878787878787878787878787878787878787878787878787bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
20040508092020200a0b2020200a0b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20141518192020201a1b2020201a1b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20242526270607060706070809200a0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
203435363716171617161718190a0b0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0b2012130a0b20200a0b02031a1b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b2002031a22230b1a1b121320202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20202002030a32330a0b0b02030a0b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20202012131a0a0b1a1b1b12131a1b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020200203201a1b1a1b20020322232000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20202012130a0a0b222320121332332000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20202002031a1a1b3233200203200a0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0b2012132020201a1b2012130a0b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b0b242506070606070628291a1b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
201a1b3435161716161716383920202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00060000076500965009650096500964008630086200f6001160012600106000d6000c6000c6000c6000d60000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003520036600366003660036600366003660036600366000c6000d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001b6501b6500d6000d6000a600116000f6000f6001160012600106000d6000c6000c6000c6000d60000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001a510000001f510000001a5100000023510000001a510000001f510000001a51000000245100000023510000001f510000001a510000001f510000001f510000001a5100000019510000001a51000000
0009000000120001200012002120021200212003120031200312003120041200512005120051200612006120061200612006120061200712007120081200912009120091200a1200b1200b1200b1200b1200c120
__music__
02 03014344

