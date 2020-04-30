--Camera variables
local player = {}
player.x, player.y, player.z = 0, -0.5, 0
local screenW, screenH, halfW, halfH, startH, startW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY, display.screenOriginY, display.screenOriginX
local viewDist = 75

local fov = 60
local focusPoint = (1/90)*fov
fov = math.rad(fov)

local renderPort = display.newGroup()

--Map table
local block = {}

--Block generation tracking
local currentHeight = 0
local currentLength = 0
local mapWidth = 5
local mapHeight = 10

for k = 1, (mapWidth*2) +1 do
	block[k] =  {}
end

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


--functions


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


function render(displayGroup, map)

	local height = 1
	local length = 1
	
	local pZ = player.z%1 < 0.5 and math.floor(player.z) or math.ceil(player.z)
	pZ = math.min( (mapWidth*2)+1, math.max( 1, pZ + mapWidth+1 ) )
	
	local c1 = {x = player.x - focusPoint, y = player.y, z = player.z}
	
	--Draw to screen
	local function draw(displayGroup, object)
		local c2 =  object

		local distance2 = (c2.x + length - c1.x)
			
		if distance2 > 0 then
			local minValue = (-fov*0.5)
			local maxValue = (fov*0.5)
				
			local y1, y2, x1, x2
			
			local distance = math.max(focusPoint, c2.x - c1.x)
			
			--render top
			if c2.y >= c1.y then
				y1 = screenH * ( (math.atan2(c2.y - c1.y, distance)  - minValue)/(maxValue-minValue) )
				y2 = screenH * ( (math.atan2(c2.y - c1.y, distance2)  - minValue)/(maxValue-minValue) )	
			else
			--render bottom
				y1 = screenH * ( (math.atan2(c2.y +height - c1.y, distance)  - minValue)/(maxValue-minValue) )
				y2 = screenH * ( (math.atan2(c2.y +height - c1.y, distance2)  - minValue)/(maxValue-minValue) )
			end
		

			
			--Colour calculatio
			local fade = math.max(1,distance/(viewDist*0.1))
			local c = c2.c			
			local pallete = pallete[c2.p]	
			
			local colour1 = {r = pallete[c].r/fade, g = pallete[c].g/fade, b = pallete[c].b/fade}	
			local colour2 = {r = (pallete[c].r*0.75)/fade, g = (pallete[c].g*0.75)/fade, b = (pallete[c].b*0.75)/fade}	
			local colour3 = {r = (pallete[c].r*0.5)/fade, g = (pallete[c].g*0.5)/fade, b = (pallete[c].b*0.5)/fade}
				
				
			--scaling values for polygons	
			local diffZ = c2.z - c1.z
			
			local scale1 = screenH*height / distance
			local scale2 = screenH*height / distance2
				
			x1 = halfW + diffZ*scale1
			x2 = halfW + diffZ*scale2
			
			--calculate vertices
			local vertices = {{},{},{},{},{},{},{}}
			
			vertices[2].x = x1 - scale1*0.5
			vertices[2].y = y1		
			vertices[3].x = x1 + scale1*0.5
			vertices[3].y = y1
															
			vertices[1].x = x2 - scale2*0.5
			vertices[1].y = y2
			vertices[4].x = x2 + scale2*0.5
			vertices[4].y = y2	
			
			--top/bottom polygon
			local a = absPolygon(displayGroup,{vertices[1].x, vertices[1].y, vertices[2].x, vertices[2].y, vertices[3].x, vertices[3].y, vertices[4].x, vertices[4].y})	
			
			--forward reference to front/side polygon
			local b
			
			--draw front/side polygon if showing top side
			if c2.y >= c1.y then
				vertices[5].x = vertices[2].x
				vertices[5].y = vertices[2].y + scale1
				vertices[6].x = vertices[3].x 
				vertices[6].y = vertices[3].y + scale1
					
				if diffZ < -0.55 then  --left
					vertices[7].x = vertices[4].x
					vertices[7].y = vertices[4].y + scale2
					b = absPolygon(displayGroup,{vertices[2].x, vertices[2].y, vertices[5].x, vertices[5].y, vertices[6].x, vertices[6].y,
					vertices[7].x, vertices[7].y, vertices[4].x, vertices[4].y, vertices[3].x, vertices[3].y})
				elseif diffZ > 0.55 then --right
					vertices[7].x = vertices[1].x
					vertices[7].y = vertices[1].y + scale2
					b = absPolygon(displayGroup,{vertices[1].x, vertices[1].y, vertices[7].x, vertices[7].y, vertices[5].x, vertices[5].y, vertices[6].x, vertices[6].y,
					vertices[3].x, vertices[3].y, vertices[2].x, vertices[2].y})
				else --middle
					b = absPolygon(displayGroup,{vertices[2].x, vertices[2].y, vertices[5].x, vertices[5].y, vertices[6].x, vertices[6].y, vertices[3].x, vertices[3].y})
				end
				a:setFillColor(colour1.r, colour1.g, colour1.b)
				b:setFillColor(colour2.r, colour2.g, colour2.b)
				
			--draw front/side polygon if showing bottom side
			else
				vertices[5].x = vertices[2].x
				vertices[5].y = vertices[2].y - scale1
				vertices[6].x = vertices[3].x 
				vertices[6].y = vertices[3].y - scale1
					
				if diffZ < -0.55 then --left
					vertices[7].x = vertices[4].x
					vertices[7].y = vertices[4].y - scale2
					b = absPolygon(displayGroup,{vertices[2].x, vertices[2].y, vertices[5].x, vertices[5].y, vertices[6].x, vertices[6].y,
					vertices[7].x, vertices[7].y, vertices[4].x, vertices[4].y, vertices[3].x, vertices[3].y})
					
				elseif diffZ > 0.55 then --right
					vertices[7].x = vertices[1].x
					vertices[7].y = vertices[1].y - scale2
					b = absPolygon(displayGroup,{vertices[1].x, vertices[1].y, vertices[7].x, vertices[7].y, vertices[5].x, vertices[5].y, vertices[6].x, vertices[6].y,
					vertices[3].x, vertices[3].y, vertices[2].x, vertices[2].y})
				else --middle
					b = absPolygon(displayGroup,{vertices[2].x, vertices[2].y, vertices[5].x, vertices[5].y, vertices[6].x, vertices[6].y, vertices[3].x, vertices[3].y})
				end
				b:setFillColor(colour2.r, colour2.g, colour2.b)
				a:setFillColor(colour3.r, colour3.g, colour3.b)
			end			
		end
	end

	
	--iterate from left to one lane left of the player
	for z = 1, pZ-1 do
		for k = #map[z], 1, -1 do	
			draw(displayGroup, map[z][k])		
		end
	end
	
	--iterate from right to the player
	for z = (mapWidth*2)+1, pZ, -1 do
		for k = #map[z], 1, -1 do	
			draw(displayGroup, map[z][k])		
		end
	end
	
