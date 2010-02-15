--[[

  Function to draw a gauge (health bar).
  
  You specify the starting point, width, and height.
  Also the name to show for the mouse-over window (eg. "HP).
  
  Author: Nick Gammon
  Date:   14 February 2010
  
  --]]

function gauge (win,     -- miniwindow to draw in
                name,    -- string, eg: "HP"
                current, max,               -- current and max value (eg. 50, 100)
                left, top, width, height,   -- where to put it inside the window
                fg_colour, bg_colour,       -- colour for bar, colour for unfilled part
                ticks, tick_colour,         -- number of ticks to draw, and in what colour
                frame_colour)               -- colour for frame around bar

  if max <= 0 then 
    return
  end -- no divide by zero
                
  -- set up some defaults
  height = height or 15
  fg_colour = fg_colour or ColourNameToRGB "mediumblue"
  bg_colour = bg_colour or ColourNameToRGB "rosybrown"
  ticks = ticks or 5
  tick_colour = tick_colour or ColourNameToRGB "silver"
  frame_colour = frame_colour or ColourNameToRGB "lightgrey"
  
  -- fraction in range 0 to 1
  local Fraction = math.min (math.max (current / max, 0), 1) 

  -- background colour - for un-filled part
  WindowRectOp (win, 2, left, top, left + width, top + height, bg_colour)  -- fill entire box
  
  -- how big filled part is
  local gauge_width = width * Fraction
  
   -- box size must be > 0 or WindowGradient fills the whole thing 
  if math.floor (gauge_width) > 0 then
    
    -- top half
    WindowGradient (win, left, top, left + width, top + height / 2, 
                    0x000000, -- black
                    fg_colour, 2)  -- vertical top to bottom
    
    -- bottom half
    WindowGradient (win, left, top + height / 2, 
                    left + width, top +  height,   
                    fg_colour,
                    0x000000, -- black
                    2) -- vertical top to bottom

  end -- non-zero
  
  -- draw tick marks if wanted
  if ticks > 0 then
  
    -- show ticks  (if there are 5 ticks there are 6 gaps)
    local ticks_at = width / (ticks + 1)
    
    -- ticks
    for i = 1, ticks do
      WindowLine (win, left + (i * ticks_at), top, 
                  left + (i * ticks_at), top + height, 
                  tick_colour, 0, 1)
    end -- for

  end -- ticks wanted

  -- draw a box around it (frame)
  WindowRectOp (win, 1, left, top, left + width, top + height, frame_colour)
  
  if name and #name > 0 then
    -- mouse-over information: add hotspot if not there
    if not WindowHotspotInfo(win, name, 1) then
      WindowAddHotspot (win, name, left, top, left + width, top + height, 
                    "", "", "", "", "", "", 0, 0)
    end -- if
    
    -- store numeric values in case they mouse over it
    WindowHotspotTooltip(win, name, string.format ("%s\t%i / %i (%i%%)", 
                          name, current, max, Fraction * 100) )
  end -- hotspot wanted
                                    
end -- function gauge

-- find which element in an array has the largest text size
function max_text_width (win, font_id, t)
  local max = 0
  for _, s in ipairs (t) do
    max = math.max (max, WindowTextWidth (win, font_id, s))
  end -- for each item
  return max
end -- max_text_width