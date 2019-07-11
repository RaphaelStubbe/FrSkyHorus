

local options = {
  { "COLOR", COLOR, RED },
  { "Hook", SOURCE, 1 },
}


-- in the create function you add all shared variables to the array containing the widget data ('thisWidget')
local function create(zone, options)
  local thisWidget  = { zone=zone, options=options}
  lcd.setColor( CUSTOM_COLOR, options.COLOR )
  --create array containing all sensor ID's used for quicker retrieval
  local ID = {}
  ID.GPS = getFieldInfo("GPS") and getFieldInfo("GPS").id	or 0
  ID.Hdg = getFieldInfo("Hdg") and getFieldInfo("Hdg").id or 0
  ID.GSpd = getFieldInfo("GSpd") and getFieldInfo("GSpd").id or 0
  
  --add ID to thisWidget
  thisWidget.ID = ID	

  --create array containing all map info per map size
  local map = {North={},South={},West={},East={},wx={},wy={},zx={},zy={},Pxa={},Pya={},Pxb={},Pyb={},Pxc={},Pyc={},Pxd={},Pyd={}}
	local noflightzone = {long={},lat={}}	
  -- coordinates for the small map.
  map.North.small = 50.666512
  map.South.small = 50.664198
  map.West.small = 4.071801
  map.East.small = 4.079747
  map.wx.small = 320
  map.wy.small = 0
  map.zx.small = 479
  map.zy.small = 210
  map.Pxa.small = 0 
  map.Pya.small = 0
  map.Pxb.small = 0
  map.Pyb.small = 0
  map.Pxc.small = 0
  map.Pyc.small = 0
  map.Pxd.small = 0
  map.Pyd.small = 0
  
  -- coordinates for the medium map.
  map.North.medium = 50.667429
  map.South.medium = 50.663318
  map.West.medium = 4.070252
  map.East.medium = 4.082528
  map.wx.medium = 246
  map.wy.medium = 0
  map.zx.medium = 443
  map.zy.medium = 271

  --coordinates for the largest map. 
  map.North.large = 50.668111
  map.South.large = 50.663844
  map.West.large = 4.069325
  map.East.large = 4.081888
  map.wx.large = 197
  map.wy.large = 0
  map.zx.large = 410
  map.zy.large = 271
    
  -- coordinates for noflightzone
  noflightzone.lat.a=50.665616
  noflightzone.long.a=4.074794
  noflightzone.lat.b=50.666045
  noflightzone.long.b=4.076014
  noflightzone.lat.c=50.665087
  noflightzone.long.c=4.075309
  noflightzone.lat.d=50.665009
  noflightzone.long.d=4.077108

  --add one bitmap per map size and set current map size
  map.bmp={}
  map.bmp.small = Bitmap.open("/Widgets/GPS/map.png")
  map.bmp.medium = Bitmap.open("/Widgets/GPS/map1.png")
  map.bmp.large = Bitmap.open("/Widgets/GPS/map2.png")
  
  --set current size
  map.current = "large"

  --add the map array to thisWidget
  thisWidget.map = map
  thisWidget.noflightzone = noflightzone	
  
  --return the thisWidget array to the opentx API, containing all data to be shared across functions
  return thisWidget
end

local function background(thisWidget)
  
  thisWidget.gpsLatLong = getValue(thisWidget.ID.GPS)
  if  (type(thisWidget.gpsLatLong) ~= "table") then
    thisWidget.ID.GPS = getFieldInfo("GPS") and getFieldInfo("GPS").id	or 0
    thisWidget.ID.Hdg = getFieldInfo("Hdg") and getFieldInfo("Hdg").id or 0
    thisWidget.ID.GSpd = getFieldInfo("GSpd") and getFieldInfo("GSpd").id or 0
    model.setGlobalVariable(8,0,0)
    return
  end
  
  thisWidget.headingDeg= getValue(thisWidget.ID.Hdg)  
  thisWidget.gpsLat = thisWidget.gpsLatLong.lat
  thisWidget.gpsLong = thisWidget.gpsLatLong.lon
--  thisWidget.gpsSat = thisWidget.gpsLatLong.numsat
  
-- Part for loading the correct zoomlevel of the map

-- coordinates for the smallest map. These can be found by placing the image back into Google Earth and looking at the overlay
-- parameters

  local North = thisWidget.map.North
  local South = thisWidget.map.South
  local East = thisWidget.map.East
  local West = thisWidget.map.West
    
 -- if thisWidget.gpsLat < North.small and thisWidget.gpsLat > South.small and thisWidget.gpsLong < East.small and thisWidget.gpsLong > West.small then    
--    thisWidget.map.current = "small"
--  elseif thisWidget.gpsLat < North.medium and thisWidget.gpsLat > South.medium and thisWidget.gpsLong < East.medium and thisWidget.gpsLong > West.medium then    
--    thisWidget.map.current = "medium"
--  else    
    thisWidget.map.current = "large"
--  end

-- Part for setting the correct zoomlevel ends here.

