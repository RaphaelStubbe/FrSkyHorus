
local options = {
    { "COLOR", COLOR, RED },
    { "Hook", SOURCE, 1 },
}

local function create(zone, options)
    local vDistance = 0
    local vRadius = 6367000

    local MyZone = { zone=zone, options=options,vDistance=vDistance,vRadius=vRadius, counter=0 }

    lcd.setColor( CUSTOM_COLOR, options.COLOR )
  --create array containing all sensor ID's used for quicker retrieval
    local ID = {}
        ID.GPS = getFieldInfo("GPS") and getFieldInfo("GPS").id	or -1
        ID.Hdg = getFieldInfo("Hdg") and getFieldInfo("Hdg").id or -1
        ID.GSpd = getFieldInfo("GSpd") and getFieldInfo("GSpd").id or -1
        ID.GAlt = getFieldInfo("GAlt") and getFieldInfo("GAlt").id or -1

  --add ID to thisWidget (MyZone)
    MyZone.ID = ID

    return MyZone
end

-- widget update function is called upon registration and at change of settings in the telemetry setup menu
local function update(MyZone, options)
    MyZone.options = options
    lcd.setColor( CUSTOM_COLOR, options.COLOR )
end

-- widget background function is periodically called when custom telemetry screen is not visible
local function background(MyZone)

    MyZone.gpsLatLong = getValue(MyZone.ID.GPS)
    if  (type(MyZone.gpsLatLong) ~= "table") then
        MyZone.ID.GPS = getFieldInfo("GPS") and getFieldInfo("GPS").id	or -1
        MyZone.ID.Hdg = getFieldInfo("Hdg") and getFieldInfo("Hdg").id or -1
        MyZone.ID.GSpd = getFieldInfo("GSpd") and getFieldInfo("GSpd").id or -1
        MyZone.ID.GAlt = getFieldInfo("GAlt") and getFieldInfo("GAlt").id or -1
        return
    end


    MyZone.headingDeg= getValue(MyZone.ID.Hdg)  
    MyZone.gpsLat = MyZone.gpsLatLong.lat
    MyZone.gpsLong = MyZone.gpsLatLong.lon
    MyZone.gpsSat = MyZone.gpsLatLong.numsat
    MyZone.gpsAlt = getValue(MyZone.ID.GAlt)
end


-- widget refresh function is periodically called when custom telemetry screen is visible
function refresh(MyZone)

    -- If no GPS data, set variable to 0 to avoid scripting error during lcd.drawtext
    if  (type(MyZone.gpsLatLong) ~= "table") then

        MyZone.headingDeg = 0
        MyZone.gpsLat = 0
        MyZone.gpsLong = 0
        MyZone.gpsSat = 0
        MyZone.gpsAlt = 0

    end

  GPSTable = getTxGPS()

  lcd.drawText(MyZone.zone.x, MyZone.zone.y, "Inbuilt GPS: ", CUSTOM_COLOR);
  lcd.drawText(MyZone.zone.x, MyZone.zone.y+15, "Sat: ", CUSTOM_COLOR);
  lcd.drawNumber(MyZone.zone.x+40, MyZone.zone.y+15, GPSTable.numsat, CUSTOM_COLOR);

  if (GPSTable.fix==true) then
    lcd.drawText(MyZone.zone.x, MyZone.zone.y+30, string.format("%f",GPSTable.lat), CUSTOM_COLOR);
    lcd.drawText(MyZone.zone.x, MyZone.zone.y+45, string.format("%f",GPSTable.lon), CUSTOM_COLOR);

    local radian = math.pi / 180
    local deltaLatitude = math.sin(radian * (GPSTable.lat - MyZone.gpsLat) /2)
    local deltaLongitude = math.sin(radian * (GPSTable.lon - MyZone.gpsLong) / 2)

    local circleDistance = 2 * math.asin(math.min(1, math.sqrt(deltaLatitude * deltaLatitude + math.cos(radian * GPSTable.lat) * math.cos(radian * MyZone.gpsLat) * deltaLongitude * deltaLongitude)))
    vDistance = math.abs(6367000 * circleDistance)
    
    lcd.drawText(MyZone.zone.x, MyZone.zone.y+105, "Distance: ", CUSTOM_COLOR);
    lcd.drawText(MyZone.zone.x+100, MyZone.zone.y+105, string.format("%f",vDistance), CUSTOM_COLOR);

  end

    lcd.drawText(MyZone.zone.x, MyZone.zone.y+60, "Sat: ",CUSTOM_COLOR);
--  lcd.drawText(MyZone.zone.x+40, MyZone.zone.y+60, string.format("%f",MyZone.gpsSat), CUSTOM_COLOR);
    lcd.drawText(MyZone.zone.x, MyZone.zone.y+75, string.format("%f",MyZone.gpsLat), CUSTOM_COLOR);
    lcd.drawText(MyZone.zone.x, MyZone.zone.y+90, string.format("%f",MyZone.gpsLong), CUSTOM_COLOR);


end

return { name="GPSDist", options=options, create=create, update=update, refresh=refresh, background=background }
