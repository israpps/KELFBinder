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
LightsSeed = math.random()/2345 + 3456;
System.log("KELFBinder.lua starts\n")
FONTPATH = "common/font2.ttf"

--- __0:__ connected&formatted, __1:__ unformatted, __2:__ unusable, __3:__ not connected, __>3__ other errors
HDD_STATUS = 3

Drawbar(X_MID, Y_MID, 40, Color.new(255, 0, 0))
RPC_STATUS = Secrman.rpc_init()
Drawbar(X_MID, Y_MID, 40, Color.new(255, 255, 255))

ROMVERN = KELFBinder.getROMversion()
KELFBinder.InitConsoleModel()
local console_model_sub = KELFBinder.getConsoleModel()
console_model_sub = string.sub(console_model_sub, 0, 8)
SUPPORTS_UPDATES = true
MUST_INSTALL_EXTRA_FILES = true
if ROMVERN > 220 or console_model_sub == "DTL-H300" or console_model_sub == "DTL-H100" then SUPPORTS_UPDATES = false System.log("console is incompatible ("..ROMVERN..") ["..console_model_sub.."]\n") end
---@PSX
IS_PSX = false
REAL_IS_PSX = false
if doesFileExist("rom0:PSXVER") then
  System.log("rom0:PSXVER FOUND\n")
  IS_PSX = true
  REAL_IS_PSX = true
end

if doesFileExist("rom0:DAEMON") then
  Screen.clear(Color.new(0xff, 0, 0))
  Screen.flip()
  error("\tARCADE DETECTED.\n\tABORTING PROGRAM EXECUTION")
end
---PSX

---
SYSUPDATE_MAIN  = "INSTALL/KELF/SYSTEM.XLF"
SYSUPDATE_PSX   = "INSTALL/KELF/XSYSTEM.XLF"
KERNEL_PATCH_100 = "INSTALL/KELF/OSDSYS.KERNEL"
KERNEL_PATCH_101 = "INSTALL/KELF/OSD110.KERNEL"

DVDPLAYERUPDATE = "INSTALL/KELF/DVDPLAYER.XLF"
TEST_KELF = "INSTALL/KELF/BENCHMARK.XLF"

SYSUPDATE_HDD_MAIN  = "INSTALL/KELF/HSYSTEM.XLF"
SYSUPDATE_HDD_BOOTSTRAP = "INSTALL/KELF/MBR.XLF"

Drawbar(X_MID, Y_MID, 50, Color.new(255, 255, 255))
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

--if doesFileExist("INSTALL/EXTINST.lua") then dofile("INSTALL/EXTINST.lua") else
--  System.log("### Could not access INSTALL/EXTINST.lua\n")
--end

---parse directory and append paths based on files found inside `SOURCEDIR` into `SOURCE_TABLE` and `DEST_TABLE`.
---if at least 1 file is found, the value of `DESTNTDIR` is added into `MKDIR_TABLE`
---@param SOURCEDIR string relative path to parse for registering installation files
---@param DESTNTDIR string destination path on target device
---@param T table installation table
function Update_InstTable(SOURCEDIR, DESTNTDIR, T)
  if type(T.source) ~= "table" or type(T.target) ~= "table" or type(T.dirs) ~= "table" then
    error("Invalid installation table passed to table updater")
  end
  local tmp = System.listDirectory(SOURCEDIR)
  local COUNT = 0 -- Ammount of files that will be installed
  local add_dir = true
  if tmp == nil then return 0 end
  for x = 1, #tmp do
    if not tmp[x].directory then
        table.insert(T.source, SOURCEDIR.."/"..tmp[x].name)
        table.insert(T.target, DESTNTDIR.."/"..tmp[x].name)
        COUNT = COUNT+1
    end
  end
  if COUNT > 0 then --at least one file will be installed... append to mkdir struct
    for x = 1, #T.dirs do
      if T.dirs[x] == DESTNTDIR then
        add_dir = false
      end
    end
    if add_dir then
      table.insert(T.dirs, DESTNTDIR)
    end
    System.log(string.format("Installation table: %d files listed to be moved from '%s' to target:/%s'\n", COUNT, SOURCEDIR, DESTNTDIR))
  end
  return COUNT
end

Drawbar(X_MID, Y_MID, 60, Color.new(0, 255, 0))
System.log("declaring installation tables for PS2BBL\n")
dofile("INSTALL/EXTINST.lua")
Drawbar(X_MID, Y_MID, 70, Color.new(255, 255, 255))

Graphics.setImageFilters(LOGO, LINEAR)
Graphics.setImageFilters(BG, LINEAR)
Graphics.setImageFilters(BGERR, LINEAR)
Graphics.setImageFilters(BGSCS, LINEAR)
Graphics.setImageFilters(CURSOR, LINEAR)
Graphics.setImageFilters(REDCURSOR, LINEAR)
Graphics.setImageFilters(GREENCURSOR, LINEAR)

Drawbar(X_MID, Y_MID, 80, Color.new(255, 255, 255))
local REGION = KELFBinder.getsystemregion()
--local REGIONSTR = KELFBinder.getsystemregionString(REGION)
local R = math.random(1,180)
local RINCREMENT = 2

Language = KELFBinder.getsystemLanguage()
if doesFileExist("lang/global.lua") then dofile("lang/global.lua")
elseif Language == 1 then -- intended to stop searching lang files if language is english
elseif Language == 0 then if doesFileExist("lang/japanese.lua") then dofile("lang/japanese.lua") end
elseif Language == 2 then if doesFileExist("lang/french.lua") then dofile("lang/french.lua") end
elseif Language == 3 then if doesFileExist("lang/spanish.lua") then dofile("lang/spanish.lua") end
elseif Language == 4 then if doesFileExist("lang/german.lua") then dofile("lang/german.lua") end
elseif Language == 5 then if doesFileExist("lang/italian.lua") then dofile("lang/italian.lua") end
elseif Language == 6 then if doesFileExist("lang/dutch.lua") then dofile("lang/dutch.lua") end
elseif Language == 7 then if doesFileExist("lang/portuguese.lua") then dofile("lang/portuguese.lua") end
else
  System.log("### unknown language ID ("..Language..")")
end

Drawbar(X_MID, Y_MID, 90, Color.new(255, 255, 255))
if doesFileExist(FONTPATH) then
  Font.ftInit()
  LSANS = Font.ftLoad(FONTPATH)
  LSANS_SMALL = Font.ftLoad(FONTPATH)
  Font.ftSetCharSize(LSANS, 940, 940)
  Font.ftSetCharSize(LSANS_SMALL, 840, 840)
else
  Screen.clear(Color.new(128, 128, 0)) Screen.flip() while true do end
end

function Eval_HDDStatus()
  HDD_STATUS = HDD.GetStatus()
  if HDD_STATUS == 0 then STR_HDD_USABLE = LNG_HDD_CON_AND_FORM
  elseif HDD_STATUS == 1 then STR_HDD_USABLE = LNG_HDD_UNF
  elseif HDD_STATUS == 2 then STR_HDD_USABLE = LNG_HDD_UNUSABLE
  elseif HDD_STATUS == 3 then STR_HDD_USABLE = LNG_HDD_DISCON
  else
    STR_HDD_USABLE = string.format(LNG_HDD_OTHER, HDD_STATUS)
  end
end
Eval_HDDStatus() --we must call it at startup no matter what

function ORBMAN(Q)
  ORBMANex(CURSOR, Q, 180, 180, 80)
end

function ORBMANex(IMG, Q, X, Z, POW)
  time = os.clock()*3
  for l = 1, 7 do
    local angle = time * l * math.pi / 30
    local radius = POW
    local x = radius * math.cos(angle) + 150
    local y = radius * math.sin(angle) + 150
    Graphics.drawScaleImage(IMG, x, y, 32, 32, Color.new(128, 128, 128, Q))
  end
end

function WaitWithORBS(NN)
  RINCREMENT = 4
  N = NN
  while N > 1 do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    ORBMAN(0x80)
    Screen.flip()
    N = N - 1
  end
  RINCREMENT = 2
end

function FadeWIthORBS(EXPAND)
  RINCREMENT = 3
  local A = 0x80
  local B = 0
  while A > 0 do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    if EXPAND then
      ORBMANex(CURSOR, A, 180, 180, 80+B)
    else
      ORBMAN(A)
    end
    Screen.flip()
    A = A - 1
    B = B + 1
  end
  RINCREMENT = 2
end
--- Processes a HDD full path into its components. (eg: `hdd0:__system:pfs:/osd110/hosdsys.elf`)
---@param PATH string
---@return string mountpart: will return partition path for mounting (`hdd0:__system`)
---@return string pfsindx: will return pfs index (`pfs:`)
---@return string filepath: will return path to file when partition gets mounted (`pfs:/osd110/hosdsys.elf`)
function GetMountData(PATH)
  local CNT = 0
  local TBL = {}
  for i in string.gmatch(PATH, "[^:]*") do
    table.insert(TBL, i)
    CNT = CNT+1
  end
  local mountpart = ""
  local pfsindx   = ""
  local filepath  = ""
  if CNT == 4 then
    mountpart = string.format("%s:%s", TBL[1], TBL[2])
    pfsindx   = string.format("%s:", TBL[3])
    filepath  = string.format("%s:%s", TBL[3], TBL[4])
  end
  return mountpart, pfsindx, filepath
end

