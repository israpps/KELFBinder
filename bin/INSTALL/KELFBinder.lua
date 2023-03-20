--[[
  KELFBINDER MAIN SCRIPT.
  MODIFY AT YOUR OWN RISK.
  MODIFICATION OF THIS FILE IS DISCOURAGED UNLESS YOU KNOW WHAT YOU'RE DOING
  ISSUE REPORTS WICH CAN'T BE REPLICATED WITH THE ORIGINAL VERSION OF THIS FILE WILL NOT BE ACCEPTED
--]]

SCR_X = 704
SCR_Y = 480
X_MID = SCR_X / 2
Y_MID = SCR_Y / 2
System.printf("KELFBinder.lua starts")
drawbar(X_MID, Y_MID, 40, Color.new(255, 255, 255)) System.sleep(1)
FONTPATH = "common/font2.ttf"

drawbar(X_MID, Y_MID, 50, Color.new(255, 0, 0))
Secrman.init()
ROMVERN = KELFBinder.getROMversion()
KELFBinder.InitConsoleModel()
local console_model_sub = KELFBinder.getConsoleModel()
console_model_sub = string.sub(console_model_sub, 0, 8)
SUPPORTS_UPDATES = true
if ROMVERN > 220 or console_model_sub == "DTL-H300" or console_model_sub == "DTL-H100" then SUPPORTS_UPDATES = false System.printf("console is incompatible ("..ROMVERN..") ["..console_model_sub.."]") end
--- PSX
IS_PSX = 0
REAL_IS_PSX = 0
MUST_INSTALL_EXTRA_FILES = true
if System.doesFileExist("rom0:PSXVER") then
  System.printf("rom0:PSXVER FOUND")
  IS_PSX = 1
  REAL_IS_PSX = 1
else
  IS_PSX = 0
end
---PSX
local SYSUPDATE_ICON_SYS = "PS2BBL.icn"
local SYSUPDATE_ICON_SYS_RES = "INSTALL/ASSETS/"..SYSUPDATE_ICON_SYS

---
DVDPLAYERUPDATE = "INSTALL/KELF/DVDPLAYER.XLF"
SYSUPDATE_MAIN  = "INSTALL/KELF/SYSTEM.XLF"
PSX_SYSUPDATE   = "INSTALL/KELF/XSYSTEM.XLF"
KERNEL_PATCH_100 = "INSTALL/KELF/OSDSYS.KERNEL"
KERNEL_PATCH_101 = "INSTALL/KELF/OSD110.KERNEL"
TEST_KELF = "INSTALL/KELF/BENCHMARK.XLF"

temporaryVar = System.openFile(SYSUPDATE_MAIN, FREAD)
SYSUPDATE_SIZE = System.sizeFile(temporaryVar)
System.closeFile(temporaryVar)


drawbar(X_MID, Y_MID, 60, Color.new(255, 255, 255))
local circle = Graphics.loadImageEmbedded(5)
local cross = Graphics.loadImageEmbedded(6)
local triangle = Graphics.loadImageEmbedded(15)
-- local square = Graphics.loadImageEmbedded(14)
local MC2         = Graphics.loadImageEmbedded(13)
local MC1         = Graphics.loadImageEmbedded(12)
local MCU         = Graphics.loadImageEmbedded(11)
local LOGO        = Graphics.loadImageEmbedded(10)
local BG          = Graphics.loadImageEmbedded(0)
local BGERR       = Graphics.loadImageEmbedded(1)
local BGSCS       = Graphics.loadImageEmbedded(2)
local CURSOR      = Graphics.loadImageEmbedded(7)
local REDCURSOR   = Graphics.loadImageEmbedded(8)
local GREENCURSOR = Graphics.loadImageEmbedded(9)
local CHK_ = Graphics.loadImageEmbedded(3)
local CHKF = Graphics.loadImageEmbedded(4)
EXTRA_INST_COUNT  = 0
EXTRA_INST_FOLDE  = 0

drawbar(X_MID, Y_MID, 70, Color.new(255, 255, 255)) System.sleep(1)
if System.doesFileExist("INSTALL/EXTINST.lua") then dofile("INSTALL/EXTINST.lua") else
  Screen.clear(Color.new(128, 0, 128))
  Screen.flip()
  while true do end
end
Graphics.setImageFilters(LOGO, LINEAR)
Graphics.setImageFilters(BG, LINEAR)
Graphics.setImageFilters(BGERR, LINEAR)
Graphics.setImageFilters(BGSCS, LINEAR)
Graphics.setImageFilters(CURSOR, LINEAR)
Graphics.setImageFilters(REDCURSOR, LINEAR)
Graphics.setImageFilters(GREENCURSOR, LINEAR)

drawbar(X_MID, Y_MID, 80, Color.new(255, 255, 255))
local REGION = KELFBinder.getsystemregion()
--local REGIONSTR = KELFBinder.getsystemregionString(REGION)
local R = 0.1
local RINCREMENT = 0.00018

Language = KELFBinder.getsystemLanguage()
if System.doesFileExist("lang/global.lua") then dofile("lang/global.lua")
elseif Language == 1 then -- intended to stop searching lang files if language is english
elseif Language == 0 then if System.doesFileExist("lang/japanese.lua") then dofile("lang/japanese.lua") end
elseif Language == 2 then if System.doesFileExist("lang/french.lua") then dofile("lang/french.lua") end
elseif Language == 3 then if System.doesFileExist("lang/spanish.lua") then dofile("lang/spanish.lua") end
elseif Language == 4 then if System.doesFileExist("lang/german.lua") then dofile("lang/german.lua") end
elseif Language == 5 then if System.doesFileExist("lang/italian.lua") then dofile("lang/italian.lua") end
elseif Language == 6 then if System.doesFileExist("lang/dutch.lua") then dofile("lang/dutch.lua") end
elseif Language == 7 then if System.doesFileExist("lang/portuguese.lua") then dofile("lang/portuguese.lua") end
else
  System.printf("unknown language ID ("..Language..")")
end
drawbar(X_MID, Y_MID, 90, Color.new(255, 255, 255))
if System.doesFileExist(FONTPATH) then
  Font.ftInit()
  font = Font.ftLoad(FONTPATH)
  Font.ftSetCharSize(font, 940, 940)
else
  Screen.clear(Color.new(128, 128, 0)) Screen.flip() while true do end
end

function ORBMAN(Q)
  R = R+RINCREMENT
  if R > 200 and RINCREMENT > 0 then RINCREMENT = -0.00018 end
  if R < 0   and RINCREMENT < 0 then RINCREMENT =  0.00018 end
  Graphics.drawImage(CURSOR, 180+(80*math.cos(math.deg(R*2.1+1.1))), 180+(80*math.sin(math.deg(R*2.1+1.1))), Color.new(128, 128, 128, Q))
  Graphics.drawImage(CURSOR, 180+(80*math.cos(math.deg(R*2.1+1.2))), 180+(80*math.sin(math.deg(R*2.1+1.2))), Color.new(128, 128, 128, Q))
  Graphics.drawImage(CURSOR, 180+(80*math.cos(math.deg(R*2.1+1.3))), 180+(80*math.sin(math.deg(R*2.1+1.3))), Color.new(128, 128, 128, Q))
  Graphics.drawImage(CURSOR, 180+(80*math.cos(math.deg(R*2.1+1.4))), 180+(80*math.sin(math.deg(R*2.1+1.4))), Color.new(128, 128, 128, Q))
  Graphics.drawImage(CURSOR, 180+(80*math.cos(math.deg(R*2.1+1.7))), 180+(80*math.sin(math.deg(R*2.1+1.7))), Color.new(128, 128, 128, Q))
  Graphics.drawImage(CURSOR, 180+(80*math.cos(math.deg(R*2.1+1.8))), 180+(80*math.sin(math.deg(R*2.1+1.8))), Color.new(128, 128, 128, Q))
  Graphics.drawImage(CURSOR, 180+(80*math.cos(math.deg(R*2.1+1.9))), 180+(80*math.sin(math.deg(R*2.1+1.9))), Color.new(128, 128, 128, Q))
end

function ORBMANex(IMG, Q, X, Z, POW)
  R = R+RINCREMENT
  if R > 200 and RINCREMENT > 0 then RINCREMENT = -0.00018 end
  if R < 0   and RINCREMENT < 0 then RINCREMENT =  0.00018 end
  Graphics.drawImage(IMG, X+(POW*math.cos(math.deg(R*2.1+1.1))), Z+(POW*math.sin(math.deg(R*2.1+1.1))), Color.new(128, 128, 128, Q))
  Graphics.drawImage(IMG, X+(POW*math.cos(math.deg(R*2.1+1.2))), Z+(POW*math.sin(math.deg(R*2.1+1.2))), Color.new(128, 128, 128, Q))
  Graphics.drawImage(IMG, X+(POW*math.cos(math.deg(R*2.1+1.3))), Z+(POW*math.sin(math.deg(R*2.1+1.3))), Color.new(128, 128, 128, Q))
  Graphics.drawImage(IMG, X+(POW*math.cos(math.deg(R*2.1+1.4))), Z+(POW*math.sin(math.deg(R*2.1+1.4))), Color.new(128, 128, 128, Q))
  Graphics.drawImage(IMG, X+(POW*math.cos(math.deg(R*2.1+1.7))), Z+(POW*math.sin(math.deg(R*2.1+1.7))), Color.new(128, 128, 128, Q))
  Graphics.drawImage(IMG, X+(POW*math.cos(math.deg(R*2.1+1.8))), Z+(POW*math.sin(math.deg(R*2.1+1.8))), Color.new(128, 128, 128, Q))
  Graphics.drawImage(IMG, X+(POW*math.cos(math.deg(R*2.1+1.9))), Z+(POW*math.sin(math.deg(R*2.1+1.9))), Color.new(128, 128, 128, Q))
