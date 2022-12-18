--12/17/2022
--Aurthor: EnspireMe Productions
--Prior Contributors:  
--Twitch Video Tutorial: enspireme_retrogadgets
--Discord for comments/questions:
--Youtube Tutorial:
--Github Repository:

--Programs Purpose: 
--Input controlled counter displayed over a LED array and 2x-7segment display
--Meant as source material for similar functionality given various input devices

--7-Segment Display Outputs
local segDisp:SegmentDisplay = gdt.SegmentDisplay0
--             Common Anode
--	     --	  	 1
--      |  |  	6 2
--  	   --      7
--      |  |    5 3
--    	 -- .    4 8
local segCode:{{number}} = {
    -- returns a table
    [0] = {1,2,3,4,5,6},
    [1] = {2,3},
    [2] = {1,2,4,5,7},
    [3] = {1,2,3,4,7},
    [4] = {2,3,6,7},
    [5] = {1,3,4,6,7},
    [6] = {1,3,4,5,6,7},
    [7] = {1,2,3},
    [8] = {1,2,3,4,5,6,7},
    [9] = {1,2,3,4,6,7}
}
--LED Strip Outputs
local led0:LedStrip = gdt.LedStrip0
local led1:LedStrip = gdt.LedStrip1
local led2:LedStrip = gdt.LedStrip2	
local maxLEDs = 24
--Button Inputs
local upBtn:LedButton = gdt.LedButton0
local downBtn:LedButton = gdt.LedButton1
local resetBtn:LedButton = gdt.LedButton2
--RGB Slider Inputs
local Rsel:Slider = gdt.Slider0
local Gsel:Slider = gdt.Slider1
local Bsel:Slider = gdt.Slider2
--Output counter
local count:number = 0

--7Segment decoder
function displayDigit(display:SegmentDisplay, digit:number, value:number)
	for segment = 1,8 do
		display.States[digit][segment] = false
	end
	for segment = 1, #segCode[value] do --#length of table
		display.States[digit][segCode[value][segment]] = true
	end
end

--BCD 2Digit 7-segment display
function bcdSplit(display:SegmentDisplay, value:number)
    local digit2:number = math.floor(value) % 10
    local digit1:number = (value - digit2) / 10
    displayDigit(display, 2, digit2) --LSDigit
    displayDigit(display, 1, digit1) --MSDigit
end


--Displays count on LED strips
function displayLEDs(value:number)
	-- leftmost led strip case
    if value <= 8 then 
        for i = 1,8 do
        		led0.States[i] = false
						led1.States[1] = false
				end
				for i = 1, value do
            led0.States[i] = true
						
        end
    end		
	-- middle led strip case
		if value > 8 and value <= 16 then
				for i = 1,8 do
        		led1.States[i] = false
						led2.States[1] = false
			  end
				for i = 1, value - 8 do
						led1.States[i] = true
				end													
		end
	-- rightmost led strip case
		if value > 16 then
				for i = 1,8 do
        		led2.States[i] = false
							
    		end
				for i = 1, value - 16 do
						led2.States[i] = true
				end		
		end					
end

function updateColor()
		if resetBtn.ButtonDown then
				for i = 1,8 do
							led0.Colors[i] = Color(Rsel.Value,Gsel.Value,Bsel.Value)																					led1.Colors[i] = Color(Rsel.Value,Gsel.Value,Bsel.Value)																					led2.Colors[i] = Color(Rsel.Value,Gsel.Value,Bsel.Value)
							for k = 1,2 do
									segDisp.Colors[k][i] = Color(Rsel.Value,Gsel.Value,Bsel.Value)
							end
				end
		end
end

--Edge Detects btn pressed and updates counter :: single event
function updateCounter()
		if count >= 0 or count <= maxLEDs then
        if upBtn.ButtonDown then count += 1 end
	    	if downBtn.ButtonDown then count -= 1 end
    end
    if count < 0 then count = 0 end     --counter lower limit
    if count > maxLEDs then count = maxLEDs end   --counter upper limit
  --Function calls with new count  
	bcdSplit(segDisp,count) --call to display on segment    
	displayLEDs(count)
end

function update()
  updateCounter() --updates every tick :: clk freq TBD still
	updateColor()
end