function GetFileSizeX(PATH)
  local FD = System.openFile(PATH, FREAD)
  local SIZE = System.sizeFile(FD)
  System.closeFile(FD)
  return SIZE
end

function HEXDUMP(DATA)
  local LOL = 0
  local MESSAGE = ""
  for b in DATA:gmatch('.') do
    MESSAGE = MESSAGE..string.format(('%02X '):format(b:byte()))
    LOL = LOL+1
    if LOL == 16 then MESSAGE = MESSAGE.."\n" end
  end
  return MESSAGE
end

function PreExtraAssetsInstall(FILECOUNT, FOLDERCOUNT, SIZECOUNT)
  if MUST_INSTALL_EXTRA_FILES then
    FOLDERCOUNT = FOLDERCOUNT + #MC_INST_TABLE.dirs
  end
  if #MC_INST_TABLE.source > 0 and MUST_INSTALL_EXTRA_FILES then
    for i = 1, #MC_INST_TABLE.source do
      if doesFileExist(MC_INST_TABLE.source[i]) then -- CHECK FOR EXISTENCE, OTHERWISE, PROGRAM CRASHES!
        SIZECOUNT = SIZECOUNT + GetFileSizeX(MC_INST_TABLE.source[i])
        FILECOUNT = FILECOUNT + 1 -- only add the confirmed files
      end
    end
  end

  return FILECOUNT, FOLDERCOUNT, SIZECOUNT
end

function InstallDVDPlayerAssets(port, cur, total, dvdfolder)
  ReportProgress(cur, total, "", LNG_INSTALLING_DVDPL)
  local ret = 0
  if #DVDPL_INST_TABLE.source > 0 and MUST_INSTALL_EXTRA_FILES then
    for i = 1, #DVDPL_INST_TABLE.source do
      if DVDPL_INST_TABLE.target[i] == "/dvdplayer.elf" then goto skipfile end
      ReportProgress(cur+i, total, dvdfolder..DVDPL_INST_TABLE.target[i], LNG_INSTALLING_EXTRA)
      if doesFileExist(DVDPL_INST_TABLE.source[i]) then -- CHECK FOR EXISTENCE, OTHERWISE, PROGRAM CRASHES!
        ret = System.copyFile(DVDPL_INST_TABLE.source[i], string.format("mc%d:/%s%s", port, dvdfolder, DVDPL_INST_TABLE.target[i]))
        if ret < 0 then return ret end
      end
      ::skipfile::
    end
  end
return 1
end

function InstallExtraAssets(port, cur, total)
  ReportProgress(cur, total)
  local ret = 0
  if #MC_INST_TABLE.dirs > 0 and MUST_INSTALL_EXTRA_FILES then
    for i = 1, #MC_INST_TABLE.dirs do
      -- if System.doesDirExist(string.format("INSTALL/ASSETS/%s", MC_INST_TABLE.dirs[i])) then -- only create the folder if source exists...
      System.createDirectory(string.format("mc%d:/%s", port, MC_INST_TABLE.dirs[i]))
      -- end
    end
  end
  if #MC_INST_TABLE.source > 0 and MUST_INSTALL_EXTRA_FILES then
    for i = 1, #MC_INST_TABLE.source do
      ReportProgress(cur+i, total, MC_INST_TABLE.target[i])
      if doesFileExist(MC_INST_TABLE.source[i]) then -- CHECK FOR EXISTENCE, OTHERWISE, PROGRAM CRASHES!
        ret = System.copyFile(MC_INST_TABLE.source[i], string.format("mc%d:/%s", port, MC_INST_TABLE.target[i]))
        if ret < 0 then return ret end
      end
    end
  end
return 1
end

function CalculateRequiredSpace(port, FILECOUNT, FOLDERCOUNT, SIZECOUNT)
  local TotalRequiredSpace = SIZECOUNT
  local AvailableSpace = 0
  local mcinfo = System.getMCInfo(port)
  TotalRequiredSpace = TotalRequiredSpace + ((FILECOUNT + FOLDERCOUNT + 3) / 2) --  A new cluster is required for every two files.
  AvailableSpace = (mcinfo.freemem * 1024)
  return AvailableSpace, TotalRequiredSpace
end

