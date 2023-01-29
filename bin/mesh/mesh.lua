Screen.setMode(NTSC, 640, 448, CT24, INTERLACED, FIELD, true, Z16S)
Font.fmLoad()
Render.init(4/3)

local orangetex = Graphics.loadImage("mesh/CUBE4.png")
Graphics.setImageFilters(orangetex, LINEAR) 
local orange = Render.loadOBJ("mesh/QBO.obj", orangetex)

Camera.position(0.0, 0.0, 50.0)
Camera.rotation(0.0, 0.0,  0.0)

Lights.create(4)

--Lights.set(1,  0.0,  0.0,  0.0, 1.0, 1.0, 1.0,     AMBIENT)
--Lights.set(2,  1.0,  0.0, -1.0, 0, 0, 0, DIRECTIONAL)
--Lights.set(3,  0.0,  1.0, -1.0, 0.9, 0.5, 0.5, DIRECTIONAL)
--Lights.set(4, -1.0, -1.0, -1.0, 0.5, 0.5, 0.5, DIRECTIONAL)

local lx = nil
local ly = nil
local rx = nil
local yy = nil
local pad = nil
local oldpad = nil
local modeltodisplay = 0

local savedlx = 0.0
local savedly = 180.0

local savedrx = 9.0
local savedry = -4.0

local modelz = 0.0
local lxmod = -0.02
local lymod = 0.02
local Q = 50
local RR = 0.1
while true do
--Lights.set(1,  0.0,  0.0,  0.0, 1, 1, 1, AMBIENT)
--Lights.set(2,  1,  1,  1, 1, 1, 1, DIRECTIONAL)
--Lights.set(3,  1.0,  0.0, -1.0, 1, 1, 1, DIRECTIONAL)
--Lights.set(2,  1.0,  0.0, -1.0, R, G, B, DIRECTIONAL)

Lights.set(1,  0.0,  0.0,  0.0, 0.5*RR, 0.5*RR, 0.5*RR,     AMBIENT)
Lights.set(2,  1.0,  0.0, -1.0, 0.0*RR, 0.0*RR, 0.0*RR, DIRECTIONAL)
Lights.set(3,  0.0,  1.0, -1.0, 0.9*RR, 0.5*RR, 0.5*RR, DIRECTIONAL)
Lights.set(4, -1.0, -1.0, -1.0, 0.5*RR, 0.5*RR, 0.5*RR, DIRECTIONAL)
	if RR < 1 then RR = RR+0.001 end
    oldpad = pad
    pad = Pads.get()

    lx, ly = Pads.getLeftStick()
    lx = lx / 1024.0
    ly = ly / 1024.0
    savedlx = savedlx - lx
    savedlx = savedlx + lxmod
	if savedlx > 50 then
		lxmod = -0.02
	elseif savedlx < -50 then
		lxmod = 0.02
	end
	if savedly > 50 then
		lymod = -0.02
	elseif savedly < -50 then
		lymod = 0.02
	end
    savedly = savedly - ly

    rx, ry = Pads.getRightStick()
    rx = rx / 1024.0
    ry = ry / 1024.0
    savedrx = savedrx + rx
    savedry = savedry + ry

    Screen.clear(Color.new(0, 0, 0, 128))

    if Pads.check(pad, PAD_CROSS) then
       R = R+1
	   if R > 254 then R = 0 end
    end
    if Pads.check(pad, PAD_CIRCLE) then
       R = R+1
	   if G > 254 then G = 0 end
    end
    if Pads.check(pad, PAD_TRIANGLE) then
       R = R+1
	   if B > 254 then B = 0 end
    end
	
	
    if Pads.check(pad, PAD_R2) then
       modelz = modelz + 0.5
    end

    if Pads.check(pad, PAD_L2) then
        modelz = modelz - 0.5
     end
	Font.fmPrint(10, 10, 0.5, 
	string.format("savedrx=%f, savedry=%f, savedly=%f\nsavedlx=%f modelz=%f",savedrx, savedry, savedly, savedlx, modelz))
    Render.drawOBJ(orange,  savedrx, savedry, modelz, savedly, savedlx, 0.0)
    Render.drawOBJ(orange,  savedrx-5, savedry+1, modelz, savedly, -savedlx, 0.0)
    --Render.drawBbox(orange,  savedrx, savedry, modelz, savedly, savedlx, 0.0, Color.new(0, 255, 0, 128))

    Screen.flip()
end