-- Calculate Position in relation to map. 

  North = North[thisWidget.map.current]
  South = South[thisWidget.map.current]
  East = East[thisWidget.map.current]
  West = West[thisWidget.map.current]
  local wx = thisWidget.map.wx[thisWidget.map.current]
  local wy = thisWidget.map.wy[thisWidget.map.current]
  local zx = thisWidget.map.zx[thisWidget.map.current]
  local zy = thisWidget.map.zy[thisWidget.map.current]
  Pxa = thisWidget.map.Pxa[thisWidget.map.current]
  Pya = thisWidget.map.Pya[thisWidget.map.current]
  Pxb = thisWidget.map.Pxb[thisWidget.map.current]
  Pyb = thisWidget.map.Pyb[thisWidget.map.current]
  Pxc = thisWidget.map.Pxc[thisWidget.map.current]
  Pyc = thisWidget.map.Pyc[thisWidget.map.current]
  Pxd = thisWidget.map.Pxd[thisWidget.map.current]
  Pyd = thisWidget.map.Pyd[thisWidget.map.current]



  --model coordonate related to the map size
  thisWidget.x = math.floor(480*((thisWidget.gpsLong - West)/(East - West)))
  thisWidget.y = math.floor(272*((North - thisWidget.gpsLat)/(North - South)))

  --No fliyng zone Point polygone
  Pxa = math.floor(480*((thisWidget.noflightzone.long.a - West)/(East - West)))
  Pya = math.floor(272*((North - thisWidget.noflightzone.lat.a)/(North - South)))
  Pxb = math.floor(480*((thisWidget.noflightzone.long.b - West)/(East - West)))
  Pyb = math.floor(272*((North - thisWidget.noflightzone.lat.b)/(North - South)))
  Pxc = math.floor(480*((thisWidget.noflightzone.long.c - West)/(East - West)))
  Pyc = math.floor(272*((North - thisWidget.noflightzone.lat.c)/(North - South)))
  Pxd = math.floor(480*((thisWidget.noflightzone.long.d - West)/(East - West)))
  Pyd = math.floor(272*((North - thisWidget.noflightzone.lat.d)/(North - South)))


  --Check the max and min for bording edge
  thisWidget.x = math.max(10,thisWidget.x)
  thisWidget.x = math.min(thisWidget.x,470)

  thisWidget.y = math.max(10,thisWidget.y)
  thisWidget.y = math.min(thisWidget.y,262)

  --Calculate the distance between thiswidget.x, Y and each corner of the no flying zone
  Distab = (math.sqrt( (Pxa - Pxb)^2 +(Pya - Pyb)^2))
  Distac = (math.sqrt( (Pxa - Pxc)^2 +(Pya - Pyc)^2))
  Distbd = (math.sqrt( (Pxb - Pxd)^2 +(Pyb - Pyd)^2))
  Distcd = (math.sqrt( (Pxc - Pxd)^2 +(Pyc - Pyd)^2))

  DistPa = (math.sqrt( (thisWidget.x - Pxa)^2 +(thisWidget.y - Pya)^2))
  DistPb = (math.sqrt( (thisWidget.x - Pxb)^2 +(thisWidget.y - Pyb)^2))
  DistPc = (math.sqrt( (thisWidget.x - Pxc)^2 +(thisWidget.y - Pyc)^2))
  DistPd = (math.sqrt( (thisWidget.x - Pxd)^2 +(thisWidget.y - Pyd)^2))
-- Check if distance = 0 then Thiswidget.x, y is on the point it self


-- else check if thewidget.x, y is in the noflyingzone (only for convex noflyingzone coordonate)
-- CosA = a² - b² - c² / -2bc

AlphaPab = math.deg(math.acos((Distab^2 - DistPa^2 - DistPb^2)/(-2 * DistPa * DistPb)))
AlphaPac = math.deg(math.acos((Distac^2 - DistPa^2 - DistPc^2)/(-2 * DistPa * DistPc)))
AlphaPbd = math.deg(math.acos((Distbd^2 - DistPb^2 - DistPd^2)/(-2 * DistPb * DistPd)))
AlphaPcd = math.deg(math.acos((Distcd^2 - DistPc^2 - DistPd^2)/(-2 * DistPc * DistPd)))

Alpha = AlphaPab + AlphaPac + AlphaPbd + AlphaPcd


  --if Alpha == 360 then
    -- In not flight area --> flying area not permite
   -- model.setGlobalVariable(8,0,1)
 --else 
    --Not in no flight area --> flying area permited
    --model.setGlobalVariable(8,0,0)
 --end

 -- switch position for hock, log the gps coordonates
--  switchpos = getValue('sd')
  --during value -1024 log
  if Alpha == 360 then
    model.setGlobalVariable(8,0,1)
    playTone(1000,1000,1000,PLAY_NOW)
  else
     model.setGlobalVariable(8,0,0)
  end
end

local function update(thisWidget, options)
  thisWidget.options = options
  lcd.setColor( CUSTOM_COLOR, thisWidget.options.COLOR )
end

