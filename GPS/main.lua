

local options = {
  { "COLOR", COLOR, RED },
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
  local map = {North={},South={},West={},East={},wx={},wy={},zx={},zy={}}
		
  -- coordinates for the small map.
  map.North.small = 50.666512
  map.South.small = 50.664198
  map.West.small = 4.071801
  map.East.small = 4.079747
  map.wx.small = 320
  map.wy.small = 0
  map.zx.small = 479
  map.zy.small = 210

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
  map.North.large = 50.668695
  map.South.large = 50.661725
  map.West.large = 4.067960
  map.East.large = 4.084409
  map.wx.large = 197
  map.wy.large = 0
  map.zx.large = 410
  map.zy.large = 271
		
  --add one bitmap per map size and set current map size
  map.bmp={}
  map.bmp.small = Bitmap.open("/Widgets/GPS/map.png")
  map.bmp.medium = Bitmap.open("/Widgets/GPS/map1.png")
  map.bmp.large = Bitmap.open("/Widgets/GPS/map2.png")
  
  --set current size
  map.current = "large"

  --add the map array to thisWidget
  thisWidget.map = map	
  
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


  thisWidget.x = math.floor(480*((thisWidget.gpsLong - West)/(East - West)))
  thisWidget.y = math.floor(272*((North - thisWidget.gpsLat)/(North - South)))

  thisWidget.x=math.max(10,thisWidget.x)
  thisWidget.x=math.min(thisWidget.x,470)

  thisWidget.y=math.max(10,thisWidget.y)
  thisWidget.y=math.min(thisWidget.y,262)

  if ((thisWidget.x - wx)*(zy-wy))-((thisWidget.y - wy)*(zx-wx)) < 0 then
    model.setGlobalVariable(8,0,0)
  else 
    model.setGlobalVariable(8,0,1)
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
-- C   _________________|___________________  D
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
  lcd.drawBitmap(thisWidget.map.bmp.small, thisWidget.zone.x -10, thisWidget.zone.y -10)

--draw info
  lcd.setColor( CUSTOM_COLOR, thisWidget.options.COLOR )
  lcd.drawText(40, 40, thisWidget.gpsLat, CUSTOM_COLOR)
  -- lcd.setColor(CUSTOM_COLOR, WHITE)
  lcd.drawText(40, 60, thisWidget.gpsLong , CUSTOM_COLOR)
 --  lcd.setColor(CUSTOM_COLOR, BLUE)
  lcd.drawText(40, 80, math.floor(thisWidget.headingDeg) , CUSTOM_COLOR)
  lcd.drawText(40, 100, thisWidget.x , CUSTOM_COLOR)
  lcd.drawText(40, 120, thisWidget.y , CUSTOM_COLOR)
  
--draw plane  
  lcd.setColor(CUSTOM_COLOR, lcd.RGB(255,255,255))
  lcd.drawLine(xvalues.ax, yvalues.ay, xvalues.bx, yvalues.by, SOLID, CUSTOM_COLOR)
  lcd.drawLine(xvalues.cx, yvalues.cy, xvalues.dx, yvalues.dy, SOLID, CUSTOM_COLOR)
  lcd.drawLine(xvalues.ex, yvalues.ey, xvalues.fx, yvalues.fy, SOLID, CUSTOM_COLOR)

--draw noflightzone
  lcd.setColor(CUSTOM_COLOR, lcd.RGB(255,0,0))
  lcd.drawLine(thisWidget.map.wx[thisWidget.map.current], thisWidget.map.wy[thisWidget.map.current], thisWidget.map.zx[thisWidget.map.current], thisWidget.map.zy[thisWidget.map.current], SOLID, CUSTOM_COLOR)

end
return { name="Map", options=options, create=create, update=update, background=background, refresh=refresh }
