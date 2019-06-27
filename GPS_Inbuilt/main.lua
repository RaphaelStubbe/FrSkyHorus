
local options = {
}

local function create(zone, options)
  local pie = { zone=zone, options=options, counter=0 }
  print(options.Option2)
  return pie
end

local function update(pie, options)
  pie.options = options
end

local function background(pie)

end

function refresh(pie)
  GPSTable = getTxGPS()
  lcd.drawNumber(pie.zone.x, pie.zone.y, GPSTable.numsat, LEFT + TEXT_COLOR + SHADOWED);
  if (GPSTable.fix==true) then
	lcd.drawText(pie.zone.x, pie.zone.y+15, string.format("%f",GPSTable.lat), LEFT + TEXT_COLOR + SHADOWED);
    lcd.drawText(pie.zone.x, pie.zone.y+30, string.format("%f",GPSTable.lon), LEFT + TEXT_COLOR + SHADOWED);
  end
end

return { name="GPSIn", options=options, create=create, update=update, refresh=refresh, background=background }