local function refresh(thisWidget)
  background(thisWidget)

  if  (type(thisWidget.gpsLatLong) ~= "table") then
    lcd.drawBitmap(thisWidget.map.bmp.large, thisWidget.zone.x -10, thisWidget.zone.y -10)
    --lcd.setColor(CUSTOM_COLOR, lcd.RGB(255,0,0))
    lcd.drawText( 20, 130, "No GPS SIGNAL !!!", DBLSIZE, CUSTOM_COLOR)
    return
  end

  local xvalues = { }
  local yvalues = { }
  local headingDeg = thisWidget.headingDeg
  local x = thisWidget.x
  local y = thisWidget.y

--                     A
--                     |
--                     |
-- C  _________________|___________________  D
--                     |
--                     |
--                     |
--                     |
--                     |
--                     |
--                     |
--                E ---|--- F
--                     B


  xvalues.ax = x + (4 * math.sin(math.rad(headingDeg))) 							-- front of fuselage x position
  yvalues.ay = y - (4 * math.cos(math.rad(headingDeg))) 							-- front of fuselage y position
  xvalues.bx = x - (7 * math.sin(math.rad(headingDeg))) 							-- rear of fuselage x position
  yvalues.by = y + (7 * math.cos(math.rad(headingDeg))) 							-- rear of fuselage y position
  xvalues.cx = x + (10 * math.cos(math.rad(headingDeg))) 							-- left wingtip x position 
  yvalues.cy = y + (10 * math.sin(math.rad(headingDeg)))							-- left wingtip y position
  xvalues.dx = x - (10 * math.cos(math.rad(headingDeg)))							-- right wingtip x position
  yvalues.dy = y - (10 * math.sin(math.rad(headingDeg)))							-- right wingtip y position
  xvalues.ex = x - ((7 * math.sin(math.rad(headingDeg))) + (3 * math.cos(math.rad(headingDeg))))	-- left tailwing tip x position
  yvalues.ey = y + ((7 * math.cos(math.rad(headingDeg))) - (3 * math.sin(math.rad(headingDeg))))	-- left tailwing tip y position
  xvalues.fx = x - ((7 * math.sin(math.rad(headingDeg))) - (3 * math.cos(math.rad(headingDeg))))	-- right tailwing tip x position
  yvalues.fy = y + ((7 * math.cos(math.rad(headingDeg))) + (3 * math.sin(math.rad(headingDeg))))	-- right tailwing tip y position
  
  
--draw background  
  lcd.drawBitmap(thisWidget.map.bmp.large, thisWidget.zone.x -10, thisWidget.zone.y -10)

--draw info
  lcd.setColor( CUSTOM_COLOR, thisWidget.options.COLOR )
  lcd.drawText(10, 10, "GPS Model:", CUSTOM_COLOR)
  lcd.drawText(10, 40, "Lat: " , CUSTOM_COLOR)
  lcd.drawText(60, 40, thisWidget.gpsLat, CUSTOM_COLOR)
  lcd.drawText(10, 60, "Long: " , CUSTOM_COLOR)
  lcd.drawText(60, 60, thisWidget.gpsLong , CUSTOM_COLOR)
  lcd.drawText(10, 80, "Hdg: ", CUSTOM_COLOR)
  lcd.drawText(60, 80, math.floor(thisWidget.headingDeg) , CUSTOM_COLOR)

  local mm = model.getGlobalVariable(8,0)
  lcd.drawText(10, 100, "GB: " , CUSTOM_COLOR)
  lcd.drawText(60, 100, mm , CUSTOM_COLOR)

--  lcd.drawText(10, 120, "Sat: " , CUSTOM_COLOR)
--  lcd.drawText(60, 120, thisWidget.gpsSat , CUSTOM_COLOR) --Sum angle


--  lcd.drawText(10, 120, "Sum Alpha: " , CUSTOM_COLOR)
--  lcd.drawText(60, 120, Alpha , CUSTOM_COLOR) --Sum angle

--draw plane  
  lcd.setColor(CUSTOM_COLOR, lcd.RGB(255,255,255))
  lcd.drawLine(xvalues.ax , yvalues.ay , xvalues.bx , yvalues.by , SOLID, CUSTOM_COLOR)
  lcd.drawLine(xvalues.cx , yvalues.cy , xvalues.dx , yvalues.dy , SOLID, CUSTOM_COLOR)
  lcd.drawLine(xvalues.ex , yvalues.ey , xvalues.fx , yvalues.fy , SOLID, CUSTOM_COLOR)

--draw noflightzone
  lcd.setColor(CUSTOM_COLOR, lcd.RGB(255,0,0))

  lcd.drawLine(Pxa -10, Pya -10, Pxb -10, Pyb -10, SOLID, CUSTOM_COLOR)
  lcd.drawLine(Pxb -10, Pyb -10, Pxd -10, Pyd -10, SOLID, CUSTOM_COLOR)
  lcd.drawLine(Pxc -10, Pyc -10, Pxa -10, Pya -10, SOLID, CUSTOM_COLOR)
  lcd.drawLine(Pxd -10, Pyd -10, Pxc -10, Pyc -10, SOLID, CUSTOM_COLOR)

end
return { name="Map", options=options, create=create, update=update, background=background, refresh=refresh }