function HDDCalculateRequiredSpace(INSTALL_TABLE, partition)
  local TotalRequiredSpace = 0
  for i = 1, #INSTALL_TABLE.source do
    if string.sub(INSTALL_TABLE.target[i], 1, #partition) == partition then -- check if the target path correspondes to the specified partition...
      TotalRequiredSpace = TotalRequiredSpace + GetFileSizeX(INSTALL_TABLE.source[i])
    end
  end
  return TotalRequiredSpace
end

function Promptkeys(SELECT, ST, CANCEL, CT, REFRESH, RT, ALFA)
  if SELECT == 1 then
    Graphics.drawScaleImage(cross, 80.0, 400.0, 32, 32, Color.new(0x80, 0x80, 0x80, 0x80 - ALFA))
    Font.ftPrint(LSANS, 110, 407, 0, 400, 16, ST, Color.new(0x80, 0x80, 0x80, 0x80 - ALFA))
  end
  if CANCEL == 1 then
    Graphics.drawScaleImage(circle, 170.0, 400.0, 32, 32, Color.new(0x80, 0x80, 0x80, 0x80 - ALFA))
    Font.ftPrint(LSANS, 200, 407, 0, 400, 16, CT, Color.new(0x80, 0x80, 0x80, 0x80 - ALFA))
  end
  if REFRESH == 1 then
    Graphics.drawScaleImage(triangle, 260.0, 400.0, 32, 32, Color.new(0x80, 0x80, 0x80, 0x80 - ALFA))
    Font.ftPrint(LSANS, 290, 407, 0, 400, 16, RT, Color.new(0x80, 0x80, 0x80, 0x80 - ALFA))
  end

end

function Greeting()
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
      Font.ftPrint(LSANS, X_MID, 20, 8, 630, 16, "THIS IS NOT A PUBLIC-READY VERSION!", Color.new(200, 200, 0, Q))
      Font.ftPrint(LSANS, X_MID, 40, 8, 630, 16, BETANUM, Color.new(200, 200, 0, Q))
    end
    Font.ftPrint(LSANS, X_MID, 310, 8, 630, 16, LNG_CRDTS0, Color.new(128, 128, 128, Q))
    Font.ftPrint(LSANS, X_MID, 330, 8, 630, 16, LNG_CRDTS1, Color.new(128, 128, 128, Q))
    Font.ftPrint(LSANS, X_MID, 350, 8, 630, 16, LNG_CRDTS2, Color.new(128, 128, 128, Q))
    Font.ftPrint(LSANS, X_MID, 370, 8, 630, 16, LNG_CRDTS3, Color.new(128, 128, 128, Q))
    Font.ftPrint(LSANS, X_MID, 390, 8, 630, 16, LNG_CRDTS4, Color.new(240, 240, 10, Q))
    Font.ftPrint(LSANS, X_MID, 410, 8, 630, 16, LNG_DOCSLINK, Color.new(240, 240, 10, Q))
    Screen.flip()
  end
end

function OrbIntro(BGQ)
  RINCREMENT = 4
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
  RINCREMENT = 2
end

function MainMenu()
  local T = 1
  local D = 15
  local A = 0x80
  local NA = 0
  local COL
  if REAL_IS_PSX then COL = 100 else COL = 200 end
  while true do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    ORBMAN(0x80)
    Font.ftPrint(LSANS, X_MID, 40, 8, 630, 32, LNG_MM1, Color.new(220, 220, 220, 0x90 - A))
    if T == 1 then
      Font.ftPrint(LSANS, X_MID+1, 150, 0, 630, 16, LNG_MM2, Color.new(0, 0xde, 0xff, 0x90 - A))
    else
      Font.ftPrint(LSANS, X_MID, 150, 0, 630, 16, LNG_MM2, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 2 then
      Font.ftPrint(LSANS, X_MID+1, 190, 0, 630, 16, LNG_MM7, Color.new(0, 0xde, 0xff, 0x90 - A))
    else
      Font.ftPrint(LSANS, X_MID, 190, 0, 630, 16, LNG_MM7, Color.new(COL, COL, COL, 0x80 - A))
    end
    if T == 3 then
      Font.ftPrint(LSANS, X_MID+1, 230, 0, 630, 16, LNG_MM3, Color.new(0, 0xde, 0xff, 0x90 - A))
    else
      Font.ftPrint(LSANS, X_MID, 230, 0, 630, 16, LNG_MM3, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 4 then
      Font.ftPrint(LSANS, X_MID+1, 270, 0, 630, 16, LNG_MM4, Color.new(0, 0xde, 0xff, 0x90 - A))
    else
      Font.ftPrint(LSANS, X_MID, 270, 0, 630, 16, LNG_MM4, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 5 then
      Font.ftPrint(LSANS, X_MID+1, 310, 0, 630, 16, LNG_MM6, Color.new(0, 0xde, 0xff, 0x90 - A))
    else
      Font.ftPrint(LSANS, X_MID, 310, 0, 630, 16, LNG_MM6, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 6 then
      Font.ftPrint(LSANS, X_MID+1, 350, 0, 630, 16, LNG_MM5, Color.new(0, 0xde, 0xff, 0x90 - A))
    else
      Font.ftPrint(LSANS, X_MID, 350, 0, 630, 16, LNG_MM5, Color.new(200, 200, 200, 0x80 - A))
    end
    if A > 0 then A = A - 1 end
    Promptkeys(1, LNG_CT0, 0, 0, 0, 0, A)

    if NA > 0 then
      if MUST_INSTALL_EXTRA_FILES then
        Font.ftPrint(LSANS, 40, 40, 0, 630, 16,  LNG_EXTRA_INSTALL_ENABLE, Color.new(0x80, 0x80, 0, NA))
      else
        Font.ftPrint(LSANS, 40, 40, 0, 630, 16, LNG_EXTRA_INSTALL_DISABLE, Color.new(0x80, 0x80, 0, NA))
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
    if T < 1 then T = 6 end
    if T > 6 then T = 1 end

  end
  return T
end

function HDDMAN()
  local T = 1
  local D = 15
  local A = 0x80
  local COL = 0
  local COL2 = 0
  local PROMTPS = {
    LNG_HDDPROMPT,
    LNG_HDDPROMPT1.." (NOT FINISHED)",
    LNG_HDDPROMPT2,
  }
  if HDD_STATUS == 0 then
    COL = 200
    COL2 = 200
  elseif HDD_STATUS == 1 then
    COL2 = 200
  end
  while true do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    ORBMAN(0x80)
    if T == 1 then
      Font.ftPrint(LSANS, X_MID+1, 150, 0, 630, 16, LNG_HDD_INSTOPT1, Color.new(0, 0xde, 0xff, 0x80 - A)) else
      Font.ftPrint(LSANS, X_MID, 150, 0, 630, 16, LNG_HDD_INSTOPT1, Color.new(COL, COL, COL, 0x80 - A))
    end
    if T == 2 then
      Font.ftPrint(LSANS, X_MID+1, 190, 0, 630, 16, LNG_HDD_INSTOPT2, Color.new(0, 0xde, 0xff, 0x80 - A)) else
      Font.ftPrint(LSANS, X_MID, 190, 0, 630, 16, LNG_HDD_INSTOPT2, Color.new(COL2, COL2, COL2, 0x80 - A))
    end
    if T == 3 then
      Font.ftPrint(LSANS, X_MID+1, 230, 0, 630, 16, LNG_HDD_INSTOPT3, Color.new(0, 0xde, 0xff, 0x80 - A)) else
      Font.ftPrint(LSANS, X_MID, 230, 0, 630, 16, LNG_HDD_INSTOPT3, Color.new(200, 200, 200, 0x80 - A))
    end

    Font.ftPrint(LSANS, 80, 350, 0, 600, 32, PROMTPS[T], Color.new(128, 128, 128, 0x80 - A))
    Promptkeys(1, LNG_CT0, 1, LNG_CT1, 0, 0, A)
    if A > 0 then A = A - 1 end
    Screen.flip()
    local pad = Pads.get()

    if Pads.check(pad, PAD_CROSS) and D == 0 then
      D = 1
      if ((HDD_STATUS == 0 or HDD_STATUS == 1) and T == 2) or (HDD_STATUS == 0 and T == 1) or T == 3 then -- hdd usable means all features are available, else. only eeprom stuff
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
    Font.ftPrint(LSANS, X_MID, 40, 8, 630, 32, LNG_MM2, Color.new(220, 220, 220, 0x80 - A))
    ORBMAN(0x80)
    if T == 1 then
      Font.ftPrint(LSANS, X_MID+1, 150, 0, 630, 16, LNG_IMPMP1, Color.new(0, 0xde, 0xff, 0x80 - A)) else
      Font.ftPrint(LSANS, X_MID, 150, 0, 630, 16, LNG_IMPMP1, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 2 then
      Font.ftPrint(LSANS, X_MID+1, 190, 0, 630, 16, LNG_IMPMP2, Color.new(0, 0xde, 0xff, 0x80 - A)) else
      Font.ftPrint(LSANS, X_MID, 190, 0, 630, 16, LNG_IMPMP2, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 3 then
      Font.ftPrint(LSANS, X_MID+1, 230, 0, 630, 16, LNG_IMPMP3, Color.new(0, 0xde, 0xff, 0x80 - A)) else
      Font.ftPrint(LSANS, X_MID, 230, 0, 630, 16, LNG_IMPMP3, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 4 then
      Font.ftPrint(LSANS, X_MID+1, 270, 0, 630, 16, LNG_IMPMP4, Color.new(0, 0xde, 0xff, 0x80 - A)) else
      Font.ftPrint(LSANS, X_MID, 270, 0, 630, 16, LNG_IMPMP4, Color.new(200, 200, 200, 0x80 - A))
    end

    Font.ftPrint(LSANS, 80, 350, 0, 600, 32, PROMTPS[T], Color.new(128, 128, 128, 0x80 - A))
    Promptkeys(1, LNG_CT0, 1, LNG_CT1, 0, 0, A)
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
    "SCPH-XXX[01/06/07/10/11/12]",
    "SCPH-XXX0[2/3/4/8]",
    "SCPH-XXX09"
  }
  while true do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    ORBMAN(0x80)
    Font.ftPrint(LSANS, X_MID, 40, 8, 630, 32, LNG_PICK_DVDPLAYER_REG, Color.new(220, 220, 220, 0x80 - A))

    if T == 1 then
      Font.ftPrint(LSANS, X_MID+1, 150, 0, 630, 16, LNG_JPN, Color.new(0, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(LSANS, X_MID, 150, 0, 630, 16, LNG_JPN, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 2 then
      Font.ftPrint(LSANS, X_MID+1, 190, 0, 630, 16, LNG_USANASIA, Color.new(0, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(LSANS, X_MID, 190, 0, 630, 16, LNG_USANASIA, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 3 then
      Font.ftPrint(LSANS, X_MID+1, 230, 0, 630, 16, LNG_EUR, Color.new(0, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(LSANS, X_MID, 230, 0, 630, 16, LNG_EUR, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 4 then
      Font.ftPrint(LSANS, X_MID+1, 270, 0, 630, 16, LNG_CHN, Color.new(0, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(LSANS, X_MID, 270, 0, 630, 16, LNG_CHN, Color.new(200, 200, 200, 0x80 - A))
    end

    Font.ftPrint(LSANS, X_MID, 350, 8, 600, 32, PROMTPS[T], Color.new(128, 128, 128, 0x80 - A))
    Promptkeys(1, LNG_CT0, 1, LNG_CT1, 0, 0, A)
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
  if (T >= 3) then -- this special condition is required because value 2 is for ASIAN models, wicha re virtually a copy of USA
    return T
  else
    return (T-1)
  end
end

function DVDPlayerINST(port, slot, target_region)
  local RET
  local TARGET_FOLD = KELFBinder.getDVDPlayerFolder(target_region)
  local TARGET_KELF = string.format("mc%d:/%s/dvdplayer.elf", port, TARGET_FOLD)
  local tinst = #DVDPL_INST_TABLE.target+2
  if doesFileExist(DVDPLAYERUPDATE) then
    System.AllowPowerOffButton(0)
    ReportProgress(0, tinst, (LNG_INSTPMPT):format(TARGET_KELF), LNG_INSTALLING_DVDPL)
    System.createDirectory(string.format("mc%d:/%s", port, TARGET_FOLD))
    KELFBinder.setSysUpdateFoldProps(port, slot, TARGET_FOLD)
    RET = Secrman.downloadfile(port, slot, DVDPLAYERUPDATE, TARGET_KELF)
    if RET < 0 then Secrerr(RET) return end
    RET = InstallDVDPlayerAssets(port, 1, tinst, TARGET_FOLD)
    if RET < 0 then Secrerr(RET) return end
    ReportProgress(tinst, tinst, "", LNG_INSTALLING_DVDPL)
    System.AllowPowerOffButton(1)
    Secrerr(RET)
  else
    Secrerr(-203)
  end
end

function NormalInstall(port, slot)

  if doesFileExist(string.format("mc%d:SYS-CONF/FMCBUINST.dat", port)) or
      doesFileExist(string.format("mc%u:SYS-CONF/uninstall.dat", port)) then WarnOfShittyFMCBInst() return end

  local RET
  local REG = KELFBinder.getsystemregion()
  local TARGET_FOLD
  local FOLDCOUNT = 1 -- the system update folder that we'll be dealing with
  local FILECOUNT = 2 -- icons + whatever updates you push
  local NEEDED_SPACE = 1024 + 964 -- 1kb + icon.sys size to begin with
  local AvailableSpace = 0

  NEEDED_SPACE = NEEDED_SPACE + GetFileSizeX(SYSUPDATE_ICON_SYS_RES)
  if doesFileExist(TEST_KELF) then
    RET, _, _, _ = Secrman.Testdownloadfile(port, slot, TEST_KELF)
  else
    RET, _, _, _ = Secrman.Testdownloadfile(port, slot, KERNEL_PATCH_100)
  end
  if RET < 0 then Secrerr(RET) return end

  if IS_PSX then
    NEEDED_SPACE = NEEDED_SPACE + GetFileSizeX(SYSUPDATE_PSX)
    TARGET_FOLD = string.format("mc%d:/BIEXEC-SYSTEM", port)
  else
    NEEDED_SPACE = NEEDED_SPACE + GetFileSizeX(SYSUPDATE_MAIN)
    TARGET_FOLD = string.format("mc%d:/%s", port, KELFBinder.getsysupdatefolder())
  end
  FILECOUNT, FOLDCOUNT, NEEDED_SPACE = PreExtraAssetsInstall(FILECOUNT, FOLDCOUNT, NEEDED_SPACE)
  AvailableSpace, NEEDED_SPACE = CalculateRequiredSpace(port, FILECOUNT, FOLDCOUNT, NEEDED_SPACE)
  if AvailableSpace < NEEDED_SPACE then InsufficientSpace(NEEDED_SPACE, AvailableSpace, LNG_MEMORY_CARD.." "..port) return end
  local tot = FILECOUNT + 3
  local cur = 0
  if System.doesDirExist(TARGET_FOLD) then
    Ask2WipeSysUpdateDirs(false, false, false, false, true, port)
  end
  ReportProgress(0, tot)
  System.AllowPowerOffButton(0)
  System.createDirectory(TARGET_FOLD)
  ReportProgress(1, tot)

  if IS_PSX then
    SYSUPDATEPATH = "BIEXEC-SYSTEM/xosdmain.elf"
    KELFBinder.setSysUpdateFoldProps(port, slot, "BIEXEC-SYSTEM")
  else
    SYSUPDATEPATH = KELFBinder.calculateSysUpdatePath()
    KELFBinder.setSysUpdateFoldProps(port, slot, KELFBinder.getsysupdatefolder())
  end

  ReportProgress(2, tot)
  if (ROMVERN == 100) or (ROMVERN == 101) then -- PROTOKERNEL NEEDS TWO UPDATES TO FUNCTION
    Secrman.downloadfile(port, slot, SYSUPDATE_MAIN, string.format("mc%d:/%s", port, "BIEXEC-SYSTEM/osd130.elf")) -- SCPH-18000
    if (ROMVERN == 100) then
      RET = Secrman.downloadfile(port, slot, KERNEL_PATCH_100, string.format("mc%d:/%s", port, SYSUPDATEPATH))
      if RET < 0 then Secrerr(RET) return end
    else
      RET = Secrman.downloadfile(port, slot, KERNEL_PATCH_101, string.format("mc%d:/%s", port, SYSUPDATEPATH))
      if RET < 0 then Secrerr(RET) return end
    end
  elseif IS_PSX then -- PSX NEEDS SPECIAL PATH
    ReportProgress(3, tot)
    RET = Secrman.downloadfile(port, slot, SYSUPDATE_PSX, string.format("mc%d:/BIEXEC-SYSTEM/xosdmain.elf", port))
    if RET < 0 then Secrerr(RET) return end
  else -- ANYTHING ELSE FOLLOWS WHATEVER IS WRITTEN INTO 'SYSUPDATEPATH'
    ReportProgress(3, tot)
    RET = Secrman.downloadfile(port, slot, SYSUPDATE_MAIN, string.format("mc%d:/%s", port, SYSUPDATEPATH))
    if RET < 0 then Secrerr(RET) return end
  end
  -- KELF install finished! deal with extra files now!
  ReportProgress(4, tot, "icon.sys")
  if REG == 0 or IS_PSX then -- JPN
    System.copyFile("INSTALL/ASSETS/JPN.sys", string.format("%s/icon.sys", TARGET_FOLD))
  elseif REG == 1 or REG == 2 then --USA or ASIA
    System.copyFile("INSTALL/ASSETS/USA.sys", string.format("%s/icon.sys", TARGET_FOLD))
  elseif REG == 3 then
    System.copyFile("INSTALL/ASSETS/EUR.sys", string.format("%s/icon.sys", TARGET_FOLD))
  elseif REG == 4 then
    System.copyFile("INSTALL/ASSETS/CHN.sys", string.format("%s/icon.sys", TARGET_FOLD))
  end
  System.copyFile(SYSUPDATE_ICON_SYS_RES, string.format("%s/%s", TARGET_FOLD, SYSUPDATE_ICON_SYS)) --icon is the same for all

  ReportProgress(5, tot)
  RET = InstallExtraAssets(port, 5, tot)
  System.AllowPowerOffButton(1)
  ReportProgressFadeEnd()
  Secrerr(RET)
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
  local MC2_CNTR = SCR_X - 160 - 32
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
    Font.ftPrint(LSANS, X_MID, 40, 8, 630, 32, LNG_MEMCARD0, Color.new(0x80, 0x80, 0x80, 0x80 - A))
    Font.ftPrint(LSANS, 160, 270, 8, 630, 32, string.format(LNG_MEMCARD1, 1), Color.new(0x80, 0x80, 0x80, 0x80 - A))
    if mcinfo0.type == 2 then
      if mcinfo0.format == 1 then
        Font.ftPrint(LSANS, 160, 290, 8, 630, 32, string.format(LNG_MEMCARD2, mcinfo0.freemem), Color.new(0x80, 0x80, 0x80, 0x80 - A))
      else
        Font.ftPrint(LSANS, 160, 290, 8, 630, 32, LNG_UNFORMATTED_CARD, Color.new(0x80, 0, 0, 0x80-A))
      end
    elseif mcinfo0.type ~= 0 then
      Font.ftPrint(LSANS, 160, 290, 8, 630, 32, LNG_INCOMPATIBLE_CARD, Color.new(0x80, 0x80, 0x80, 0x80 - A))
    end

    if T == 0 then
      Graphics.drawScaleImage(mi0, 160 - 32, 180.0, 64, 64, Color.new(0x90, 0x90, 0x90, Q))
    else
      Graphics.drawScaleImage(mi0, 160 - 32, 180.0, 64, 64, Color.new(0x80, 0x80, 0x80, 0x80 - A))
    end

    Font.ftPrint(LSANS, MC2_CNTR, 270, 8, 630, 32, string.format(LNG_MEMCARD1, 2), Color.new(0x80, 0x80, 0x80, 0x80 - A))
    if mcinfo1.type == 2 then
      if mcinfo1.format == 1 then
        Font.ftPrint(LSANS, MC2_CNTR, 290, 8, 630, 32, string.format(LNG_MEMCARD2, mcinfo1.freemem), Color.new(0x80, 0x80, 0x80, 0x80 - A))
      else
        Font.ftPrint(LSANS, MC2_CNTR, 290, 8, 630, 32, LNG_UNFORMATTED_CARD, Color.new(0x80, 0, 0, 0x80-A))
      end
    elseif mcinfo1.type ~= 0 then
      Font.ftPrint(LSANS, MC2_CNTR, 290, 8, 630, 32, LNG_INCOMPATIBLE_CARD, Color.new(0x80, 0x80, 0x80, 0x80 - A))
    end
    if T == 1 then
      Graphics.drawScaleImage(mi1, MC2_CNTR-32, 180.0, 64, 64, Color.new(0x90, 0x90, 0x90, Q))
    else
      Graphics.drawScaleImage(mi1, MC2_CNTR-32, 180.0, 64, 64, Color.new(0x80, 0x80, 0x80, 0x80 - A))
    end

    if A > 0 then A = A - 1 end
    Promptkeys(1, LNG_CT0, 1, LNG_CT1, 1, LNG_CT2, A)
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

function ExpertINSTprompt()
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

    Font.ftPrint(LSANS, X_MID, 40, 8, 630, 32, LNG_EXPERTINST_PROMPT, Color.new(0x80, 0x80, 0x80, 0x80 - A))
    if SUPPORTS_UPDATES then
      Font.ftPrint(LSANS, X_MID, 60, 8, 630, 32, LNG_EXPERTINST_PROMPT1, Color.new(0x80, 0x80, 0, 0x80 - A))
      Font.ftPrint(LSANS, X_MID, 80, 8, 630, 32, SYSUP, Color.new(0x70, 0x70, 0x70, 0x80 - A))
    end
    Font.ftPrint(LSANS, 110, 120, 0, 630, 16, LNG_REGS0, Color.new(0x80, 0x80, 0, 0x80 - A))
    Font.ftPrint(LSANS, 110, 240, 0, 630, 16, LNG_REGS1, Color.new(0x80, 0x80, 0, 0x80 - A))
    Font.ftPrint(LSANS, 292, 120, 0, 630, 32, LNG_REGS2, Color.new(0x80, 0x80, 0, 0x80 - A))
    Font.ftPrint(LSANS, 292, 240, 0, 630, 16, LNG_REGS3, Color.new(0x80, 0x80, 0, 0x80 - A))
    Font.ftPrint(LSANS, 104, 340, 0, 600, 32, UPDTT[T] , Color.new(200, 200, 200, 0x80 - A))

    if UPDT[0] == 1 then Graphics.drawImage(CHKF, 110, 142) else Graphics.drawImage(CHK_, 110, 142, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[1] == 1 then Graphics.drawImage(CHKF, 110, 162) else Graphics.drawImage(CHK_, 110, 162, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[2] == 1 then Graphics.drawImage(CHKF, 110, 182) else Graphics.drawImage(CHK_, 110, 182, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[3] == 1 then Graphics.drawImage(CHKF, 110, 202) else Graphics.drawImage(CHK_, 110, 202, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[4] == 1 then Graphics.drawImage(CHKF, 110, 262) else Graphics.drawImage(CHK_, 110, 262, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[5] == 1 then Graphics.drawImage(CHKF, 110, 282) else Graphics.drawImage(CHK_, 110, 282, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[6] == 1 then Graphics.drawImage(CHKF, 110, 302) else Graphics.drawImage(CHK_, 110, 302, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[7] == 1 then Graphics.drawImage(CHKF, 292, 162) else Graphics.drawImage(CHK_, 292, 162, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[8] == 1 then Graphics.drawImage(CHKF, 292, 182) else Graphics.drawImage(CHK_, 292, 182, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if UPDT[9] == 1 then Graphics.drawImage(CHKF, 292, 262) else Graphics.drawImage(CHK_, 292, 262, Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
    if T == JAP_ROM_100 then
      Font.ftPrint(LSANS, 139, 140, 0, 400, 16, "osdsys.elf", Color.new(0x80, 0x80, 0x80, 0x80 - A))
    else
      Font.ftPrint(LSANS, 139, 140, 0, 400, 16, "osdsys.elf", Color.new(0x80, 0x80, 0x80, 0x50 - A))
    end
    if T == JAP_ROM_101 then
      Font.ftPrint(LSANS, 139, 160, 0, 400, 16, "osd110.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(LSANS, 139, 160, 0, 400, 16, "osd110.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if T == JAP_ROM_120 then
      Font.ftPrint(LSANS, 139, 180, 0, 400, 16, "osd130.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(LSANS, 139, 180, 0, 400, 16, "osd130.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if T == JAP_STANDARD then
      Font.ftPrint(LSANS, 139, 200, 0, 400, 16, "osdmain.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(LSANS, 139, 200, 0, 400, 16, "osdmain.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if T == USA_ROM_110 then
      Font.ftPrint(LSANS, 139, 260, 0, 400, 16, "osd120.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(LSANS, 139, 260, 0, 400, 16, "osd120.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if T == USA_ROM_120 then
      Font.ftPrint(LSANS, 139, 280, 0, 400, 16, "osd130.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(LSANS, 139, 280, 0, 400, 16, "osd130.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if T == USA_STANDARD then
      Font.ftPrint(LSANS, 139, 300, 0, 400, 16, "osdmain.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(LSANS, 139, 300, 0, 400, 16, "osdmain.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if T == EUR_ROM_120 then
      Font.ftPrint(LSANS, X_MID-40, 160, 0, 400, 16, "osd130.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(LSANS, X_MID-40, 160, 0, 400, 16, "osd130.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if T == EUR_STANDARD then
      Font.ftPrint(LSANS, X_MID-40, 180, 0, 400, 16, "osdmain.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(LSANS, X_MID-40, 180, 0, 400, 16, "osdmain.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if T == CHN_STANDARD then
      Font.ftPrint(LSANS, X_MID-40, 260, 0, 400, 16, "osdmain.elf", Color.new(0x80, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(LSANS, X_MID-40, 260, 0, 400, 16, "osdmain.elf", Color.new(0x80, 0xde, 0xff, 0x50 - A))
    end
    if A > 0 then A = A - 1 end
    Promptkeys(1, LNG_CT0, 1, LNG_CT1, 1, LNG_CT3, A)
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
      UPDT["x"] = true
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
  if UPDT["x"] then -- if user wants to install check if he picked any item
    for i = 0, 9 do
      if UPDT[i] == 1 then -- found at least one selected item, proceed
        UPDT["x"] = true
        return UPDT
      end
    end
    UPDT["x"] = false -- user hit install without picking items, quit
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
  if REAL_IS_PSX then PROMTPS[3] = LNG_DESC_MACHINE_IS_PSX end
  while true do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    ORBMAN(0x80)

    Font.ftPrint(LSANS, X_MID, 40, 8, 630, 32, LNG_IMPMP2, Color.new(220, 220, 220, 0x80 - A))
    if T == 1 then
      Font.ftPrint(LSANS, X_MID+1, 150, 0, 630, 16, LNG_AI_CROSS_MODEL, Color.new(0, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(LSANS, X_MID, 150, 0, 630, 16, LNG_AI_CROSS_MODEL, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 2 then
      Font.ftPrint(LSANS, X_MID+1, 190, 0, 630, 16, LNG_AI_CROSS_REGION, Color.new(0, 0xde, 0xff, 0x80 - A))
    else
      Font.ftPrint(LSANS, X_MID, 190, 0, 630, 16, LNG_AI_CROSS_REGION, Color.new(200, 200, 200, 0x80 - A))
    end
    if T == 3 then
      Font.ftPrint(LSANS, X_MID+1, 230, 0, 630, 16, "PSX DESR", Color.new(0, 0xde, 0xff, 0x80 - A))
    elseif REAL_IS_PSX then
      Font.ftPrint(LSANS, X_MID, 230, 0, 630, 16, "PSX DESR", Color.new(50, 50, 50, 0x80 - A))
    else -- make the PSX option grey if runner machine is PSX
      Font.ftPrint(LSANS, X_MID, 230, 0, 630, 16, "PSX DESR", Color.new(200, 200, 200, 0x80 - A))
    end

    Font.ftPrint(LSANS, 80, 350, 0, 600, 32, PROMTPS[T], Color.new(0x70, 0x70, 0x70, 0x80 - A))
    Promptkeys(1, LNG_CT0, 1, LNG_CT1, 0, 0, A)
    if A > 0 then A = A - 1 end
    Screen.flip()
    local pad = Pads.get()

    if Pads.check(pad, PAD_CROSS) and D == 0 then
      if T == 3 and REAL_IS_PSX then
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
  if INSTMODE == 1 then -- all models for same region
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
  elseif INSTMODE == 2 then -- all models of all regions (save PSX)
    for i = 0, 9 do
      UPDT[i] = 1
    end
  elseif INSTMODE == 3 then -- PSX
    UPDT[10] = 1
  else
    UPDT["x"] = false
  end
  return UPDT
end

function Secrerr(RET)
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

      Promptkeys(1, LNG_CONTINUE, 0, 0, 0, 0, A)
      if RET ~= 1 then
        Font.ftPrint(LSANS, X_MID, 40, 8, 630, 64, string.format(LNG_INSTERR, RET), Color.new(0x80, 0x80, 0x80, 0x80 - A))
      else
        Font.ftPrint(LSANS, X_MID, 40, 8, 630, 64, LNG_INSTPMPT1, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      end
      if RET == (-5) then
        Font.ftPrint(LSANS, X_MID, 60, 8, 630, 64, LNG_EIO, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == (-22) then
        Font.ftPrint(LSANS, X_MID, 60, 8, 630, 64, LNG_SECRMANERR, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == (-12) then
        Font.ftPrint(LSANS, X_MID, 60, 8, 630, 64, LNG_ENOMEM, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == (-201) or RET == (-203) then
        Font.ftPrint(LSANS, X_MID, 60, 8, 630, 64, LNG_SOURCE_KELF_GONE, Color.new(0x80, 0x80, 0x80, 0x80 - A))
        if RET == (-203) then Font.ftPrint(LSANS, X_MID, 85, 8, 630, 64, LNG_WARN_DVDPLAYER_PROPIETARY_SOFTWARE , Color.new(0x80, 0x80, 0x80, 0x80 - A)) end
      elseif RET == (-202) then
        Font.ftPrint(LSANS, X_MID, 80 , 8, 630, 64, LNG_MBR_KELF_SIZE_OUT_OF_BOUNDS , Color.new(0x80, 0x80, 0x80, 0x80 - A))
        Font.ftPrint(LSANS, X_MID, 100, 8, 630, 64, LNG_MBR_KELF_SIZE_OUT_OF_BOUNDS2, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET ~= 1 then -- only write unknown error if retcode is not a success
        Font.ftPrint(LSANS, X_MID, 60, 8, 630, 64, LNG_EUNKNOWN, Color.new(0x80, 0x80, 0x80, 0x80 - A))
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

function Report(RET, IS_GOOD, IS_A_QUESTION)
  local A = 0x80
  local Q = 0x7f
  local QIN = 1
  local pad = 0
  local ret = false
  while A > 0 do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, A))
    A = A - 1
    Screen.flip()
  end
  A = 0x80
  while true do
    Screen.clear()
    if IS_GOOD then
      Graphics.drawScaleImage(BGSCS, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
      ORBMANex(GREENCURSOR, 0x80 - Q - 1, 180, 180, 80 + Q)
    else
      Graphics.drawScaleImage(BGERR, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
      ORBMANex(REDCURSOR, 0x80 - Q - 1, 180, 180, 80 + Q)
    end
    if Q < 0x20 then
      pad = Pads.get()
      if A > 0 then A = A - 1 end
      if IS_A_QUESTION then Promptkeys(1, LNG_CONTINUE, 1, LNG_CT1, 0, 0, A) else Promptkeys(1, LNG_CONTINUE, 0, 0, 0, 0, A) end

      if RET == 101 then
        Font.ftPrint(LSANS, X_MID, 60, 8, 630, 64, LNG_HDDBOOT_ALREADY_ENABLED, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == 100 then
        Font.ftPrint(LSANS, X_MID, 60, 8, 630, 64, LNG_HDDBOOT_ENABLED, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == 200 then
        Font.ftPrint(LSANS, X_MID, 60,  8, 630, 64, LNG_HDDFORMAT_CONFIRM, Color.new(0x80, 0x80, 0x80, 0x80 - A))
        Font.ftPrint(LSANS, X_MID, 100, 8, 630, 64, LNG_HDDFORMAT_CONFIRM2, Color.new(0x80, 0x80, 0x80, 0x80 - A))
        Font.ftPrint(LSANS, X_MID, 140, 8, 630, 64, LNG_CONTINUE.."?", Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == 300 then
        Font.ftPrint(LSANS, X_MID, 60,  8, 630, 64, LNG_HDD_SMART_STATUS_FAILS_WARNING, Color.new(0x80, 0x80, 0, 0x80 - A))
        Font.ftPrint(LSANS, X_MID, 140, 8, 630, 64, LNG_HDD_RECOMMEND_HDD_REPLACE, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == 301 then
        Font.ftPrint(LSANS, X_MID, 60,  8, 630, 64, LNG_HDD_SECTOR_ERROR_WARNING, Color.new(0x80, 0x80, 0, 0x80 - A))
        Font.ftPrint(LSANS, X_MID, 140, 8, 630, 64, LNG_HDD_RECOMMEND_HDD_REPLACE, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == 302 then
        Font.ftPrint(LSANS, X_MID, 60,  8, 630, 64, LNG_HDD_CORRUPTED_PART_WARNING, Color.new(0x80, 0x80, 0, 0x80 - A))
        Font.ftPrint(LSANS, X_MID, 140, 8, 630, 64, LNG_HDD_RECOMMEND_FORMAT_OR_FSCK, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == 400 then
        Font.ftPrint(LSANS, X_MID, 60,  8, 630, 64, LNG_DEX_MACHINE_WARNING, Color.new(0x80, 0x80, 0, 0x80 - A))
        Font.ftPrint(LSANS, X_MID, 140, 8, 630, 64, LNG_DEX_MACHINE_WARNING_DESC, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == 666 then
        Font.ftPrint(LSANS, X_MID, 60,  8, 630, 64, LNG_SECRMAN_REPLACE_FAIL, Color.new(0x80, 0x80, 0, 0x80 - A))
        Font.ftPrint(LSANS, X_MID, 140, 8, 630, 64, string.format(LNG_SECRMAN_REPLACE_FAIL2, RPC_STATUS), Color.new(0x80, 0x80, 0x80, 0x80 - A))
        Font.ftPrint(LSANS, X_MID, 160, 8, 630, 64, LNG_SECRMAN_REPLACE_FAIL3, Color.new(0x80, 0x80, 0x80, 0x80 - A))
        Font.ftPrint(LSANS, X_MID, 180, 8, 630, 64, LNG_SECRMAN_REPLACE_FAIL4, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      end
      if Pads.check(pad, PAD_CROSS) and A == 0 then
        ret = true
        QIN = -1
        Q = 1
      end
      if Pads.check(pad, PAD_CIRCLE) and A == 0 then
        QIN = -1
        Q = 1
      end
    end
    if Q > 0 and Q < 0x80 then Q = Q - QIN end
    if Q > 0x7f then break end
    Screen.flip()
  end
  return ret
end

function MagicGateTest(port, slot)
  local A = 0x80
  local Q = 0x7f
  local QIN = 1
  local PADV = 0
  while A > 0 do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y, Color.new(0x80, 0x80, 0x80, A))
    Font.ftPrint(LSANS, X_MID, 40, 8, 630, 64, LNG_PLS_WAIT, Color.new(0x80, 0x80, 0x80, 0x80 - A))
    A = A - 1
    Screen.flip()
  end
  local RET
  local HEADER
  local KBIT
  local KCONT
  local MESSAGE = ""
  local MESSAGE1 = ""
  local MESSAGE2 = ""
  if doesFileExist(TEST_KELF) then
    RET, HEADER, KBIT, KCONT = Secrman.Testdownloadfile(port, slot, TEST_KELF)
  else
    RET, HEADER, KBIT, KCONT = Secrman.Testdownloadfile(port, slot, KERNEL_PATCH_100)
  end
  MESSAGE = HEXDUMP(HEADER)
  MESSAGE1 = HEXDUMP(KBIT)
  MESSAGE2 = HEXDUMP(KCONT)
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
      Promptkeys(1, LNG_CONTINUE, 0, 0, 0, 0, A)
      if RET ~= 1 then
        Font.ftPrint(LSANS, X_MID, 40, 8, 630, 64, string.format(LNG_TESTTERR, RET), Color.new(0x80, 0x80, 0x80, 0x80 - A))
      else
        Font.ftPrint(LSANS, X_MID, 40,  8, 630, 64, LNG_TESTSUCC, Color.new(0x80, 0x80, 0x80, 0x80 - A))
        Font.ftPrint(LSANS, 120, 200, 0, 630, 64, LNG_KELF_HEAD, Color.new(0x80, 0x80, 0x80, 0x80 - A))
        Font.ftPrint(LSANS_SMALL, 150, 220, 0, 630, 32, MESSAGE, Color.new(0x80, 0x80, 0, 0x80 - A))
        Font.ftPrint(LSANS, 120, 260, 0, 630, 64, "Kbit:", Color.new(0x80, 0x80, 0x80, 0x80 - A))
        Font.ftPrint(LSANS_SMALL, 150, 280, 0, 630, 32, MESSAGE1, Color.new(0x80, 0x80, 0, 0x80 - A))
        Font.ftPrint(LSANS, 120, 300, 0, 630, 64, "Kc:", Color.new(0x80, 0x80, 0x80, 0x80 - A))
        Font.ftPrint(LSANS_SMALL, 150, 320, 0, 630, 32, MESSAGE2, Color.new(0x80, 0x80, 0, 0x80 - A))
      end
      if RET == (-5) then
        Font.ftPrint(LSANS, X_MID, 60, 8, 630, 64, LNG_EIO, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == (-22) then
        Font.ftPrint(LSANS, X_MID, 60, 8, 630, 64, LNG_SECRMANERR, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == (-12) then
        Font.ftPrint(LSANS, X_MID, 60, 8, 630, 64, LNG_ENOMEM, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET == (-201) then
        Font.ftPrint(LSANS, X_MID, 60, 8, 630, 64, LNG_SOURCE_KELF_GONE, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      elseif RET ~= 1 then -- only write unknown error if retcode is not a success
        Font.ftPrint(LSANS, X_MID, 60, 8, 630, 64, LNG_EUNKNOWN, Color.new(0x80, 0, 0, 0x80 - A))
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
    Font.ftPrint(LSANS, X_MID, 40, 8, 630, 64, LNG_WARNING, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    Font.ftPrint(LSANS, X_MID, 80, 8, 630, 64, LNG_FMCBINST_CRAP0, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    Font.ftPrint(LSANS, X_MID, 120, 8, 630, 64, LNG_FMCBINST_CRAP1, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    Font.ftPrint(LSANS, X_MID, 190, 8, 630, 64, LNG_FMCBINST_CRAP2, Color.new(0x80, 0x80, A, 0x80 - Q))

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

function InsufficientSpace(NEEDED, AVAILABLE, targetdev)
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
    Font.ftPrint(LSANS, X_MID, 40, 8, 630, 64, LNG_ERROR, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    Font.ftPrint(LSANS, X_MID, 80, 8, 630, 64, string.format(LNG_NOT_ENOUGH_SPACE0, targetdev), Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    Font.ftPrint(LSANS, X_MID, 120, 8, 630, 64, string.format(LNG_NOT_ENOUGH_SPACE1, NEEDED / 1024, AVAILABLE / 1024),
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

      Promptkeys(1, LNG_YES, 1, LNG_NO, 0, 0, A)
      Font.ftPrint(LSANS, 50, 40, 0, 630, 64, LNG_WARNING, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      Font.ftPrint(LSANS, 50, 100, 0, 630, 64, LNG_WARN_CONFLICT0, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      Font.ftPrint(LSANS, 50, 160, 0, 630, 64, LNG_WARN_CONFLICT1, Color.new(0x80, 0x80, 0x80, 0x80 - A))
      Font.ftPrint(LSANS, 50, 260, 0, 630, 64, LNG_WARN_CONFLICT2, Color.new(0x70, 0x70, 0x70, 0x80 - A))
      Font.ftPrint(LSANS, 50, 300, 0, 630, 64, LNG_WARN_CONFLICT3, Color.new(0x70, 0x70, 0x70, 0x80 - A))
      Font.ftPrint(LSANS, 50, 340, 0, 630, 64, LNG_WARN_CONFLICT4, Color.new(0x70, 0x70, 0x70, 0x80 - A))


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
    Promptkeys(1, LNG_CONTINUE, 0, 0, 0, 0, Q)
    Font.ftPrint(LSANS, X_MID, 40, 8, 630, 64, LNG_COMPAT0, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    Font.ftPrint(LSANS, X_MID, 100, 8, 630, 64, LNG_COMPAT1, Color.new(0x80, 0x80, 0x80, 0x80 - Q))
    if Pads.check(pad, PAD_CROSS) then
      QIN = -1
      Q = 1
    end
    if Q > 0 and Q < 0x80 then Q = Q - QIN end
    if Q > 0x7f then break end
    Screen.flip()
  end
end

function PerformExpertINST(port, slot, UPDT)
  Screen.clear()
  Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
  Screen.flip()

  if doesFileExist(string.format("mc%d:SYS-CONF/FMCBUINST.dat", port)) or
      doesFileExist(string.format("mc%u:SYS-CONF/uninstall.dat", port)) then WarnOfShittyFMCBInst() return end

  Screen.clear()
  Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
  Font.ftPrint(LSANS, X_MID, 40, 8, 600, 64, LNG_CALCULATING)
  Screen.flip()
  local RETT
  if doesFileExist(TEST_KELF) then
    RETT, _, _, _ = Secrman.Testdownloadfile(port, slot, TEST_KELF)
  else
    RETT, _, _, _ = Secrman.Testdownloadfile(port, slot, KERNEL_PATCH_100)
  end
  if RETT < 0 then Secrerr(RETT) return end
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
  local total = FILECOUNT+3
  local cur=0
  if AvailableSpace < SIZE_NEED2 then InsufficientSpace(SIZE_NEED2, AvailableSpace, LNG_MEMORY_CARD.." "..port) return end
  if FOLDS_CONFLICT then Ask2WipeSysUpdateDirs(NEEDS_JPN, NEEDS_USA, NEEDS_EUR, NEEDS_CHN, false, port) end

  System.AllowPowerOffButton(0)

  ReportProgress(0, total)

  if NEEDS_JPN then System.createDirectory(JPN_FOLD) end
  if NEEDS_USA then System.createDirectory(USA_FOLD) end
  if NEEDS_EUR then System.createDirectory(EUR_FOLD) end
  if NEEDS_CHN then System.createDirectory(CHN_FOLD) end

  if UPDT[0] == 1 then
    cur = cur+1
    ReportProgress(cur, total, "osdsys.elf")
    RET = Secrman.downloadfile(port, slot, KERNEL_PATCH_100, string.format("mc%d:/BIEXEC-SYSTEM/osdsys.elf", port), 0)
    if RET < 0 then Secrerr(RET) return end
  end
  if UPDT[1] == 1 then
    cur = cur+1
    ReportProgress(cur, total, "osd110.elf")
    RET = Secrman.downloadfile(port, slot, KERNEL_PATCH_101, string.format("mc%d:/BIEXEC-SYSTEM/osd110.elf", port), 0)
    if RET < 0 then Secrerr(RET) return end
  end

  SYSUPDATEPATH = KELFBinder.calculateSysUpdatePath()
  cur = cur+1
  ReportProgress(cur, total, SYSUPDATEPATH)
  local RET = Secrman.downloadfile(port, slot, SYSUPDATE_MAIN, string.format("mc%d:/%s", port, SYSUPDATEPATH), FLAGS)
  if RET < 0 then Secrerr(RET) return end


  if NEEDS_JPN then
    KELFBinder.setSysUpdateFoldProps(port, slot, "BIEXEC-SYSTEM")
    cur = cur+1 ReportProgress(cur, total, SYSUPDATE_ICON_SYS)
    System.copyFile("INSTALL/ASSETS/JPN.sys", string.format("mc%d:/%s/icon.sys", port, "BIEXEC-SYSTEM"))
    System.copyFile(SYSUPDATE_ICON_SYS_RES, string.format("mc%d:/%s/%s", port, "BIEXEC-SYSTEM", SYSUPDATE_ICON_SYS))
  end
  if NEEDS_USA then
    KELFBinder.setSysUpdateFoldProps(port, slot, "BAEXEC-SYSTEM")
    cur = cur+1 ReportProgress(cur, total, SYSUPDATE_ICON_SYS)
    System.copyFile("INSTALL/ASSETS/USA.sys", string.format("mc%d:/%s/icon.sys", port, "BAEXEC-SYSTEM"))
    System.copyFile(SYSUPDATE_ICON_SYS_RES, string.format("mc%d:/%s/%s", port, "BAEXEC-SYSTEM", SYSUPDATE_ICON_SYS))
  end
  if NEEDS_EUR then
    KELFBinder.setSysUpdateFoldProps(port, slot, "BEEXEC-SYSTEM")
    cur = cur+1 ReportProgress(cur, total, SYSUPDATE_ICON_SYS)
    System.copyFile("INSTALL/ASSETS/EUR.sys", string.format("mc%d:/%s/icon.sys", port, "BEEXEC-SYSTEM"))
    System.copyFile(SYSUPDATE_ICON_SYS_RES, string.format("mc%d:/%s/%s", port, "BEEXEC-SYSTEM", SYSUPDATE_ICON_SYS))
  end
  if NEEDS_CHN then
    KELFBinder.setSysUpdateFoldProps(port, slot, "BCEXEC-SYSTEM")
    cur = cur+1 ReportProgress(cur, total, SYSUPDATE_ICON_SYS)
    System.copyFile("INSTALL/ASSETS/CHN.sys", string.format("mc%d:/%s/icon.sys", port, "BCEXEC-SYSTEM"))
    System.copyFile(SYSUPDATE_ICON_SYS_RES, string.format("mc%d:/%s/%s", port, "BCEXEC-SYSTEM", SYSUPDATE_ICON_SYS))
  end

  RET = InstallExtraAssets(port, cur, total)
  System.AllowPowerOffButton(1)
  ReportProgressFadeEnd()
  Secrerr(RET)
end

function ReportProgress(prog, total, EXTRASTR, MAINSTR)
  Screen.clear()
  Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
  local a
  if type(MAINSTR) == "string" then a = MAINSTR else a = LNG_INSTALLING end
  Font.ftPrint(LSANS, X_MID, 40, 8, 600, 64, a)
  if type(EXTRASTR) == "string" then Font.ftPrint(LSANS_SMALL, X_MID, 120, 8, 600, 64, EXTRASTR) end
  DrawbarNbg(X_MID, Y_MID, 100, Color.new(0xff, 0xff, 0xff, 0x30))
  DrawbarNbg(X_MID, Y_MID, ((prog * 100) / total), Color.new(0xff, 0xff, 0xff, 0x80))
  Screen.flip()
end

function ReportProgressFadeEnd()
  local Z = 0x80
  while Z > 0 do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    DrawbarNbg(X_MID, Y_MID, 100, Color.new(0xff, 0xff, 0xff, Z))
    Screen.flip()
    Z = Z-2
  end
end

function WriteDataToHDD()
  System.log("Starting file transfer to HDD\n")
  Screen.clear()
  Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
  Screen.flip()
  local mountpath
  local current_mount = "NONE"
  local total = 3 + #HDD_INST_TABLE.source
  local pfs_path
  local pfs_mkdir
  ReportProgress(1, total, LNG_HDD_INSTOPT3)
  HDD.EnableHDDBoot()
  ReportProgress(2, total, "hdd0:__mbr:MBR.KELF")
  local ret = HDD.InstallBootstrap(SYSUPDATE_HDD_BOOTSTRAP)
  if ret < 0 then
    return ret
  end
  for i = 1, #HDD_INST_TABLE.source do
    ReportProgress(3+i, total, HDD_INST_TABLE.target[i])
    mountpath, _, pfs_path = GetMountData(HDD_INST_TABLE.target[i]) -- calculate needed paths
    if mountpath ~= current_mount then --different partition...
      System.log("partition change needed '"..mountpath.."'\n")
      ReportProgress(3+i, total, "MNT: "..mountpath)
      if HDD.MountPartition(mountpath, 0, FIO_MT_RDWR) < 0 then -- ...mount needed one
        System.log("### ERROR Mounting partition"..mountpath.."\n")
        return -5
      else --success
        current_mount = mountpath
        for x = 1, #HDD_INST_TABLE.dirs do
          if string.sub(HDD_INST_TABLE.dirs[x], 1, #current_mount) == current_mount then -- check if the target path correspondes to the specified partition...
            _ , _, pfs_mkdir = GetMountData(HDD_INST_TABLE.dirs[x])
            if not System.doesDirExist(pfs_mkdir) then System.createDirectory(pfs_mkdir) end
          end
        end
      end
    end
    ret = System.copyFile(HDD_INST_TABLE.source[i], pfs_path)
    if ret < 0 then
      return ret
    end
  end
  HDD.UMountPartition(0)
  ReportProgressFadeEnd()
  return 1
end

function PerformHDDInst()
  Screen.clear()
  Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
  Font.ftPrint(LSANS, X_MID, 40, 8, 600, 64, LNG_CALCULATING)
  Screen.flip()
  local MBR_SIZE = GetFileSizeX(SYSUPDATE_HDD_BOOTSTRAP)
  if MBR_SIZE > 883200 then
    System.log("### MBR.KELF size out of bounds: "..MBR_SIZE.."\n")
    Secrerr(-202)
    return
  end
  local __sysconf_freespace = HDD.GetPartitionSize("hdd0:__sysconf")
  local __sysconf_reqspace = HDDCalculateRequiredSpace(HDD_INST_TABLE, "hdd0:__sysconf")
  System.log("> Space needed for __sysconf is "..__sysconf_reqspace.."\n")
  if __sysconf_reqspace > __sysconf_freespace then InsufficientSpace(__sysconf_reqspace, __sysconf_freespace, LNG_PARTITION.." __sysconf") return end

  local __system_freespace  = HDD.GetPartitionSize("hdd0:__system")
  local __system_reqspace  = HDDCalculateRequiredSpace(HDD_INST_TABLE, "hdd0:__system")
  System.log("> Space needed for __system is "..__system_reqspace.."\n")
  if __system_reqspace > __system_freespace then InsufficientSpace(__system_reqspace, __system_freespace, LNG_PARTITION.." __system") return end

  local __common_freespace  = HDD.GetPartitionSize("hdd0:__common")
  local __common_reqspace  = HDDCalculateRequiredSpace(HDD_INST_TABLE, "hdd0:__common")
  System.log("> Space needed for __common is "..__common_reqspace.."\n")
  if __common_reqspace > __common_freespace then InsufficientSpace(__common_reqspace, __common_freespace, LNG_PARTITION.." __common") return end
  System.sleep(1)
  System.AllowPowerOffButton(0)
  Secrerr(WriteDataToHDD())
  System.AllowPowerOffButton(1)
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
    Font.ftPrint(LSANS, X_MID, 40, 8, 630, 16, LNG_WANNAQUIT)
    Promptkeys(1, LNG_YES, 1, LNG_NO, 1, LNG_RWLE, 0)
    ORBMAN(0x80 - Q)
    local pad = Pads.get()
    if Pads.check(pad, PAD_CROSS) then KELFBinder.DeinitLOG() System.exitToBrowser() end
    if Pads.check(pad, PAD_CIRCLE) then break end
    if Pads.check(pad, PAD_TRIANGLE) then
      if doesFileExist("INSTALL/CORE/BACKDOOR.ELF") then
        KELFBinder.DeinitLOG()
        System.loadELF(System.getbootpath() .. "INSTALL/CORE/BACKDOOR.ELF")
      else
        System.log("BACKDOOR ELF NOT ACCESIBLE\n")
      end
    end
    Screen.flip()
  end
end

function SystemInfo()
  local D = 15
  local A = 0x50
  local UPDTPATH
  local COL = 0
  if REAL_IS_PSX then
    UPDTPATH = "BIEXEC-SYSTEM/xosdmain.elf"
  else
    UPDTPATH = KELFBinder.calculateSysUpdatePath()
  end
  local ROMPATCH_PATH = KELFBinder.calculateSysUpdateROMPatch()
  if ROMVERN < 150 then ROMPATCH_PATH = LNG_UNSUPPORTED end

  local SUPPORTS_HDD_UPDATES
  if ROMVERN > 200 then SUPPORTS_HDD_UPDATES = LNG_NO
  elseif KELFBinder.DoesConsoleNeedHDDLOAD() then SUPPORTS_HDD_UPDATES = string.format(LNG_YES.." (%s)", LNG_HDD_NEEDS_HDDLOAD) else SUPPORTS_HDD_UPDATES = LNG_YES end

  local COMPATIBLE_WITH_UPDATES = LNG_NO
  if SUPPORTS_UPDATES then COMPATIBLE_WITH_UPDATES = LNG_YES end
  if HDD_STATUS == 0 or HDD_STATUS == 1 or HDD_STATUS == 3 then COL = 220 end
  while true do
    Screen.clear()
    Graphics.drawScaleImage(BG, 0.0, 0.0, SCR_X, SCR_Y)
    ORBMAN(0x80)
    Font.ftPrint(LSANS, X_MID, 30, 8, 630, 32, LNG_SYSTEMINFO, Color.new(220, 220, 220, 0x80 - A))

    Font.ftPrint(LSANS, 50, 60, 0, 630, 32, string.format("ROMVER = [%s]", ROMVER), Color.new(220, 220, 220, 0x80 - A))
    Font.ftPrint(LSANS, 50, 80, 0, 630, 32, string.format(LNG_CONSOLE_MODEL, KELFBinder.getConsoleModel()),
      Color.new(220, 220, 220, 0x80 - A))
    Font.ftPrint(LSANS, 50, 100, 0, 630, 32, string.format(LNG_IS_COMPATIBLE, COMPATIBLE_WITH_UPDATES),
      Color.new(220, 220, 220, 0x80 - A))
    if SUPPORTS_UPDATES then
      Font.ftPrint(LSANS, 50, 120, 0, 630, 32, string.format(LNG_SUPATH, UPDTPATH), Color.new(220, 220, 220, 0x80 - A))
      Font.ftPrint(LSANS, 50, 140, 0, 630, 32, string.format(LNG_ROMPATCH_PATCH, ROMPATCH_PATH), Color.new(220, 220, 220, 0x80 - A))
    end
    Font.ftPrint(LSANS, 50, 160, 0, 630, 32, LNG_HDD_STAT..STR_HDD_USABLE, Color.new(220, 220, COL, 0x80 - A))
    Font.ftPrint(LSANS, 50, 180, 0, 630, 32, LNG_HDD_UPDATES_SUPPORT.." "..SUPPORTS_HDD_UPDATES, Color.new(220, 220, 220, 0x80 - A))

    Promptkeys(0, LNG_CT0, 1, LNG_CT4, 0, 0, A)
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
    Graphics.drawRect(0, 190, SCR_X, 2, Color.new(255, 255, 255, Q))
    Font.ftPrint(LSANS, X_MID, 200, 8, 630, 16, LNG_CRDTS0, Color.new(200, 200, 200, Q))
    Font.ftPrint(LSANS, X_MID, 220, 8, 630, 16, LNG_CRDTS1, Color.new(200, 200, 200, Q))
    Font.ftPrint(LSANS, X_MID, 240, 8, 630, 16, LNG_CRDTS2, Color.new(200, 200, 200, Q))
    Font.ftPrint(LSANS, X_MID, 260, 8, 630, 16, LNG_CRDTS3, Color.new(200, 200, 200, Q))
    Graphics.drawRect(0, 290, SCR_X, 2, Color.new(255, 255, 255, Q))
    Font.ftPrint(LSANS, X_MID, 300, 8, 630, 16, LNG_CRDTS5, Color.new(200, 200, 200, Q))
    Font.ftPrint(LSANS, X_MID, 320, 8, 630, 16, "krHACKen, uyjulian, HWNJ", Color.new(200, 200, 200, Q))
    Font.ftPrint(LSANS, X_MID, 340, 8, 630, 16, "sp193, Leo Oliveira", Color.new(200, 200, 200, Q))
    Graphics.drawRect(0, 370, SCR_X, 2, Color.new(255, 255, 255, Q))
    Font.ftPrint(LSANS, X_MID, 380, 8, 630, 16, LNG_CRDTS4, Color.new(240, 240, 10, Q))
    Font.ftPrint(LSANS, X_MID, 400, 8, 630, 16, LNG_DOCSLINK, Color.new(240, 240, 10, Q))
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
  Drawbar(X_MID, Y_MID, 100, Color.new(255, 255, 255, NEIN))
  NEIN = NEIN-2
end
Greeting()
if SUPPORTS_UPDATES == false then
  WarnIncompatibleMachine()
end
if KELFBinder.getsystemtype() == 2 then
  Report(400, false, false)
end
if KELFBinder.GetIRXInfoByName("secrman_special") == nil then--no secrman special?
  RPC_STATUS = -10
  if KELFBinder.GetIRXInfoByName("secrman_for_cex") ~= nil then--check if retail secrman is there
    RPC_STATUS = -20
  end
  if KELFBinder.GetIRXInfoByName("secrman_nomecha") ~= nil then--check if retail secrman is there
    RPC_STATUS = 0
  end
end
if RPC_STATUS ~= 0 then
  Report(666, false, false)
end

if HDD_STATUS == 0 or HDD_STATUS == 1 then
  if HDD.GetSMARTStatus() ~= 0 then
    Report(300, false, false)
  elseif HDD.CheckSectorError() ~= 0 then
    Report(301, false, false)
  elseif HDD.CheckDamagedPartition() ~= 0 and HDD_STATUS == 0 then --only check damaged partitions on formatted HDD
    Report(302, false, false)
  end
end

OrbIntro(0)
while true do
  local TT = MainMenu()
  WaitWithORBS(50)
  if (TT == 1 and RPC_STATUS == 0) then -- SYSTEM UPDATE
    local TTT = Installmodepicker()
    WaitWithORBS(50)
    if TTT == 1 then -- NORMAL INST
      local port = MemcardPickup()
      if port ~= -1 then
        FadeWIthORBS(false)
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
          FadeWIthORBS(false)
          if UPDT[10] == 1 then -- IF PSX mode was selected
            IS_PSX = true -- simulate runner console is a PSX to reduce code duplication
            NormalInstall(port, 0)
            IS_PSX = false
          else
            PerformExpertINST(port, 0, UPDT)
          end
        end
      end
    elseif TTT == 3 then -- EXPERT INST
      local port = MemcardPickup()
      if port ~= -1 then
        FadeWIthORBS(true)
        local UPDT = ExpertINSTprompt()
        if UPDT["x"] == true then
          PerformExpertINST(port, 0, UPDT)
        else OrbIntro(0) end
      end
    elseif TTT == 4 then -- MAGICGATE TEST
      local port = MemcardPickup()
      if port ~= -1 then
        FadeWIthORBS(false)
        MagicGateTest(port, 0)
        WaitWithORBS(50)
      end
    end
  elseif TT == 2 and (not REAL_IS_PSX) then -- HDD
    local ACT = HDDMAN()
    if (ACT == 1) then
      PerformHDDInst()
    elseif (ACT == 2) then
      local continue = Report(200, false, true)
      if continue then System.log("\n> User asked to format HDD...\n\n") end
      Eval_HDDStatus() --check again!
      OrbIntro(1)
    elseif (ACT == 3) then
      FadeWIthORBS(true)
      local ret = HDD.EnableHDDBoot()
      ret = 100 + ret
      Report(ret, true, false)
      OrbIntro(1)
    end
  elseif TT == 3 and RPC_STATUS == 0 then -- DVDPLAYER
    local port = MemcardPickup()
    WaitWithORBS(20)
    if (port >= 0) then
      local target_region = DVDPlayerRegionPicker()
      if (target_region >= 0) then
        FadeWIthORBS(false)
        DVDPlayerINST(port, 0, target_region)
      end
    end
  elseif TT == 4 then
    SystemInfo()
  elseif TT == 5 then
    Credits()
  elseif TT == 6 then
    Ask2quit()
  end
  -- SYSTEM UPDATE
end
Screen.clear(Color.new(0xff, 0, 0, 0))
while true do end
