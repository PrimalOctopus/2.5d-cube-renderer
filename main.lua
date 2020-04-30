--Camera variable
local player = {}
player.x, player.y = 0, -0.5
local fov = math.rad(60)
local screenW, screenH, halfW, halfH, startH, startW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY, display.screenOriginY, display.screenOriginX
local renderPort = display.newGroup()
local viewDist = 75

local focusPoint = (1/90)*fov

--Map table
local block = {}


--Block generation tracking
local currentHeight = 0
local currentLength = 0


--palletes
local pallete = 
		{
			{
				{r = 232, g = 215, b = 241},
				{r = 211, g = 188, b = 204},
				{r = 161, g = 103, b = 165},
				{r = 74, g = 48, b = 109},
				{r = 14, g = 39, b = 60}	
			},
			{
				{r = 50, g = 10, b = 40},
				{r = 81, g = 23, b = 48},
				{r = 142, g = 68, b = 61},
				{r = 203, g = 145, b = 115},
				{r = 224, g = 214, b = 138}	
			},
			{
				{r = 66, g = 202, b = 253},
				{r = 102, g = 179, b = 186},
				{r = 246, g = 239, b = 166},
				{r = 240, g = 210, b = 209},
				{r = 142, g = 177, b = 157}	
			},
			{
				{r = 183, g = 240, b = 173},
				{r = 210, g = 255, b = 150},
				{r = 237, g = 255, b = 122},
				{r = 232, g = 211, b = 63},
				{r = 209, g = 123, b = 15}	
			},
			{
				{r = 206, g = 229, b = 242},
				{r = 172, g = 203, b = 225},
				{r = 124, g = 152, b = 179},
				{r = 99, g = 112, b = 129},
				{r = 83, g = 107, b = 120}
			},
			{
				{r = 206, g = 255, b = 26},
				{r = 170, g = 169, b = 90},
				{r = 130, g = 129, b = 109},
				{r = 65, g = 64, b = 102},
				{r = 27, g = 45, b = 42}
			},
			{
				{r = 57, g = 0, b = 153},
				{r = 158, g = 0, b = 89},
				{r = 255, g = 0, b = 84},
				{r = 255, g = 84, b = 0},
				{r = 255, g = 189, b = 0}
			},
			{
				{r = 251, g = 251, b = 242},
				{r = 229, g = 230, b = 228},
				{r = 207, g = 210, b = 205},
				{r = 166, g = 162, b = 162},
				{r = 132, g = 117, b = 119}
			},
			{
				{r = 33, g = 39, b = 56},
				{r = 249, g = 112, b = 104},
				{r = 209, g = 214, b = 70},
				{r = 237, g = 242, b = 239},
				{r = 87, g = 196, b = 229}
			},
			{
				{r = 6, g = 158, b = 45},
				{r = 5, g = 142, b = 63},
				{r = 4, g = 119, b = 59},
				{r = 3, g = 96, b = 22},
				{r = 3, g = 68, b = 12}
			},
		}

for k = 1, #pallete do
	for j = 1, #pallete[k] do
		pallete[k][j].r = pallete[k][j].r/255
		pallete[k][j].g = pallete[k][j].g/255
		pallete[k][j].b = pallete[k][j].b/255

	end
end
		
