

local shadowed  = 0
local AlarmTrigger = 90

local options = {
  { "Sensor", SOURCE, 1 },
  { "Color", COLOR, WHITE },
  { "NbrCells", VALUE, 1, 1, 6 },
  { "Shadow", BOOL, 0 }
}

-- This function is runned once at the creation of the widget
local function create(zone, options)
  local myZone  = { zone=zone, options=options, counter=0 }
  histCellData = {}
  return myZone
end

-- This function allow updates when you change widgets settings
local function update(myZone, options)
  myZone.options = options
end

-- A quick and dirty check for empty table
local function isEmpty(self)
  for _, _ in pairs(self) do
    return false
  end
  return true
end

--- This function return the percentage remaining in a single Lipo cel
local function getCellPercent(cellValue)
  --## Data gathered from commercial lipo sensors
  local myArrayPercentList =
  {{3, 0}, {3.093, 1}, {3.196, 2}, {3.301, 3}, {3.401, 4}, {3.477, 5}, {3.544, 6}, {3.601, 7}, {3.637, 8}, {3.664, 9}, {3.679, 10}, 
  {3.683, 11}, {3.689, 12}, {3.692, 13}, {3.705, 14}, {3.71, 15}, {3.713, 16}, {3.715, 17}, {3.72, 18}, {3.731, 19}, {3.735, 20},
  {3.744, 21}, {3.753, 22}, {3.756, 23}, {3.758, 24}, {3.762, 25}, {3.767, 26}, {3.774, 27}, {3.78, 28}, {3.783, 29}, {3.786, 30},
  {3.789, 31}, {3.794, 32}, {3.797, 33}, {3.8, 34}, {3.802, 35}, {3.805, 36}, {3.808, 37}, {3.811, 38}, {3.815, 39}, {3.818, 40},
  {3.822, 41}, {3.825, 42}, {3.829, 43}, {3.833, 44}, {3.836, 45}, {3.84, 46}, {3.843, 47}, {3.847, 48}, {3.85, 49}, {3.854, 50},
  {3.857, 51}, {3.86, 52}, {3.863, 53}, {3.866, 54}, {3.87, 55}, {3.874, 56}, {3.879, 57}, {3.888, 58}, {3.893, 59}, {3.897, 60},
  {3.902, 61}, {3.906, 62}, {3.911, 63}, {3.918, 64}, {3.923, 65}, {3.928, 66}, {3.939, 67}, {3.943, 68}, {3.949, 69}, {3.955, 70},
  {3.961, 71}, {3.968, 72}, {3.974, 73}, {3.981, 74}, {3.987, 75}, {3.994, 76}, {4.001, 77}, {4.007, 78}, {4.014, 79}, {4.021, 80},
  {4.029, 81}, {4.036, 82}, {4.044, 83}, {4.052, 84}, {4.062, 85}, {4.074, 86}, {4.085, 87}, {4.095, 88}, {4.105, 89}, {4.111, 90},
  {4.116, 91}, {4.12, 92}, {4.125, 93}, {4.129, 94}, {4.135, 95}, {4.145, 96}, {4.176, 97}, {4.179, 98}, {4.193, 99}, {4.2, 100}}

  for i, v in ipairs( myArrayPercentList ) do
    if v[ 1 ] >= cellValue then
      result =  v[ 2 ]
      break
     end
  end
  return result
end

-- This function returns green at 100%, red bellow 30% and graduate in betwwen
local function getPercentColor(cpercent)
  if cpercent < 30 then
    return lcd.RGB(0xff, 0, 0)
  else
    g = math.floor(0xdf * cpercent / 100)
    r = 0xdf - g
    return lcd.RGB(r, g, 0)
  end
end

local function AlarmTriggerfct(value)

    if value == 0 then
        return
    else

        if value < AlarmTrigger then
            playNumber(value, 13, 0)
            value = value - 0,1
            AlarmTrigger = math.floor(value/10)*10-- aroundir à la décimal inférieur
        end
        AlarmTrigger = math.floor(value/10)*10-- aroundir à la décimal inférieur
    end
    if value < 30 then-- Play sound alarm if level is under 30%
        playFile("attero.wav")
   -- 	playFile("batcrit.wav")
    end
    return
end