end

function WaitWithORBS(NN)
  N = NN
  while N > 1 do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    ORBMAN(0x80)
    Screen.flip()
    N = N - 1
  end
end

function FadeWIthORBS()
  local A = 0x80
  while A > 0 do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    ORBMAN(A)
    Screen.flip()
    A = A - 1
  end
end

function GetFileSizeX(PATH)
  local FD = System.openFile(PATH, FREAD)
  local SIZE = System.sizeFile(FD)
  System.closeFile(FD)
  return SIZE
end

function PreExtraAssetsInstall(FILECOUNT, FOLDERCOUNT, SIZECOUNT)
  --FILECOUNT = FILECOUNT + EXTRA_INST_COUNT -- originally it sums the count
  FOLDERCOUNT = FOLDERCOUNT + EXTRA_INST_FOLDE
  if EXTRA_INST_FOLDE > 0 and MUST_INSTALL_EXTRA_FILES then
    for i = 1, EXTRA_INST_FOLDE do
      FOLDERCOUNT = FOLDERCOUNT + 1
    end
  end
  if EXTRA_INST_COUNT > 0 and MUST_INSTALL_EXTRA_FILES then
    for i = 1, EXTRA_INST_COUNT do -- @EXTRA_INST_COUNT
      if System.doesFileExist(EXTRA_INST_SRC[i]) then -- CHECK FOR EXISTENCE, OTHERWISE, PROGRAM CRASHES!
        SIZECOUNT = SIZECOUNT + GetFileSizeX(EXTRA_INST_SRC[i])
        FILECOUNT = FILECOUNT + 1 -- only add the confirmed files
      end
    end
  end

  return FILECOUNT, FOLDERCOUNT, SIZECOUNT
end

function InstallExtraAssets(port)
  ----------------------
  if EXTRA_INST_FOLDE > 0 and MUST_INSTALL_EXTRA_FILES then
    for i = 1, EXTRA_INST_FOLDE do
      -- if System.doesDirExist(string.format("INSTALL/ASSETS/%s", EXTRA_INST_MKD[i])) then -- only create the folder if source exists...
      System.createDirectory(string.format("mc%d:/%s", port, EXTRA_INST_MKD[i]))
      -- end
    end
  end
  if EXTRA_INST_COUNT > 0 and MUST_INSTALL_EXTRA_FILES then
    for i = 1, EXTRA_INST_COUNT do
      if System.doesFileExist(EXTRA_INST_SRC[i]) then -- CHECK FOR EXISTENCE, OTHERWISE, PROGRAM CRASHES!
        System.copyFile(EXTRA_INST_SRC[i], string.format("mc%d:/%s", port, EXTRA_INST_DST[i]))
      end
    end
  end

end

function CalculateRequiredSpace(port, FILECOUNT, FOLDERCOUNT, SIZECOUNT)
  local TotalRequiredSpace = SIZECOUNT
  local AvailableSpace = 0
  local mcinfo = System.getMCInfo(port)
  TotalRequiredSpace = TotalRequiredSpace + ((FILECOUNT + FOLDERCOUNT + 3) / 2) --  A new cluster is required for every two files.
  AvailableSpace = (mcinfo.freemem * 1024)
  return AvailableSpace, TotalRequiredSpace
end

function promptkeys(SELECT, ST, CANCEL, CT, REFRESH, RT, ALFA)
  if SELECT == 1 then
    Graphics.drawScaleImage(cross, 80.0, 400.0, 32, 32, Color.new(0x80, 0x80, 0x80, 0x80 - ALFA))
    Font.ftPrint(font, 110, 407, 0, 400, 16, ST, Color.new(0x80, 0x80, 0x80, 0x80 - ALFA))
  end
  if CANCEL == 1 then
    Graphics.drawScaleImage(circle, 170.0, 400.0, 32, 32, Color.new(0x80, 0x80, 0x80, 0x80 - ALFA))
    Font.ftPrint(font, 200, 407, 0, 400, 16, CT, Color.new(0x80, 0x80, 0x80, 0x80 - ALFA))
  end
  if REFRESH == 1 then
    Graphics.drawScaleImage(triangle, 260.0, 400.0, 32, 32, Color.new(0x80, 0x80, 0x80, 0x80 - ALFA))
    Font.ftPrint(font, 290, 407, 0, 400, 16, RT, Color.new(0x80, 0x80, 0x80, 0x80 - ALFA))
  end

end

function greeting()
  local CONTINUE = true
  local Q = 2
  local W = 1
  -- Sound.playADPCM(1, SND_OPEN)
  while CONTINUE do
    Screen.clear()
    if Q > 0x80 then W = -1 System.sleep(1) end
    if Q > 1 then Q = Q + W else CONTINUE = false end
    if W > 0 then
      Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y, Color.new(Q, Q, Q, Q))
    else
      Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    end
    Graphics.drawImage(LOGO, X_MID-256, 50.0, Color.new(128, 128, 128, Q))
    if IS_NOT_PUBLIC_READY then
      Font.ftPrint(font, X_MID, 20, 8, 630, 16, "THIS IS NOT A PUBLIC-READY VERSION!", Color.new(128, 128, 128, Q))
      Font.ftPrint(font, X_MID, 40, 8, 630, 16, "Closed Release candidate - build "..BETANUM, Color.new(128, 128, 128, Q))
    end
    Font.ftPrint(font, X_MID, 310, 8, 630, 16, LNG_CRDTS0, Color.new(128, 128, 128, Q))
    Font.ftPrint(font, X_MID, 330, 8, 630, 16, LNG_CRDTS1, Color.new(128, 128, 128, Q))
    Font.ftPrint(font, X_MID, 350, 8, 630, 16, LNG_CRDTS2, Color.new(128, 128, 128, Q))
    Font.ftPrint(font, X_MID, 370, 8, 630, 16, LNG_CRDTS3, Color.new(128, 128, 128, Q))
    Font.ftPrint(font, X_MID, 390, 8, 630, 16, LNG_CRDTS4, Color.new(240, 240, 240, Q))
    Screen.flip()
  end
end

function OrbIntro(BGQ)
  local A = 0x70
  local X = 0x90
  local Q = 0x80
  while X > 0 do
    Screen.clear()
    if BGQ == 0 then
      Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    else
      Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
      if Q > 0 then Q = Q - 1 end
    end
    ORBMANex(CURSOR, 0x70 - A, 180, 180, 80 + X)
    if A > 0 then A = A - 1 end
    if X > 0 then X = X - 1 end
    Screen.flip()
  end
end

