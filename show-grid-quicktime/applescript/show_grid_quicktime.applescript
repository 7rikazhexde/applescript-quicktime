(********************************************************
show_grid_quicktime.scpt

 Summary:
	AppleScript for arranging video files stored in specified folders in a grid format.

 Usage:
	1.Adjustable parameters settings
		See "Adjustable parameters". 
		Then activate the parameters for the file size you want to use from "Configuration for video".
	2.Run script and check result
			
Note:
	- Target files are mov and mp4.
	- This script supports the following file sizes.
		640x360 (reduced to 320x180)
		640x360
		486x360 (reduced to 243x180)
	- Other sizes can be supported by changing the "Adjustable parameters", 
	  but the parameters need to be adjusted.
	- This script supports the process of launching and playing video files. 
	  Comment out "playAllVideosSimultaneously()" if you do not need the playback process.
********************************************************)

on run {}
	--set videoFolder to "/Users/Guest/Public/test/video/sample1" as POSIX file
	set videoFolder to choose folder with prompt "Please select a folderÅF"
	set videoFolderPath to POSIX path of videoFolder
	
	-- Adjustable parameters
	-- videoWidth, videoHeight: original video size (*fixed value dependent on file size).
	-- horizontalMargin: horizontal spacing between windows (*fixed value depending on file size).
	-- verticalMargin: vertical spacing between windows (*fixed value depending on file size).
	-- offsetX, offsetY: overall alignment position adjustment (*0,0 for upper left corner).
	-- adjustSize: fine adjustment of the vertical position of the lower window (*fixed value.)
	-- Set to a value of 25 or higher (*25 corresponds to an offset of 0 pixels. Fine-tune as required).
	
	-- halfSizeFlag: video reduction allowed (*change if necessary).
	
	-- Configuration for video (*Use uncommented out, depending on file size)
	-- For 640x360 (reduced to 320x180)
	--(*
	set videoWidth to 640
	set videoHeight to 360
	set horizontalMargin to 5
	set verticalMargin to 30
	set offsetX to 100
	set offsetY to 100
	set adjustSize to 25
	set halfSizeFlag to true
	--*)
	
	-- For 640x360
	(*
	set videoWidth to 640
	set videoHeight to 360
	set horizontalMargin to 0
	set verticalMargin to 25
	set offsetX to 100
	set offsetY to 100
	set adjustSize to 25 
	set halfSizeFlag to false
	*)
	
	-- For 486x360 (reduced to 343x180)
	(*
	set videoWidth to 486
	set videoHeight to 360
	set horizontalMargin to 83
	set verticalMargin to 85
	set offsetX to 100
	set offsetY to 200
	set adjustSize to 25
	set halfSizeFlag to true
	*)
	
	-- Call function to arrange windows in grid
	my arrangeWindowsInGrid(videoFolder, videoWidth, videoHeight, horizontalMargin, verticalMargin, offsetX, offsetY, adjustSize, halfSizeFlag)
	
	-- Optionally call function to play all videos simultaneously
	-- Comment out the next line if you don't want automatic playback
	delay 2
	my playAllVideosSimultaneously()
end run

on arrangeWindowsInGrid(videoFolder, videoWidth, videoHeight, horizontalMargin, verticalMargin, offsetX, offsetY, adjustSize, halfSizeFlag)
	tell application "Finder"
		set videoFiles to files of folder videoFolder whose name extension is in {"mp4", "mov"}
	end tell
	
	if (count of videoFiles) is 0 then
		display dialog "No mp4 or mov files were found in the specified folder." buttons {"OK"} default button "OK"
	else
		set num to count of videoFiles
		set gridSize to (num ^ 0.5) as integer -- Integer part of root n
		
		tell application "QuickTime Player"
			activate
			set windowCount to 0
			repeat with videoFile in videoFiles
				open videoFile
				delay 0.5 -- Wait for the file to open.
				set windowCount to windowCount + 1
				if windowCount is num then exit repeat
			end repeat
			
			-- Arrange windows
			tell application "System Events"
				tell process "QuickTime Player"
					-- Calculation of window size
					if halfSizeFlag is true then
						set windowWidth to videoWidth / 2
						set windowHeight to videoHeight / 2
					else
						set windowWidth to videoWidth
						set windowHeight to videoHeight
					end if
					
					set windowList to windows
					set totalWindows to count of windowList
					repeat with i from 1 to totalWindows
						set thisWindow to item (totalWindows - i + 1) of windowList
						
						-- Row and column calculations
						(*
							For 3x3 grid (gridSize = 3)
							For i = 1: (1-1) div 3 = 0, (1-1) mod 3 = 0 Å® (row 0, column 0) top left 
							For i = 2: (2-1) div 3 = 0, (2-1) mod 3 = 1 Å® (row 0, column 1) top centre 
							For i = 3: (3-1) div 3 = 0, (3-1) mod 3 = 2 Å® (row 0, column 2) top right
							For i = 4: (4-1) div 3 = 1, (4-1) mod 3 = 0 Å® (row 1, column 0) middle left
							...					
							For i = 9: (9-1) div 3 = 2, (9-1) mod 3 = 2 Å® (row 2, column 2) bottom right
						*)
						set rowIndex to (i - 1) div gridSize
						set colIndex to (i - 1) mod gridSize
						
						set xPos to offsetX + (windowWidth + horizontalMargin) * colIndex
						set yPos to offsetY + (windowHeight + verticalMargin - adjustSize) * rowIndex
						
						set position of thisWindow to {xPos, yPos}
						set size of thisWindow to {windowWidth, windowHeight}
					end repeat
				end tell
			end tell
		end tell
	end if
end arrangeWindowsInGrid

on playAllVideosSimultaneously()
	tell application "QuickTime Player"
		set allDocuments to documents
		repeat with eachDocument in allDocuments
			tell eachDocument
				play
			end tell
		end repeat
	end tell
end playAllVideosSimultaneously