end
	
	
local function generateMap(range, z)
	local newBlock 
	
	newBlock = {
					x = currentLength, y = currentHeight, z = z,
					c = math.random(1,5), p = currentPallete 
				}
							
	currentHeight = math.min( mapHeight*0.5 ,math.max( -mapHeight*0.5, currentHeight + math.random(-range, range) ) )
	if currentHeight == -1 then 
		currentHeight = 0
	end
				
	return newBlock
end
	

local zSpeed = 5
function update()
	player.x = player.x +10*time.frame
	
	player.z = player.z + zSpeed*time.frame
	
	if player.z > (mapWidth) and zSpeed > 0 then
		zSpeed = -zSpeed
	elseif player.z < -mapWidth and zSpeed < 0 then
		zSpeed = -zSpeed
	end
	
	for z = 1, #block do
		currentLength = block[z][#block[z]].x+1
		for k = 1, #block[z] do
			if player.x > block[z][k].x+4 then
				table.remove(block[z],k)
				block[z][#block[z]+1] = generateMap(mapHeight,z -mapWidth -1)
			end
		end
	end
	
	renderPort:removeSelf()
	renderPort = display.newGroup()
	render(renderPort, block)


	--Calculate frame times
	time.old = time.current
	time.current = system.getTimer()
	time.frame = (time.current - time.old)*0.001--/1000	
	fpsText.text = "fps "..math.floor(1/time.frame)
end

for k = 1,viewDist do
	for z = 1, (mapWidth*2)+1 do
		block[z][#block[z]+1] = generateMap(2,z-mapWidth-1)
	end
	currentLength = currentLength + 1
end
	
Runtime:addEventListener("enterFrame", update)
palleteTimer = timer.performWithDelay(5000, function() currentPallete = (currentPallete%#pallete)+1 end, 0)