function MainMenu()
  local T = 1
  local D = 15
  local A = 0x80
  local NA = 0
  while true do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    ORBMAN(0x80)
    Font.ftPrint(font, X_MID, 20, 8, 630, 32, LNG_MM1, Color.new(220, 220, 220, 0x90 - A))
    if T == 1 then
      Font.ftPrint(font, X_MID+1, 150, 0, 630, 16, LNG_MM2, Color.new(0, 0xde, 0xff, 0x90 - A))
    else
      Font.ftPrint(font, X_MID, 150, 0, 630, 16, LNG_MM2, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 2 then
      Font.ftPrint(font, X_MID+1, 190, 0, 630, 16, LNG_MM3, Color.new(0, 0xde, 0xff, 0x90 - A))
    else
      Font.ftPrint(font, X_MID, 190, 0, 630, 16, LNG_MM3, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 3 then
      Font.ftPrint(font, X_MID+1, 230, 0, 630, 16, LNG_MM4, Color.new(0, 0xde, 0xff, 0x90 - A))
    else
      Font.ftPrint(font, X_MID, 230, 0, 630, 16, LNG_MM4, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 4 then
      Font.ftPrint(font, X_MID+1, 270, 0, 630, 16, LNG_MM6, Color.new(0, 0xde, 0xff, 0x90 - A))
    else
      Font.ftPrint(font, X_MID, 270, 0, 630, 16, LNG_MM6, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 5 then
      Font.ftPrint(font, X_MID+1, 310, 0, 630, 16, LNG_MM5, Color.new(0, 0xde, 0xff, 0x90 - A))
    else
      Font.ftPrint(font, X_MID, 310, 0, 630, 16, LNG_MM5, Color.new(200, 200, 200, 0x80 - A))
    end
    if A > 0 then A = A - 1 end
    promptkeys(1, LNG_CT0, 0, 0, 0, 0, A)

    if NA > 0 then
      if MUST_INSTALL_EXTRA_FILES then
        Font.ftPrint(font, 40, 40, 0, 630, 16,  LNG_EXTRA_INSTALL_ENABLE, Color.new(0x80, 0x80, 0, NA))
      else
        Font.ftPrint(font, 40, 40, 0, 630, 16, LNG_EXTRA_INSTALL_DISABLE, Color.new(0x80, 0x80, 0, NA))
      end
      NA = NA-1
    end

    Screen.flip()
    local pad = Pads.get()
    if Pads.check(pad, PAD_CROSS) and D == 0 then
      D = 1
      Screen.clear()
      break
    end

    if Pads.check(pad, PAD_R1) and D == 0 then
      NA = 0x80
      MUST_INSTALL_EXTRA_FILES = true
    end
    if Pads.check(pad, PAD_L1) and D == 0 then
      NA = 0x80
      MUST_INSTALL_EXTRA_FILES = false
    end

    if Pads.check(pad, PAD_UP) and D == 0 then
      T = T - 1
      D = 1
    elseif Pads.check(pad, PAD_DOWN) and D == 0 then
      T = T + 1
      D = 1
    end

    if D > 0 then D = D + 1 end
    if D > 10 then D = 0 end
    if T < 1 then T = 5 end
    if T > 5 then T = 1 end

  end
  return T
end

function Installmodepicker()
  local T = 1
  local D = 15
  local A = 0x80
  local PROMTPS = {
    LNG_IMPP0,
    LNG_IMPP1,
    LNG_IMPP2,
    LNG_IMPP3
  }
  while true do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    ORBMAN(0x80)
    if T == 1 then
      Font.ftPrint(font, X_MID+1, 150, 0, 630, 16, LNG_IMPMP1, Color.new(0, 0xde, 0xff, 0x80 - A)) else
      Font.ftPrint(font, X_MID, 150, 0, 630, 16, LNG_IMPMP1, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 2 then
      Font.ftPrint(font, X_MID+1, 190, 0, 630, 16, LNG_IMPMP2, Color.new(0, 0xde, 0xff, 0x80 - A)) else
      Font.ftPrint(font, X_MID, 190, 0, 630, 16, LNG_IMPMP2, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 3 then
      Font.ftPrint(font, X_MID+1, 230, 0, 630, 16, LNG_IMPMP3, Color.new(0, 0xde, 0xff, 0x80 - A)) else
      Font.ftPrint(font, X_MID, 230, 0, 630, 16, LNG_IMPMP3, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 4 then
      Font.ftPrint(font, X_MID+1, 270, 0, 630, 16, LNG_IMPMP4, Color.new(0, 0xde, 0xff, 0x80 - A)) else
      Font.ftPrint(font, X_MID, 270, 0, 630, 16, LNG_IMPMP4, Color.new(200, 200, 200, 0x80 - A))
    end

    Font.ftPrint(font, 80, 350, 0, 600, 32, PROMTPS[T], Color.new(128, 128, 128, 0x80 - A))
    promptkeys(1, LNG_CT0, 1, LNG_CT1, 0, 0, A)
    if A > 0 then A = A - 1 end
    Screen.flip()
    local pad = Pads.get()

    if Pads.check(pad, PAD_CROSS) and D == 0 then
      D = 1
      Screen.clear()
      break
    end

    if Pads.check(pad, PAD_CIRCLE) and D == 0 then
      T = 0
      break
    end

    if Pads.check(pad, PAD_UP) and D == 0 then
      T = T - 1
      D = 1
    elseif Pads.check(pad, PAD_DOWN) and D == 0 then
      T = T + 1
      D = 1
    end
    if D > 0 then D = D + 1 end
    if D > 10 then D = 0 end
    if T < 1 then T = 4 end
    if T > 4 then T = 1 end

  end
  return T
end

function DVDPlayerRegionPicker()
  local T = 1
  local D = 1
  local A = 0x80
  local PROMTPS = {
    "SCPH-XXX00",
    "SCPH-XXX0[1/6/7/8/10/11]",
    "SCPH-XXX0[2/3/4]",
    "SCPH-XXX09"
  }
  while true do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    ORBMAN(0x80)
    Font.ftPrint(font, X_MID, 20, 8, 630, 32, LNG_PICK_DVDPLAYER_REG, Color.new(220, 220, 220, 0x80 - A))

    if T == 1 then
      Font.ftPrint(font, X_MID+1, 150, 0, 630, 16, LNG_JPN, Color.new(0, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(font, X_MID, 150, 0, 630, 16, LNG_JPN, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 2 then
      Font.ftPrint(font, X_MID+1, 190, 0, 630, 16, LNG_USANASIA, Color.new(0, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(font, X_MID, 190, 0, 630, 16, LNG_USANASIA, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 3 then
      Font.ftPrint(font, X_MID+1, 230, 0, 630, 16, LNG_EUR, Color.new(0, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(font, X_MID, 230, 0, 630, 16, LNG_EUR, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 4 then
      Font.ftPrint(font, X_MID+1, 270, 0, 630, 16, LNG_CHN, Color.new(0, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(font, X_MID, 270, 0, 630, 16, LNG_CHN, Color.new(200, 200, 200, 0x80 - A))
    end

    Font.ftPrint(font, X_MID, 350, 8, 600, 32, PROMTPS[T], Color.new(128, 128, 128, 0x80 - A))
    promptkeys(1, LNG_CT0, 1, LNG_CT1, 0, 0, A)
    if A > 0 then A = A - 1 end
    Screen.flip()
    local pad = Pads.get()

    if Pads.check(pad, PAD_CROSS) and D == 0 then
      D = 1
      Screen.clear()
      break
    end

    if Pads.check(pad, PAD_CIRCLE) and D == 0 then
      T = -1
      break
    end

    if Pads.check(pad, PAD_UP) and D == 0 then
      T = T - 1
      D = 1
    elseif Pads.check(pad, PAD_DOWN) and D == 0 then
      T = T + 1
      D = 1
    end
    if D > 0 then D = D + 1 end
    if D > 10 then D = 0 end
    if T < 1 then T = 4 end
    if T > 4 then T = 1 end

  end
  return (T - 1)
end

function DVDPlayerINST(port, slot, target_region)
  local RET
  local TARGET_FOLD = KELFBinder.getDVDPlayerFolder(target_region)
  local TARGET_KELF = string.format("mc%d:/%s/dvdplayer.elf", port, TARGET_FOLD)

  if System.doesFileExist(DVDPLAYERUPDATE) then
    System.AllowPowerOffButton(0)
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    Font.ftPrint(font, X_MID, 20, 8, 600, 64, string.format(LNG_INSTPMPT, TARGET_KELF))
    Screen.flip()
    System.createDirectory(string.format("mc%d:/%s", port, TARGET_FOLD))
    KELFBinder.setSysUpdateFoldProps(port, slot, TARGET_FOLD)
    RET = Secrman.downloadfile(port, slot, DVDPLAYERUPDATE, TARGET_KELF)
    System.AllowPowerOffButton(1)
    if RET < 0 then secrerr(RET) return end
    secrerr(RET)
  else
    secrerr(-201)
  end
end

function NormalInstall(port, slot)

  if System.doesFileExist(string.format("mc%d:SYS-CONF/FMCBUINST.dat", port)) or
      System.doesFileExist(string.format("mc%u:SYS-CONF/uninstall.dat", port)) then WarnOfShittyFMCBInst() return end

  local RET
  local REG = KELFBinder.getsystemregion()
  local TARGET_FOLD = string.format("mc%d:/%s", port, KELFBinder.getsysupdatefolder())
  local FOLDCOUNT = 1 -- the system update folder that we'll be dealing with
  local FILECOUNT = 2 -- icons + whatever updates you push
  local NEEDED_SPACE = 1024 + 964 -- 1kb + icon.sys size to begin with
  local AvailableSpace = 0
  NEEDED_SPACE = NEEDED_SPACE + GetFileSizeX(SYSUPDATE_ICON_SYS_RES)

  if IS_PSX == 1 then
    NEEDED_SPACE = NEEDED_SPACE + GetFileSizeX(PSX_SYSUPDATE)
  else
    NEEDED_SPACE = NEEDED_SPACE + GetFileSizeX(SYSUPDATE_MAIN)
  end
  FILECOUNT, FOLDCOUNT, NEEDED_SPACE = PreExtraAssetsInstall(FILECOUNT, FOLDCOUNT, NEEDED_SPACE)
  AvailableSpace, NEEDED_SPACE = CalculateRequiredSpace(port, FILECOUNT, FOLDCOUNT, NEEDED_SPACE)
  if AvailableSpace < NEEDED_SPACE then InsufficientSpace(NEEDED_SPACE, AvailableSpace) return end

  if System.doesDirExist(TARGET_FOLD) then
    Ask2WipeSysUpdateDirs(false, false, false, false, true, port)
  end
  System.AllowPowerOffButton(0)
  System.createDirectory(TARGET_FOLD)
  if REG == 0 then -- JPN
    System.copyFile("INSTALL/ASSETS/JPN.sys", string.format("%s/icon.sys", TARGET_FOLD))
  elseif REG == 1 or REG == 2 then --USA or ASIA
    System.copyFile("INSTALL/ASSETS/USA.sys", string.format("%s/icon.sys", TARGET_FOLD))
  elseif REG == 3 then
    System.copyFile("INSTALL/ASSETS/EUR.sys", string.format("%s/icon.sys", TARGET_FOLD))
  elseif REG == 4 then
    System.copyFile("INSTALL/ASSETS/CHN.sys", string.format("%s/icon.sys", TARGET_FOLD))
  end
  System.copyFile(SYSUPDATE_ICON_SYS_RES, string.format("%s/%s", TARGET_FOLD, SYSUPDATE_ICON_SYS)) --icon is the same for all
  KELFBinder.setSysUpdateFoldProps(port, slot, KELFBinder.getsysupdatefolder())
  SYSUPDATEPATH = KELFBinder.calculateSysUpdatePath()
  if IS_PSX == 1 then SYSUPDATEPATH = "BIEXEC-SYSTEM/xosdmain.elf" end
  Screen.clear()
  Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
  Font.ftPrint(font, X_MID, 20, 8, 600, 64, LNG_INSTALLING)
  Font.ftPrint(font, X_MID, 45, 8, 600, 64, SYSUPDATEPATH)
  Font.ftPrint(font, X_MID, 100, 8, 630, 64, string.format(LNG_NOT_ENOUGH_SPACE1, NEEDED_SPACE / 1024, AvailableSpace /
    1024))
  Screen.flip()
  if (ROMVERN == 100) or (ROMVERN == 101) then -- PROTOKERNEL NEEDS TWO UPDATES TO FUNCTION
    Secrman.downloadfile(port, slot, SYSUPDATE_MAIN, string.format("mc%d:/%s", port, "BIEXEC-SYSTEM/osd130.elf")) -- SCPH-18000
    if (ROMVERN == 100) then
      RET = Secrman.downloadfile(port, slot, KERNEL_PATCH_100, string.format("mc%d:/%s", port, SYSUPDATEPATH))
      if RET < 0 then secrerr(RET) return end
    else
      RET = Secrman.downloadfile(port, slot, KERNEL_PATCH_101, string.format("mc%d:/%s", port, SYSUPDATEPATH))
      if RET < 0 then secrerr(RET) return end
    end
  elseif IS_PSX == 1 then -- PSX NEEDS SPECIAL PATH
    RET = Secrman.downloadfile(port, slot, PSX_SYSUPDATE, string.format("mc%d:/BIEXEC-SYSTEM/xosdmain.elf", port))
    if RET < 0 then secrerr(RET) return end
  else -- ANYTHING ELSE FOLLOWS WHATEVER IS WRITTEN INTO 'SYSUPDATEPATH'
    RET = Secrman.downloadfile(port, slot, SYSUPDATE_MAIN, string.format("mc%d:/%s", port, SYSUPDATEPATH))
    if RET < 0 then secrerr(RET) return end
  end
  -- KELF install finished! deal with extra files now!
  Screen.clear()
  Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
  Font.ftPrint(font, X_MID, 20, 8, 400, 64, LNG_INSTALLING)
  Font.ftPrint(font, X_MID, 45, 8, 600, 64, SYSUPDATEPATH)
  Font.ftPrint(font, X_MID, 100, 8, 630, 64, string.format(LNG_NOT_ENOUGH_SPACE1, NEEDED_SPACE / 1024, AvailableSpace / 1024))
  if MUST_INSTALL_EXTRA_FILES then Font.ftPrint(font, X_MID, 120, 8, 400, 64, LNG_INSTALLING_EXTRA) end
  Screen.flip()
  InstallExtraAssets(port)
  System.AllowPowerOffButton(1)
  secrerr(RET)
end

function MemcardPickup()
  local T = 0
  local D = 15
  local Q = 0x77
  local QP = -4
  local A = 0x50
  local mi0
  local mi1
  local mcinfo0 = System.getMCInfo(0)
  local mcinfo1 = System.getMCInfo(1)
  while true do
    local HC = ((mcinfo0.type == 2) or (mcinfo1.type == 2))
    if mcinfo0.type == 2 then mi0 = MC2
    elseif mcinfo0.type == 1 then mi0 = MC1
    else mi0 = MCU
    end

    if mcinfo1.type == 2 then mi1 = MC2
    elseif mcinfo1.type == 1 then mi1 = MC1
    else mi1 = MCU
    end

    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    ORBMAN(0x80)
    Font.ftPrint(font, X_MID, 20, 8, 630, 32, LNG_MEMCARD0, Color.new(0x80, 0x80, 0x80, 0x80 - A))
    Font.ftPrint(font, 160, 270, 8, 630, 32, string.format(LNG_MEMCARD1, 1), Color.new(0x80, 0x80, 0x80, 0x80 - A))
    if mcinfo0.type == 2 then
      if mcinfo0.format == 1 then
        Font.ftPrint(font, 160, 290, 8, 630, 32, string.format(LNG_MEMCARD2, mcinfo0.freemem), Color.new(0x80, 0x80, 0x80, 0x80 - A))
      else
        Font.ftPrint(font, 160, 290, 8, 630, 32, LNG_UNFORMATTED_CARD, Color.new(0x80, 0, 0, 0x80-A))
      end
    elseif mcinfo0.type ~= 0 then
      Font.ftPrint(font, 160, 290, 8, 630, 32, LNG_INCOMPATIBLE_CARD, Color.new(0x80, 0x80, 0x80, 0x80 - A))
    end

    if T == 0 then
      Graphics.drawScaleImage(mi0, 160 - 32, 180.0, 64, 64, Color.new(0x90, 0x90, 0x90, Q))
    else
      Graphics.drawScaleImage(mi0, 160 - 32, 180.0, 64, 64, Color.new(0x80, 0x80, 0x80, 0x80 - A))
    end

    Font.ftPrint(font, 524, 270, 8, 630, 32, string.format(LNG_MEMCARD1, 2), Color.new(0x80, 0x80, 0x80, 0x80 - A))
    if mcinfo1.type == 2 then
      if mcinfo1.format == 1 then
        Font.ftPrint(font, 524, 290, 8, 630, 32, string.format(LNG_MEMCARD2, mcinfo1.freemem), Color.new(0x80, 0x80, 0x80, 0x80 - A))
      else
        Font.ftPrint(font, 524, 290, 8, 630, 32, LNG_UNFORMATTED_CARD, Color.new(0x80, 0, 0, 0x80-A))
      end
    elseif mcinfo1.type ~= 0 then
      Font.ftPrint(font, 524, 290, 8, 630, 32, LNG_INCOMPATIBLE_CARD, Color.new(0x80, 0x80, 0x80, 0x80 - A))
    end
    if T == 1 then -- minus 32 so image center (instead of the corner) lies on 524
      Graphics.drawScaleImage(mi1, 524 - 32, 180.0, 64, 64, Color.new(0x90, 0x90, 0x90, Q))
    else
      Graphics.drawScaleImage(mi1, 524 - 32, 180.0, 64, 64, Color.new(0x80, 0x80, 0x80, 0x80 - A))
    end

    if A > 0 then A = A - 1 end
    promptkeys(1, LNG_CT0, 1, LNG_CT1, 1, LNG_CT2, A)
    Screen.flip()
    local pad = Pads.get()
    if Pads.check(pad, PAD_CROSS) and (D == 0) and (HC == true) then
      mcinfo0 = System.getMCInfo(0) -- since memcard pickup does not auto check every n time. do a check before proceeding...
      mcinfo1 = System.getMCInfo(1)
      A = 0x20
      D = 1
      if (mcinfo0.type == 2 and T == 0 and mcinfo0.format == 1) or (mcinfo1.type == 2 and T == 1 and mcinfo1.format == 1) then
        Screen.clear()
        break
      end
    end

    if Pads.check(pad, PAD_CIRCLE) and D == 0 then T = -1 break end
    if Pads.check(pad, PAD_LEFT) and D == 0 then
      T = 0
      D = 1
      Q = 0x77
    elseif Pads.check(pad, PAD_RIGHT) and D == 0 then
      T = 1
      D = 1
      Q = 0x77
    end
    if Pads.check(pad, PAD_TRIANGLE) and D == 0 then
      mcinfo0 = System.getMCInfo(0)
      mcinfo1 = System.getMCInfo(1)
      A = 0x20
    end

    if Q < 4 then QP = 4 end
    if Q > 0x77 then QP = -4 end
    Q = Q + QP
    if D > 0 then D = D + 1 end
    if D > 10 then D = 0 end


  end
  Screen.clear()
  return T
end

function expertINSTprompt()
  local T = 0
  local D = 15
  local A = 0x40
  --[[
    JAP_ROM_100, JAP_ROM_101, JAP_ROM_120, JAP_STANDARD,
    USA_ROM_110, USA_ROM_120, USA_STANDARD,
    EUR_ROM_120, EUR_STANDARD,
    CHN_STANDARD,]]
  local UPDT = {}
  UPDT["x"] = false
  local UPDTT = {}
  UPDTT[0] = LNG_SUC0
  UPDTT[1] = LNG_SUC1
  UPDTT[2] = LNG_SUC2
  UPDTT[3] = LNG_SUC3
  UPDTT[4] = LNG_SUC4
  UPDTT[5] = LNG_SUC5
  UPDTT[6] = LNG_SUC6
  UPDTT[7] = LNG_SUC7
  UPDTT[8] = LNG_SUC8
  UPDTT[9] = LNG_SUC9
  for i = 0, 10 do
    UPDT[i] = 0
  end
  local REGI = {LNG_JPN, LNG_USA, LNG_ASI, LNG_EUR, LNG_CHN}
  local SYSUP = KELFBinder.calculateSysUpdatePath()
  SYSUP = string.sub(SYSUP, 15)
  SYSUP = REGI[KELFBinder.getsystemregion()+1].." - "..SYSUP
  while true do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    ORBMAN(0x70)
    Font.ftPrint(font, X_MID, 20, 8, 630, 32, LNG_EXPERTINST_PROMPT, Color.new(0x80, 0x80, 0x80, 0x80 - A))
    if SUPPORTS_UPDATES then
      Font.ftPrint(font, X_MID, 50, 8, 630, 32, LNG_EXPERTINST_PROMPT1, Color.new(0x80, 0x80, 0, 0x80 - A))
      Font.ftPrint(font, X_MID, 65, 8, 630, 32, SYSUP, Color.new(0x70, 0x70, 0x70, 0x80 - A))
    end
    Font.ftPrint(font, 179, 120, 0, 630, 16, LNG_REGS0, Color.new(0x80, 0x80, 0, 0x80 - A))
    Font.ftPrint(font, 179, 240, 0, 630, 16, LNG_REGS1, Color.new(0x80, 0x80, 0, 0x80 - A))
    Font.ftPrint(font, 374, 120, 0, 630, 16, LNG_REGS2, Color.new(0x80, 0x80, 0, 0x80 - A))
    Font.ftPrint(font, 374, 200, 0, 630, 16, LNG_REGS3, Color.new(0x80, 0x80, 0, 0x80 - A))
    Font.ftPrint(font, 104, 340, 0, 600, 32, UPDTT[T] , Color.new(200, 200, 200, 0x80 - A))

    if UPDT[0] == 1 then Graphics.drawImage(CHKF,  160, 142) else Graphics.drawImage(CHK_, 160, 142, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[1] == 1 then Graphics.drawImage(CHKF,  160, 162) else Graphics.drawImage(CHK_, 160, 162, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[2] == 1 then Graphics.drawImage(CHKF,  160, 182) else Graphics.drawImage(CHK_, 160, 182, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[3] == 1 then Graphics.drawImage(CHKF,  160, 202) else Graphics.drawImage(CHK_, 160, 202, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[4] == 1 then Graphics.drawImage(CHKF,  160, 262) else Graphics.drawImage(CHK_, 160, 262, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[5] == 1 then Graphics.drawImage(CHKF,  160, 282) else Graphics.drawImage(CHK_, 160, 282, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[6] == 1 then Graphics.drawImage(CHKF,  160, 302) else Graphics.drawImage(CHK_, 160, 302, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[7] == 1 then Graphics.drawImage(CHKF, 332, 142)  else Graphics.drawImage(CHK_, 332, 142, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[8] == 1 then Graphics.drawImage(CHKF, 332, 162)  else Graphics.drawImage(CHK_, 332, 162, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[9] == 1 then Graphics.drawImage(CHKF, 332, 222)  else Graphics.drawImage(CHK_, 332, 222, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if T == JAP_ROM_100 then
      Font.ftPrint(font, 179, 140, 0, 400, 16, "osdsys.elf", Color.new(0x80, 0x80, 0x80, 0x80 - A))
    else
      Font.ftPrint(font, 179, 140, 0, 400, 16, "osdsys.elf", Color.new(0x80, 0x80, 0x80, 0x50 - A))
    end
    if T == JAP_ROM_101 then
      Font.ftPrint(font, 179, 160, 0, 400, 16, "osd110.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(font, 179, 160, 0, 400, 16, "osd110.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if T == JAP_ROM_120 then
      Font.ftPrint(font, 179, 180, 0, 400, 16, "osd130.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(font, 179, 180, 0, 400, 16, "osd130.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if T == JAP_STANDARD then
      Font.ftPrint(font, 179, 200, 0, 400, 16, "osdmain.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(font, 179, 200, 0, 400, 16, "osdmain.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if T == USA_ROM_110 then
      Font.ftPrint(font, 179, 260, 0, 400, 16, "osd120.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(font, 179, 260, 0, 400, 16, "osd120.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if T == USA_ROM_120 then
      Font.ftPrint(font, 179, 280, 0, 400, 16, "osd130.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(font, 179, 280, 0, 400, 16, "osd130.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if T == USA_STANDARD then
      Font.ftPrint(font, 179, 300, 0, 400, 16, "osdmain.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(font, 179, 300, 0, 400, 16, "osdmain.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if T == EUR_ROM_120 then
      Font.ftPrint(font, X_MID, 140, 0, 400, 16, "osd130.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(font, X_MID, 140, 0, 400, 16, "osd130.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if T == EUR_STANDARD then
      Font.ftPrint(font, X_MID, 160, 0, 400, 16, "osdmain.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(font, X_MID, 160, 0, 400, 16, "osdmain.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if T == CHN_STANDARD then
      Font.ftPrint(font, X_MID, 220, 0, 400, 16, "osdmain.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(font, X_MID, 220, 0, 400, 16, "osdmain.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if A > 0 then A = A - 1 end
    promptkeys(1, LNG_CT0, 1, LNG_CT1, 1, LNG_CT3, A)
    Screen.flip()
    local pad = Pads.get()
    if UPDT[0] == 1 or UPDT[1] == 1 and UPDT[2] == 0 then
      UPDT[2] = 1
    end

    if Pads.check(pad, PAD_CROSS) and D == 0 then
      D = 1
      if UPDT[T] == 1 then UPDT[T] = 0 else UPDT[T] = 1 end
      if T == 2 and UPDT[2] == 0 then
        UPDT[0] = 0
        UPDT[1] = 0
      end
    end

    if Pads.check(pad, PAD_TRIANGLE) and D == 0 then
      D = 1
      break
    end

    if Pads.check(pad, PAD_CIRCLE) and D == 0 then
      UPDT["x"] = false
      D = 1
      break
    end

    pad = Pads.get()
    if Pads.check(pad, PAD_UP) and D == 0 then
      T = T - 1
      D = 1
    elseif Pads.check(pad, PAD_DOWN) and D == 0 then
      T = T + 1
      D = 1
    end
    if D > 0 then D = D + 1 end
    if D > 15 then D = 0 end
    if T < JAP_ROM_100 then T = CHN_STANDARD end
    if T > CHN_STANDARD then T = JAP_ROM_100 end

  end

  for i = 0, 9 do
    if UPDT[i] == 1 then UPDT["x"] = true break end
  end
  Screen.clear()
  return UPDT
end

function AdvancedINSTprompt()
  local T = 1
  local D = 15
  local A = 0x80
  local PROMTPS = {
    LNG_DESC_CROSS_MODEL,
    LNG_DESC_CROSS_REGION,
    LNG_DESC_PSXDESR
  }
  while true do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    ORBMAN(0x80)
    if T == 1 then
      Font.ftPrint(font, X_MID+1, 150, 0, 630, 16, LNG_AI_CROSS_MODEL, Color.new(0, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(font, X_MID, 150, 0, 630, 16, LNG_AI_CROSS_MODEL, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 2 then
      Font.ftPrint(font, X_MID+1, 190, 0, 630, 16, LNG_AI_CROSS_REGION, Color.new(0, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(font, X_MID, 190, 0, 630, 16, LNG_AI_CROSS_REGION, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 3 then
      Font.ftPrint(font, X_MID+1, 230, 0, 630, 16, "PSX DESR", Color.new(0, 0xde, 0xff, 0x80 - A))
    elseif IS_PSX == 1 then
      Font.ftPrint(font, X_MID, 230, 0, 630, 16, "PSX DESR", Color.new(50, 50, 50, 0x80 - A))
    else -- make the PSX option grey if runner machine is PSX
      Font.ftPrint(font, X_MID, 230, 0, 630, 16, "PSX DESR", Color.new(200, 200, 200, 0x80 - A))
    end

    Font.ftPrint(font, 80, 350, 0, 600, 32, PROMTPS[T], Color.new(0x70, 0x70, 0x70, 0x80 - A))
    promptkeys(1, LNG_CT0, 1, LNG_CT1, 0, 0, A)
    if A > 0 then A = A - 1 end
    Screen.flip()
    local pad = Pads.get()

    if Pads.check(pad, PAD_CROSS) and D == 0 then
      if T == 3 and IS_PSX == 1 then
        --user requested a PSX install on a PSX, senseless, normal install will do the job
      else
        D = 1
        Screen.clear()
        break
      end
    end

    if Pads.check(pad, PAD_CIRCLE) and D == 0 then
      T = 0
      break
    end

    if Pads.check(pad, PAD_UP) and D == 0 then
      T = T - 1
      D = 1
    elseif Pads.check(pad, PAD_DOWN) and D == 0 then
      T = T + 1
      D = 1
    end
    if D > 0 then D = D + 1 end
    if D > 10 then D = 0 end
    if T < 1 then T = 3 end
    if T > 3 then T = 1 end
  end
  return T
end

function PreAdvancedINSTstep(INSTMODE)
  local UPDT = {}
  UPDT["x"] = true
  for i = 0, 10 do
    UPDT[i] = 0
  end
  if INSTMODE == 1 then
    if REGION == 0 then
      for i = 0, 3 do
        UPDT[i] = 1
      end
    elseif REGION == 1 or REGION == 2 then
      for i = 4, 6 do
        UPDT[i] = 1
      end
    elseif REGION == 3 then
      UPDT[7] = 1
      UPDT[8] = 1
    elseif REGION == 4 then
      UPDT[9] = 1
    end
  elseif INSTMODE == 2 then
    for i = 0, 9 do
      UPDT[i] = 1
    end
  elseif INSTMODE == 3 then
    UPDT[10] = 1
  else
    UPDT["x"] = false
  end
  return UPDT
end

function secrerr(RET)
  local A = 0x80
  local Q = 0x7f
  local QIN = 1
  local pad = 0
  while A > 0 do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, A))
    A = A - 1
    Screen.flip()
  end
  A = 0x80
  while true do
    Screen.clear()
    if RET == 1 then
      Graphics.drawScaleImage(BGSCS, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
      ORBMANex(GREENCURSOR, 0x80 - Q - 1, 180, 180, 80 + Q)
    else
      Graphics.drawScaleImage(BGERR, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
      ORBMANex(REDCURSOR, 0x80 - Q - 1, 180, 180, 80 + Q)
    end
    if Q < 0x20 then
      pad = Pads.get()
      if A > 0 then A = A - 1 end

      promptkeys(1, LNG_CONTINUE, 0, 0, 0, 0, A)
      if RET ~= 1 then
        Font.ftPrint(font, X_MID, 40, 8, 630, 64, string.format(LNG_INSTERR, RET), Color.new(0x80, 0x80, 0x80, 0x80 - A))
      else
        Font.ftPrint(font, X_MID, 40, 8, 630, 64, LNG_INSTPMPT1, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      end
      if RET == (-5) then
        Font.ftPrint(font, X_MID, 60, 8, 630, 64, LNG_EIO, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == (-22) then
        Font.ftPrint(font, X_MID, 60, 8, 630, 64, LNG_SECRMANERR, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == (-12) then
        Font.ftPrint(font, X_MID, 60, 8, 630, 64, LNG_ENOMEM, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == (-201) then
        Font.ftPrint(font, X_MID, 60, 8, 630, 64, LNG_SOURCE_KELF_GONE, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET ~= 1 then -- only write unknown error if retcode is not a success
        Font.ftPrint(font, X_MID, 60, 8, 630, 64, LNG_EUNKNOWN, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      end

      if Pads.check(pad, PAD_CROSS) and A == 0 then
        QIN = -1
        Q = 1
      end
    end
    if Q > 0 and Q < 0x80 then Q = Q - QIN end
    if Q > 0x7f then break end
    Screen.flip()
  end
  OrbIntro(1)
end

function MagicGateTest(port, slot)
  local A = 0x80
  local Q = 0x7f
  local QIN = 1
  local PADV = 0
  while A > 0 do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, A))
    Font.ftPrint(font, X_MID, 40, 8, 630, 64, string.format(LNG_PLS_WAIT, RET), Color.new(0x80, 0x80, 0x80, 0x80 - A))
    A = A - 1
    Screen.flip()
  end
  local RET
  local HEADER
  local MESSAGE = ""
  local LOL = 0
  if System.doesFileExist(TEST_KELF) then
    RET, HEADER = Secrman.Testdownloadfile(port, slot, TEST_KELF) else
    RET, HEADER = Secrman.Testdownloadfile(port, slot, KERNEL_PATCH_100)
  end
  for b in HEADER:gmatch('.') do
    MESSAGE = MESSAGE..string.format(('%02X '):format(b:byte()))
    LOL = LOL+1
    if LOL == 16 then MESSAGE = MESSAGE.."\n" end
  end
  A = 0x80
  while true do
    Screen.clear()
    if RET == 1 then
      Graphics.drawScaleImage(BGSCS, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
      ORBMANex(GREENCURSOR, 0x80 - Q - 1, 180, 180, 80 + Q)
    else
      Graphics.drawScaleImage(BGERR, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
      ORBMANex(REDCURSOR, 0x80 - Q - 1, 180, 180, 80 + Q)
    end
    if Q < 0x20 then
      PADV = Pads.get()
      if A > 0 then A = A - 1 end
      promptkeys(1, LNG_CONTINUE, 0, 0, 0, 0, A)
      if RET ~= 1 then
        Font.ftPrint(font, X_MID, 40, 8, 630, 64, string.format(LNG_TESTTERR, RET), Color.new(0x80, 0x80, 0x80, 0x80 - A))
      else
        Font.ftPrint(font, X_MID, 40,  8, 630, 64, LNG_TESTSUCC, Color.new(0x80, 0x80, 0x80, 0x80 - A))
        Font.ftPrint(font, 120, 280, 8, 630, 64, LNG_KELF_HEAD, Color.new(0x80, 0x80, 0x80, 0x80 - A))
        Font.ftPrint(font, 120, 300, 0, 630, 32, MESSAGE, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      end
      if RET == (-5) then
        Font.ftPrint(font, X_MID, 60, 8, 630, 64, LNG_EIO, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == (-22) then
        Font.ftPrint(font, X_MID, 60, 8, 630, 64, LNG_SECRMANERR, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == (-12) then
        Font.ftPrint(font, X_MID, 60, 8, 630, 64, LNG_ENOMEM, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == (-201) then
        Font.ftPrint(font, X_MID, 60, 8, 630, 64, LNG_SOURCE_KELF_GONE, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET ~= 1 then -- only write unknown error if retcode is not a success
        Font.ftPrint(font, X_MID, 60, 8, 630, 64, LNG_EUNKNOWN, Color.new(0x80, 0, 0, 0x80 - A))
      end

      if Pads.check(PADV, PAD_CROSS) and A == 0 then
        QIN = -2
        Q = 1
      end
    end
    if Q > 0 and Q < 0x80 then Q = Q - QIN end
    if Q > 0x7f then break end
    Screen.flip()
  end
  OrbIntro(1)
end

function WarnOfShittyFMCBInst()
  local A = 0x80
  local AIN = -1
  local Q = 0x7f
  local QIN = 1
  local pad = 0
  while A > 0 do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, A))
    A = A - 1
    Screen.flip()
  end
  A = 0x80
  while true do
    Screen.clear()
    Graphics.drawScaleImage(BGERR, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    ORBMANex(REDCURSOR, 0x80 - Q - 1, 180, 180, 80 + Q)
    Font.ftPrint(font, X_MID, 60, 8, 630, 64, LNG_WARNING, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    Font.ftPrint(font, X_MID, 80, 8, 630, 64, LNG_FMCBINST_CRAP0, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    Font.ftPrint(font, X_MID, 120, 8, 630, 64, LNG_FMCBINST_CRAP1, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    Font.ftPrint(font, X_MID, 190, 8, 630, 64, LNG_FMCBINST_CRAP2, Color.new(0x80, 0x80, A, 0x80 - Q))

    if Q < 10 then
      pad = Pads.get()
    end

    if Pads.check(pad, PAD_CROSS) then
      QIN = -1
      Q = 1
    end

    if Q ~= 0 then Q = Q - QIN end

    A = A + AIN
    if A == 0x40 then AIN = -1 end
    if A == 0 then AIN = 1 end
    if Q > 0x7f then break end
    Screen.flip()
  end
  OrbIntro(1)
end

function InsufficientSpace(NEEDED, AVAILABLE)
  local A = 0x80
  local AIN = -1
  local Q = 0x7f
  local QIN = 1
  local pad = 0
  while A > 0 do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, A))
    A = A - 1
    Screen.flip()
  end
  A = 0x80
  while true do
    Screen.clear()
    Graphics.drawScaleImage(BGERR, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    ORBMANex(REDCURSOR, 0x80 - Q - 1, 180, 180, 80 + Q)
    Font.ftPrint(font, X_MID, 60, 8, 630, 64, LNG_ERROR, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    Font.ftPrint(font, X_MID, 80, 8, 630, 64, LNG_NOT_ENOUGH_SPACE0, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    Font.ftPrint(font, X_MID, 120, 8, 630, 64, string.format(LNG_NOT_ENOUGH_SPACE1, NEEDED / 1024, AVAILABLE / 1024),
      Color.new(0x80, 0x80, 0x80, 0x80 - Q))

    if Q < 10 then
      pad = Pads.get()
    end

    if Pads.check(pad, PAD_CROSS) then
      QIN = -1
      Q = 1
    end

    if Q ~= 0 then Q = Q - QIN end

    A = A + AIN
    if A == 0x40 then AIN = -1 end
    if A == 0 then AIN = 1 end
    if Q > 0x7f then break end
    Screen.flip()
  end
  OrbIntro(1)
end

function Ask2WipeSysUpdateDirs(NEEDS_JPN, NEEDS_USA, NEEDS_EUR, NEEDS_CHN, NEEDS_CURRENT, port)
  local A = 0x80
  local Q = 0x7f
  local QIN = 1
  local pad = 0
  local SHOULD_WIPE = false
  local JPN_FOLD = string.format("mc%d:/%s", port, "BIEXEC-SYSTEM")
  local USA_FOLD = string.format("mc%d:/%s", port, "BAEXEC-SYSTEM")
  local EUR_FOLD = string.format("mc%d:/%s", port, "BEEXEC-SYSTEM")
  local CHN_FOLD = string.format("mc%d:/%s", port, "BCEXEC-SYSTEM")
  while A > 0 do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, A))
    A = A - 1
    Screen.flip()
  end
  A = 0x80
  while true do
    Screen.clear()
    Graphics.drawScaleImage(BGERR, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    ORBMANex(REDCURSOR, 0x80 - Q - 1, 180, 180, 80 + Q)

    if Q < 0x20 then
      pad = Pads.get()
      if A > 0 then A = A - 1 end

      promptkeys(1, LNG_YES, 1, LNG_NO, 0, 0, A)
      Font.ftPrint(font, 50, 40, 0, 630, 64, LNG_WARNING, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      Font.ftPrint(font, 50, 100, 0, 630, 64, LNG_WARN_CONFLICT0, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      Font.ftPrint(font, 50, 160, 0, 630, 64, LNG_WARN_CONFLICT1, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      Font.ftPrint(font, 50, 260, 0, 630, 64, LNG_WARN_CONFLICT2, Color.new(0x70, 0x70, 0x70, 0x80 - A))


      if Pads.check(pad, PAD_CROSS) then
        QIN = -1
        Q = 1
        SHOULD_WIPE = true
      end
      if Pads.check(pad, PAD_CIRCLE) then
        QIN = -1
        Q = 1
      end
    end
    if Q > 0 and Q < 0x80 then Q = Q - QIN end
    if Q > 0x7f then break end
    Screen.flip()
  end
  A = 0
  while A < 0x80 do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, A))
    A = A + 1
    Screen.flip()
  end

  if SHOULD_WIPE then
    if NEEDS_USA then System.WipeDirectory(USA_FOLD) end
    if NEEDS_CHN then System.WipeDirectory(CHN_FOLD) end
    if NEEDS_JPN then System.WipeDirectory(JPN_FOLD) end
    if NEEDS_EUR then System.WipeDirectory(EUR_FOLD) end
    if NEEDS_CURRENT then System.WipeDirectory(string.format("mc%d:/%s", port, KELFBinder.getsysupdatefolder())) end
  end
end

function WarnIncompatibleMachine()
  local A = 0x80
  local Q = 0x7f
  local QIN = 1
  local pad = 0
  while A > 0 do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, A))
    A = A - 1
    Screen.flip()
  end
  A = 0x80
  while true do
    Screen.clear()
    Graphics.drawScaleImage(BGERR, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    ORBMANex(REDCURSOR, 0x80 - Q - 1, 180, 180, 80 + Q)

    pad = Pads.get()
    if A > 0 then A = A - 1 end
    promptkeys(1, LNG_CONTINUE, 0, 0, 0, 0, Q)
    Font.ftPrint(font, X_MID, 40, 8, 630, 64, LNG_COMPAT0, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    Font.ftPrint(font, X_MID, 100, 8, 630, 64, LNG_COMPAT1, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    if Pads.check(pad, PAD_CROSS) then
      QIN = -1
      Q = 1
    end
    if Q > 0 and Q < 0x80 then Q = Q - QIN end
    if Q > 0x7f then break end
    Screen.flip()
  end
end

function performExpertINST(port, slot, UPDT)
  Screen.clear()
  Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
  Screen.flip()

  if System.doesFileExist(string.format("mc%d:SYS-CONF/FMCBUINST.dat", port)) or
      System.doesFileExist(string.format("mc%u:SYS-CONF/uninstall.dat", port)) then WarnOfShittyFMCBInst() return end
  local AvailableSpace = 0
  local FLAGS = 0
  local SIZE_NEED = 1024 -- FreeMcBoot installed automatically adds 1024 to the needed space counter
  local SIZE_NEED2 = 0
  local SYSUPDATE_MAIN_SIZE = GetFileSizeX(SYSUPDATE_MAIN)
  local ICONSIZE = GetFileSizeX(SYSUPDATE_ICON_SYS_RES)
  local NEEDS_JPN = false
  local NEEDS_USA = false
  local NEEDS_EUR = false
  local NEEDS_CHN = false
  local FOLDS_CONFLICT = false
  local FILECOUNT = 0
  local FOLDERCOUNT = 0
  local JPN_FOLD = string.format("mc%d:/%s", port, "BIEXEC-SYSTEM")
  local USA_FOLD = string.format("mc%d:/%s", port, "BAEXEC-SYSTEM")
  local EUR_FOLD = string.format("mc%d:/%s", port, "BEEXEC-SYSTEM")
  local CHN_FOLD = string.format("mc%d:/%s", port, "BCEXEC-SYSTEM")
  if UPDT[0] == 1 or UPDT[1] == 1 or UPDT[2] == 1 or UPDT[3] == 1 then NEEDS_JPN = true end
  if UPDT[4] == 1 or UPDT[5] == 1 or UPDT[6] == 1 then NEEDS_USA = true end
  if UPDT[7] == 1 or UPDT[8] == 1 then NEEDS_EUR = true end
  if UPDT[9] == 1 then NEEDS_CHN = true end

  if NEEDS_JPN and System.doesDirExist(JPN_FOLD) then
    FOLDS_CONFLICT = true
    FOLDERCOUNT = FOLDERCOUNT + 1
    FILECOUNT = FILECOUNT + 2
    SIZE_NEED = SIZE_NEED + (964 + ICONSIZE)
  end
  if NEEDS_USA and System.doesDirExist(USA_FOLD) then
    FOLDS_CONFLICT = true
    FOLDERCOUNT = FOLDERCOUNT + 1
    FILECOUNT = FILECOUNT + 2
    SIZE_NEED = SIZE_NEED + (964 + ICONSIZE)
  end
  if NEEDS_EUR and System.doesDirExist(EUR_FOLD) then
    FOLDS_CONFLICT = true
    FOLDERCOUNT = FOLDERCOUNT + 1
    FILECOUNT = FILECOUNT + 2
    SIZE_NEED = SIZE_NEED + (964 + ICONSIZE)
  end
  if NEEDS_CHN and System.doesDirExist(CHN_FOLD) then
    FOLDS_CONFLICT = true
    FOLDERCOUNT = FOLDERCOUNT + 1
    FILECOUNT = FILECOUNT + 2
    SIZE_NEED = SIZE_NEED + (964 + ICONSIZE)
  end

  for i = 0, 9 do
    if UPDT[i] == 1 then
      FLAGS = FLAGS | (1 << (i + 1))
      if i < 2 then -- if index is on the protokernel patches...
        SIZE_NEED = (SIZE_NEED + 7056)
      else
        SIZE_NEED = (SIZE_NEED + SYSUPDATE_MAIN_SIZE)
      end
      FILECOUNT = (FILECOUNT + 1)
    end
  end

  FILECOUNT, FOLDERCOUNT, SIZE_NEED = PreExtraAssetsInstall(FILECOUNT, FOLDERCOUNT, SIZE_NEED)
  AvailableSpace, SIZE_NEED2 = CalculateRequiredSpace(port, FILECOUNT, FOLDERCOUNT, SIZE_NEED)
  if AvailableSpace < SIZE_NEED2 then InsufficientSpace(SIZE_NEED2, AvailableSpace) return end
  if FOLDS_CONFLICT then Ask2WipeSysUpdateDirs(NEEDS_JPN, NEEDS_USA, NEEDS_EUR, NEEDS_CHN, false, port) end

  System.AllowPowerOffButton(0)
  Screen.clear()
  Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
  Font.ftPrint(font, X_MID, 20, 8, 400, 64, LNG_INSTALLING)
  Font.ftPrint(font, X_MID, 100, 8, 630, 64, string.format(LNG_NOT_ENOUGH_SPACE1, SIZE_NEED2 / 1024, AvailableSpace / 1024))
  Screen.flip()

  if NEEDS_JPN then System.createDirectory(JPN_FOLD) end
  if NEEDS_USA then System.createDirectory(USA_FOLD) end
  if NEEDS_EUR then System.createDirectory(EUR_FOLD) end
  if NEEDS_CHN then System.createDirectory(CHN_FOLD) end

  if UPDT[0] == 1 then
    RET = Secrman.downloadfile(port, slot, KERNEL_PATCH_100, string.format("mc%d:/BIEXEC-SYSTEM/osdsys.elf", port), 0)
    if RET < 0 then secrerr(RET) return end
  end
  if UPDT[1] == 1 then
    RET = Secrman.downloadfile(port, slot, KERNEL_PATCH_101, string.format("mc%d:/BIEXEC-SYSTEM/osd110.elf", port), 0)
    if RET < 0 then secrerr(RET) return end
  end

  SYSUPDATEPATH = KELFBinder.calculateSysUpdatePath()
  local RET = Secrman.downloadfile(port, slot, SYSUPDATE_MAIN, string.format("mc%d:/%s", port, SYSUPDATEPATH), FLAGS)
  if RET < 0 then secrerr(RET) return end

  Screen.clear()
  Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
  Font.ftPrint(font, X_MID, 20, 8, 400, 64, LNG_INSTALLING)
  Font.ftPrint(font, X_MID, 100, 8, 630, 64, string.format(LNG_NOT_ENOUGH_SPACE1, SIZE_NEED2 / 1024, AvailableSpace / 1024))
  if MUST_INSTALL_EXTRA_FILES then Font.ftPrint(font, X_MID, 120, 8, 400, 64, LNG_INSTALLING_EXTRA) end
  Screen.flip()

  if NEEDS_JPN then
    KELFBinder.setSysUpdateFoldProps(port, slot, "BIEXEC-SYSTEM")
    System.copyFile("INSTALL/ASSETS/JPN.sys", string.format("mc%d:/%s/icon.sys", port, "BIEXEC-SYSTEM"))
    System.copyFile(SYSUPDATE_ICON_SYS_RES, string.format("mc%d:/%s/%s", port, "BIEXEC-SYSTEM", SYSUPDATE_ICON_SYS))
  end
  if NEEDS_USA then
    KELFBinder.setSysUpdateFoldProps(port, slot, "BAEXEC-SYSTEM")
    System.copyFile("INSTALL/ASSETS/USA.sys", string.format("mc%d:/%s/icon.sys", port, "BAEXEC-SYSTEM"))
    System.copyFile(SYSUPDATE_ICON_SYS_RES, string.format("mc%d:/%s/%s", port, "BAEXEC-SYSTEM", SYSUPDATE_ICON_SYS))
  end
  if NEEDS_EUR then
    KELFBinder.setSysUpdateFoldProps(port, slot, "BEEXEC-SYSTEM")
    System.copyFile("INSTALL/ASSETS/EUR.sys", string.format("mc%d:/%s/icon.sys", port, "BEEXEC-SYSTEM"))
    System.copyFile(SYSUPDATE_ICON_SYS_RES, string.format("mc%d:/%s/%s", port, "BEEXEC-SYSTEM", SYSUPDATE_ICON_SYS))
  end
  if NEEDS_CHN then
    KELFBinder.setSysUpdateFoldProps(port, slot, "BCEXEC-SYSTEM")
    System.copyFile("INSTALL/ASSETS/CHN.sys", string.format("mc%d:/%s/icon.sys", port, "BCEXEC-SYSTEM"))
    System.copyFile(SYSUPDATE_ICON_SYS_RES, string.format("mc%d:/%s/%s", port, "BCEXEC-SYSTEM", SYSUPDATE_ICON_SYS))
  end

  InstallExtraAssets(port)
  System.AllowPowerOffButton(1)
  System.sleep(2)
  secrerr(RET)
end

function Ask2quit()
  Q = 1
  QQ = 1
  while true do
    if Q > 100 then QQ = -1 end
    if Q < 1 then QQ = 1 end
    Q = Q + QQ
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    Font.ftPrint(font, X_MID, 40, 8, 630, 16, LNG_WANNAQUIT)
    promptkeys(1, LNG_YES, 1, LNG_NO, 1, LNG_RWLE, 0)
    ORBMAN(0x80 - Q)
    local pad = Pads.get()
    if Pads.check(pad, PAD_CROSS) then System.exitToBrowser() end
    if Pads.check(pad, PAD_CIRCLE) then break end
    if Pads.check(pad, PAD_TRIANGLE) then if System.doesFileExist("INSTALL/CORE/BACKDOOR.ELF") then System.loadELF(System.getbootpath() .. "INSTALL/CORE/BACKDOOR.ELF") end end
    Screen.flip()
  end
end

function SystemInfo()
  local D = 15
  local A = 0x50
  local UPDTPATH
  if REAL_IS_PSX == 0 then UPDTPATH = KELFBinder.calculateSysUpdatePath() else UPDTPATH = "BIEXEC-SYSTEM/xosdmain.elf" end
  local COMPATIBLE_WITH_UPDATES = LNG_NO
  if SUPPORTS_UPDATES then COMPATIBLE_WITH_UPDATES = LNG_YES end
  while true do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    ORBMAN(0x80)
    Font.ftPrint(font, X_MID, 20, 8, 630, 32, LNG_SYSTEMINFO, Color.new(220, 220, 220, 0x80 - A))

    Font.ftPrint(font, 50, 60, 0, 630, 32, string.format("ROMVER = [%s]", ROMVER), Color.new(220, 220, 220, 0x80 - A))
    Font.ftPrint(font, 50, 80, 0, 630, 32, string.format(LNG_CONSOLE_MODEL, KELFBinder.getConsoleModel()),
      Color.new(220, 220, 220, 0x80 - A))
    Font.ftPrint(font, 50, 100, 0, 630, 32, string.format(LNG_IS_COMPATIBLE, COMPATIBLE_WITH_UPDATES),
      Color.new(220, 220, 220, 0x80 - A))
    if SUPPORTS_UPDATES then
      Font.ftPrint(font, 50, 120, 0, 630, 32, string.format(LNG_SUPATH, UPDTPATH), Color.new(220, 220, 220, 0x80 - A))
    end

    promptkeys(0, LNG_CT0, 1, LNG_CT4, 0, 0, A)
    if A > 0 then A = A - 1 end
    Screen.flip()
    local pad = Pads.get()
    if D > 0 then D = D + 1 end
    if D > 10 then D = 0 end
    if Pads.check(pad, PAD_CIRCLE) and D == 0 then break end
  end
end

function Credits()
  local pad = 0
  local Q = 1
  local QINC = 1
  while Q > 0 do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    ORBMAN(0x80)
    Graphics.drawScaleImage(LOGO, X_MID-128, 40.0, 256, 128, Color.new(128, 200, 200, Q))
    Font.ftPrint(font, X_MID, 200, 8, 630, 16, LNG_CRDTS0, Color.new(200, 200, 200, Q))
    Font.ftPrint(font, X_MID, 220, 8, 630, 16, LNG_CRDTS1, Color.new(200, 200, 200, Q))
    Font.ftPrint(font, X_MID, 240, 8, 630, 16, LNG_CRDTS2, Color.new(200, 200, 200, Q))
    Font.ftPrint(font, X_MID, 260, 8, 630, 16, LNG_CRDTS3, Color.new(200, 200, 200, Q))
    Graphics.drawRect(50, 290, 540, 1, Color.new(128, 128, 128, Q))
    Font.ftPrint(font, X_MID, 300, 8, 630, 16, LNG_CRDTS5, Color.new(200, 200, 200, Q))
    Font.ftPrint(font, X_MID, 320, 8, 630, 16, "krHACKen, uyjulian, HWNJ", Color.new(200, 200, 200, Q))
    Font.ftPrint(font, X_MID, 340, 8, 630, 16, "sp193, Leo Oliveira", Color.new(200, 200, 200, Q))
    Graphics.drawRect(50, 370, 540, 1, Color.new(128, 128, 128, Q))
    Font.ftPrint(font, X_MID, 380, 8, 630, 16, LNG_CRDTS4, Color.new(240, 240, 10, Q))
    Screen.flip()
    if (Q ~= 0x80) then Q = Q + QINC end
    pad = Pads.get()
    if Pads.check(pad, PAD_CROSS) then
      QINC = -1
      Q = (0x80 - 1)
    end
  end
end

-- SCRIPT BEHAVIOUR BEGINS --
local NEIN = 0x80
while NEIN > 0 do 
  drawbar(X_MID, Y_MID, 100, Color.new(255, 255, 255))
  NEIN = NEIN-2
end
greeting()
if SUPPORTS_UPDATES == false then WarnIncompatibleMachine() end
OrbIntro(0)
while true do
  local TT = MainMenu()
  WaitWithORBS(50)
  if (TT == 1) then -- SYSTEM UPDATE
    local TTT = Installmodepicker()
    WaitWithORBS(50)
    if TTT == 1 then -- NORMAL INST
      local port = MemcardPickup()
      if port ~= -1 then
        FadeWIthORBS()
        NormalInstall(port, 0)
        WaitWithORBS(50)
      end
    elseif TTT == 2 then -- ADVANCED INST
      local port = 0
      local LOL = AdvancedINSTprompt()
      local UPDT = {}
      UPDT = PreAdvancedINSTstep(LOL)
      if UPDT["x"] == true then
        port = MemcardPickup()
        if port ~= -1 then
          WaitWithORBS(30)
          FadeWIthORBS()
          if UPDT[10] == 1 then -- IF PSX mode was selected
            IS_PSX = 1 -- simulate runner console is a PSX to reduce code duplication
            NormalInstall(port, 0)
            IS_PSX = 0
          else
            performExpertINST(port, 0, UPDT)
          end
        end
      end
    elseif TTT == 3 then -- EXPERT INST
      local port = MemcardPickup()
      if port ~= -1 then
        WaitWithORBS(30)
        local UPDT = expertINSTprompt()
        if UPDT["x"] == true then
          FadeWIthORBS()
          performExpertINST(port, 0, UPDT)
        else WaitWithORBS(20) end
      end
    elseif TTT == 4 then -- MAGICGATE TEST
      local port = MemcardPickup()
      if port ~= -1 then
        FadeWIthORBS()
        MagicGateTest(port, 0)
        WaitWithORBS(50)
      end
    end
  elseif TT == 2 then -- DVDPLAYER
    local port = MemcardPickup()
    WaitWithORBS(20)
    if (port >= 0) then
      local target_region = DVDPlayerRegionPicker()
      if (target_region >= 0) then
        FadeWIthORBS()
        DVDPlayerINST(port, 0, target_region)
      end
    end
  elseif TT == 3 then
    SystemInfo()
  elseif TT == 4 then
    Credits()
  elseif TT == 5 then
    Ask2quit()
  end
  -- SYSTEM UPDATE
end
Screen.clear(Color.new(0xff, 0, 0, 0))
while true do end