local currentPallete = math.random(1, #pallete)
local palleteTimer

--FPS timers
local time = {current = system.getTimer(), old = system.getTimer(), frame = 0}

fpsText = display.newText(" ", startW + 120, 80, native.systemFont, 36 )
fpsText.anchorX = 0


function distancec ( x1, y1, x2, y2 )
	local dx = x1 - x2
	local dy = y1 - y2
	return math.sqrt ( dx * dx + dy * dy )
end


--Draw polygon at screen defined coordinates
function absPolygon(displayGroup ,vertices)
	local max = {x = -9999, y = -9999}
	local min = {x = 9999, y = 9999}
	for k = 1, #vertices, 2 do
		max.x = vertices[k] > max.x and vertices[k] or max.x
		max.y = vertices[k+1] > max.y and vertices[k+1] or max.y
		min.x = vertices[k] < min.x and vertices[k] or min.x
		min.y = vertices[k+1] < min.y and vertices[k+1] or min.y
	end

	local xCenter = min.x + (max.x - min.x)/2
	local yCenter = min.y + (max.y - min.y)/2

	for k = 1, #vertices, 2 do	
		vertices[k] = vertices[k]-xCenter
		vertices[k+1] = vertices[k+1]-yCenter
	end
	
	return display.newPolygon(displayGroup, xCenter, yCenter, vertices)
end


--Draw to screen
function draw(displayGroup, c1, c2, lane)
	local minValue = (-fov*0.5)
	local maxValue = (fov*0.5)
	
	local size = 1
	
	local y1, y2, x1, x2
	
	local distance = math.max(0.666, c2.x - c1.x)
	
	local distance2 = math.max(c2.x + size - c1.x)
	
	--render top
	if c2.y >= c1.y then
		y1 = screenH * ( (math.atan2(c2.y - c1.y, distance)  - minValue)/(maxValue-minValue) )
		y2 = screenH * ( (math.atan2(c2.y - c1.y, distance2)  - minValue)/(maxValue-minValue) )
	else
	--render bottom
		y1 = screenH * ( (math.atan2(c2.y +size - c1.y, distance)  - minValue)/(maxValue-minValue) )
		y2 = screenH * ( (math.atan2(c2.y +size - c1.y, distance2)  - minValue)/(maxValue-minValue) )
	end
	
	if (y2 > 0 and y2 < screenH) then

		--y1 = math.max(0, math.min(y1, screenH))
	

		

		
		local scale1 = screenH*size / distance
		local scale2 = screenH*size / distance2
		
		local fade = math.max(1,distance/(viewDist*0.1))
		
		local c = c2.c		
		
		local pallete = pallete[c2.p]
			
		local colour1 = {r = pallete[c].r/fade, g = pallete[c].g/fade, b = pallete[c].b/fade}
		
		local colour2 = {r = (pallete[c].r*0.75)/fade, g = (pallete[c].g*0.75)/fade, b = (pallete[c].b*0.75)/fade}
		
		local colour3 = {r = (pallete[c].r*0.5)/fade, g = (pallete[c].g*0.5)/fade, b = (pallete[c].b*0.5)/fade}
		

		
		--middle lane
		if lane == 2 then
			x1 = halfW
			x2 = halfW
		elseif lane == 1 then
			x1 = halfW - 2*scale1
			x2 = halfW - 2*scale2
		elseif lane == 3 then
			x1 = halfW + 2*scale1
			x2 = halfW + 2*scale2
		end
		
		local vertices = {{},{},{},{},{},{},{}}
		
		--top/bottom
		vertices[2].x = x1 - scale1*0.5
		vertices[2].y = y1		
		vertices[3].x = x1 + scale1*0.5
		vertices[3].y = y1
									
								
		vertices[1].x = x2 - scale2*0.5
		vertices[1].y = y2
		vertices[4].x = x2 + scale2*0.5
		vertices[4].y = y2	
		
		local a = absPolygon(displayGroup,{vertices[1].x, vertices[1].y, vertices[2].x, vertices[2].y, vertices[3].x, vertices[3].y, vertices[4].x, vertices[4].y})
		
		local b
		
		--create polygons
			if c2.y >= c1.y then
				vertices[5].x = vertices[2].x
				vertices[5].y = vertices[2].y + scale1
				vertices[6].x = vertices[3].x 
				vertices[6].y = vertices[3].y + scale1
				
				if lane == 1 then
					vertices[7].x = vertices[4].x
					vertices[7].y = vertices[4].y + scale2
					b = absPolygon(displayGroup,{vertices[2].x, vertices[2].y, vertices[5].x, vertices[5].y, vertices[6].x, vertices[6].y,
					vertices[7].x, vertices[7].y, vertices[4].x, vertices[4].y, vertices[3].x, vertices[3].y})
				elseif lane == 3 then
					vertices[7].x = vertices[1].x
					vertices[7].y = vertices[1].y + scale2
					b = absPolygon(displayGroup,{vertices[1].x, vertices[1].y, vertices[7].x, vertices[7].y, vertices[5].x, vertices[5].y, vertices[6].x, vertices[6].y,
					vertices[3].x, vertices[3].y, vertices[2].x, vertices[2].y})
				else
					b = absPolygon(displayGroup,{vertices[2].x, vertices[2].y, vertices[5].x, vertices[5].y, vertices[6].x, vertices[6].y, vertices[3].x, vertices[3].y})
				end
				a:setFillColor(colour1.r, colour1.g, colour1.b)
				b:setFillColor(colour2.r, colour2.g, colour2.b)
			else
				vertices[5].x = vertices[2].x
				vertices[5].y = vertices[2].y - scale1
				vertices[6].x = vertices[3].x 
				vertices[6].y = vertices[3].y - scale1
				
				if lane == 1 then
					vertices[7].x = vertices[4].x
					vertices[7].y = vertices[4].y - scale2
					b = absPolygon(displayGroup,{vertices[2].x, vertices[2].y, vertices[5].x, vertices[5].y, vertices[6].x, vertices[6].y,
					vertices[7].x, vertices[7].y, vertices[4].x, vertices[4].y, vertices[3].x, vertices[3].y})
				
				elseif lane == 3 then
					vertices[7].x = vertices[1].x
					vertices[7].y = vertices[1].y - scale2
					b = absPolygon(displayGroup,{vertices[1].x, vertices[1].y, vertices[7].x, vertices[7].y, vertices[5].x, vertices[5].y, vertices[6].x, vertices[6].y,
					vertices[3].x, vertices[3].y, vertices[2].x, vertices[2].y})
				else
					b = absPolygon(displayGroup,{vertices[2].x, vertices[2].y, vertices[5].x, vertices[5].y, vertices[6].x, vertices[6].y, vertices[3].x, vertices[3].y})
				end
				b:setFillColor(colour2.r, colour2.g, colour2.b)
				a:setFillColor(colour3.r, colour3.g, colour3.b)
			end
		end					
end



function render(object)

	local fp = {x = player.x-focusPoint,y = player.y}
	
	renderPort:removeSelf()
	
	renderPort = display.newGroup()
	
	for k = #object, 1, -1 do				
			
		draw( renderPort, fp, object[k], 1)
		draw( renderPort, fp, object[k], 3)
		draw( renderPort, fp, object[k], 2)
			
	end
end




	
	
local function generateMap(length ,range)
	local mapCounter = 1
	
	local mapTable = {}
	for i = 1,length do	
			local newBlock = {
								x = currentLength, y = currentHeight, 
								c = math.random(1,5), p = currentPallete 
							}
							
			mapTable[mapCounter] = newBlock

			currentHeight = math.min( 5 ,math.max( -5, currentHeight + math.random(-range, range) ) )
			if currentHeight == -1 then 
				currentHeight = 0
			end
				
			mapCounter = mapCounter + 1
		currentLength = currentLength + 1
	end
	return mapTable
end
	

function update()
	--print("update")

	player.x = player.x +5*time.frame
	
	for k = #block, 1, -1 do
		if player.x > block[k].x+1 then			
			table.remove(block, k)
			
			local temp = generateMap(1, 2)
			block[#block+1] = temp[1]
		end
	end
	

	render(block)

	
	
	
	--Calculate frame times
	time.old = time.current
	time.current = system.getTimer()
	time.frame = (time.current - time.old)*0.001--/1000	
	fpsText.text = "fps "..math.floor(1/time.frame)
end

block = generateMap(viewDist,2)
Runtime:addEventListener("enterFrame", update)
palleteTimer = timer.performWithDelay(5000, function() currentPallete = (currentPallete%#pallete)+1 end, 0)