-- This function returns green at gvalue, red at rvalue and graduate in betwwen
local function getRangeColor(value, gvalue, rvalue)
  if gvalue > rvalue and not range==0 then
    range = gvalue - rvalue
    if value > gvalue then return lcd.RGB(0, 0xdf, 0) end
    if value < rvalue then return lcd.RGB(0xdf, 0, 0) end
    g = math.floor(0xdf * (value-rvalue) / range)
    r = 0xdf - g
    return lcd.RGB(r, g, 0)
  else
    range = rvalue - gvalue
    if value > gvalue then return lcd.RGB(0, 0xdf, 0) end
    if value < rvalue then return lcd.RGB(0xdf, 0, 0) end
    r = math.floor(0xdf * (value-gvalue) / range)
    g = 0xdf - r
    return lcd.RGB(r, g, 0)
  end
end

-- This size is for top bar widgets
--local function zoneTiny(zone)
--  local mySensor = getCels(zone.options.Sensor)
--  if type(mySensor) == "table" then
--    local myString = string.format("%2.1fV", getCellSum(mySensor))
--    local percent = getCellPercent(getCellAvg(mySensor))
--    lcd.drawText(zone.zone.x + zone.zone.w, zone.zone.y, percent.."%", RIGHT + SMLSIZE + CUSTOM_COLOR)
--    lcd.drawText(zone.zone.x + zone.zone.w, zone.zone.y + 15, myString, RIGHT + SMLSIZE + CUSTOM_COLOR)
    -- draw batt
--    lcd.drawRectangle(zone.zone.x, zone.zone.y + 6, 16, 25, CUSTOM_COLOR, 2)
--    lcd.drawFilledRectangle(zone.zone.x + 4, zone.zone.y + 4, 6, 3, CUSTOM_COLOR)
--    local rect_h = math.floor(25 * percent / 100)
--    lcd.drawFilledRectangle(zone.zone.x, zone.zone.y + 6 + 25 - rect_h , 16, rect_h, CUSTOM_COLOR)
--   end
--end

--- Size is 160x30 1/8th
local function zoneSmall(zone)
  local myBatt = {["x"]=0, ["y"]=0, ["w"]=75, ["h"]=28, ["segments_w"]=15, ["color"]=WHITE, ["cath_w"]=6, ["cath_h"]=20}
  local mySensor = getValue(zone.options.Sensor)

  lcd.setColor(CUSTOM_COLOR, zone.options.Color)
  --  if type(mySensor) == "table" then
        local percent = getCellPercent(mySensor/zone.options.NbrCells)
        AlarmTriggerfct(percent)

        lcd.drawText(zone.zone.x + zone.zone.w, zone.zone.y, string.format("%2.1fV",mySensor), RIGHT + MIDSIZE + CUSTOM_COLOR + shadowed)
        lcd.drawText(zone.zone.x + zone.zone.w, zone.zone.y + 20, percent.."%", RIGHT + MIDSIZE + CUSTOM_COLOR + shadowed)
        lcd.drawText(zone.zone.x + zone.zone.w, zone.zone.y + 40, "Next Alarm: "..AlarmTrigger.."%", RIGHT + MIDSIZE + CUSTOM_COLOR + shadowed)
    -- fils batt
        lcd.setColor(CUSTOM_COLOR, getPercentColor(percent))
        lcd.drawGauge(zone.zone.x+2, zone.zone.y+2, myBatt.w -4, myBatt.h - 4, percent, 100, CUSTOM_COLOR)
    -- draws bat
        lcd.setColor(CUSTOM_COLOR, WHITE)
        lcd.drawRectangle(zone.zone.x + myBatt.x, zone.zone.y + myBatt.y, myBatt.w, myBatt.h, CUSTOM_COLOR, 2)
        lcd.drawFilledRectangle(zone.zone.x + myBatt.x + myBatt.w, zone.zone.y + myBatt.h/2 - myBatt.cath_h/2, myBatt.cath_w, myBatt.cath_h, CUSTOM_COLOR)
        for i=1, myBatt.w - myBatt.segments_w, myBatt.segments_w do
            lcd.drawRectangle(zone.zone.x + myBatt.x + i, zone.zone.y + myBatt.y, myBatt.segments_w, myBatt.h, CUSTOM_COLOR, 1)
        end
    --  else
    --        lcd.drawText(zone.zone.x+5, zone.zone.y, "No sensor data", LEFT + SMLSIZE + INVERS + CUSTOM_COLOR)
    --  end
  return
end

-- This function allow recording of lowest cells when widget is not active
local function background(myZone)
    local mySensor = getValue(myZone.options.Sensor)
    local percent=getCellPercent(mySensor/myZone.options.NbrCells)
    AlarmTriggerfct(percent)

  return
end

function refresh(myZone)
  --Refresh graphical
    zoneSmall(myZone)   
end

return { name="BattCapa", options=options, create=create, update=update, background=background, refresh=refresh }
