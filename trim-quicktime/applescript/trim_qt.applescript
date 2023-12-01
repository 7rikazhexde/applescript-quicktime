(********************************************************
Summary:
	AppleScript to trim and save selected video files with QuickTime Player on MacOS by time specification.
 
Verified Version:
	macOS Ventura
	version 13.6.1
 
Usage:
	1. Select the video file to be trimmed
	2. Specify the path (folder) to output files after trimming
	3. Enter the trim start time
	4. Enter the trim end time

Note:
	Video formats other than MOV and MP4 have not been tested.

Reference:
 	1. Batch cut unwanted parts of mp4 with AppleScript
	https://golbitz.com/applescript/applescript%E3%81%A7mp4%E3%81%AE%E4%B8%8D%E8%A6%81%E3%81%AA%E9%83%A8%E5%88%86%E3%82%92%E4%B8%80%E6%8B%AC%E3%82%AB%E3%83%83%E3%83%88-624
	2. apple script quicktime player export permission error
	https://discussions.apple.com/thread/250200823	
	3. Referencing Files and Folders 
	https://sites.google.com/site/zzaatrans/home/macautomationscriptingguide/referencefilesandfolders-html	
	4. Technical Note TN2065 
	https://sites.google.com/site/zzaatrans/home/doshellscriptinas_apple_2006-html/tn2065_apple	
	5. [Linux] Obtain the file size.
	https://ameblo.jp/archive-redo-blog/entry-10196055325.html
	6. Find and Replace Strings
	http://tonbi.jp/AppleScript/Tips/String/FindReplace.html
********************************************************)

(******************************************************** 
Function:
	askTrimTime(): Function to enter trim time
	
Argument:
	message: Message to be displayed in dialog
	
Return:
	trimTime: Time to trim
	
Description:
	Trim time is processed only for numerical values.
********************************************************)
on askTrimTime(message)
	repeat
		set results to (display dialog message default answer "" with icon note buttons {"Cancel", "Continue"} default button "Continue")
		set inputReturned to text returned of results
		set buttonReturned to button returned of results
		
		-- If the Cancel button is pressed, the script is terminated.
		if buttonReturned = "Cancel" then
			(display alert "Pushed cancel button. Quit script.")
			quit
		end if
		
		-- Trim time is for numerical values only
		try
			set trimTime to inputReturned as number
			exit repeat
		end try
		
	end repeat
	return trimTime
end askTrimTime

(******************************************************** 
Function:
 	replaceText(): Function to replace a string with a specified string
	
Argument:
	theText: original string
	serchStr:	 String to be replaced
	replaceStr: Replaced string
	
Return:
 	replaceText: Substituted string
	
Reference:
	6. Find and Replace Strings
********************************************************)
on replaceText(theText, serchStr, replaceStr)
	set tmp to AppleScript's text item delimiters
	set AppleScript's text item delimiters to serchStr
	set theList to every text item of theText
	set AppleScript's text item delimiters to replaceStr
	set theText to theList as string
	set AppleScript's text item delimiters to tmp
	return theText
end replaceText

(******************************************************** 
Function:
	trimVideo(): Function to enter trim time
	
Argument:
	none
	
Return:
	none
	
Note:
	If a file name contains a blank string, it is processed by replacing the blank string with "_".
	
Reference:
 	1. Batch cut unwanted parts of mp4 with AppleScript
	2. apple script quicktime player export permission error
	3. Referencing Files and Folders 
	4. Technical Note TN2065 
	5. [Linux] Obtain the file size.
********************************************************)
on trimVideo()
	-- Set input file path
	set inFilePath to choose file with prompt "Please select a video file:"
	set inputPathForShell to POSIX path of inFilePath
	log "-- Input File Path: " & inputPathForShell
	
	-- Get file name
	tell application "Finder"
		set fileName to name of inFilePath
	end tell
	
	-- Replace spaces with "_".
	set fileName to replaceText(fileName, " ", "_")
	
	-- Set export file name
	-- Output filename creation
	set outFileName to replaceText(fileName, ".mov", "_trim.mov")
	set outFileName to replaceText(fileName, ".mp4", "_trim.mp4")
	
	-- Set export file path
	set outFileFolder to choose folder with prompt "Please select a video file folder:"
	
	-- Combine file export file path and file name
	set outFileFolderPath to outFileFolder as text
	set outFilePath to outFileFolderPath & outFileName
	
	-- Set start / end trim time
	set message to "Please enter the trim start time(sec)"
	set startTime to askTrimTime(message)
	log "-- Trim Start Time: " & startTime & "sec"
	set message to "Please enter the trim end time(sec)"
	set endTime to askTrimTime(message)
	log "-- Trim End Time: " & endTime & "sec"
	
	tell application "QuickTime Player"
		activate
		
		-- Open video file
		try
			set theOpenedFile to open for access file outFilePath with write permission
			set eof of theOpenedFile to 0
		end try
		
		open file inFilePath
		
		-- Set trimming and export video file
		trim front document from startTime to endTime
		export front document in outFilePath using settings preset "480p"
		
		-- File close
		delay 1
		try
			close access theOpenedFile
		end try
		-- Even in the case of dirty, it does not save.
		close every document saving no
		
		-- Set export file path for shell script using PSXIX
		set filePathForShell to POSIX path of outFileFolder
		set outFileForShell to filePathForShell & outFileName
		
		-- File export
		-- The file export progress bar does not automatically close after exporting, use the quit command to close it after exporting.
		-- File export completion is determined by file size.
		-- Set the file size in each of the two variables and compare their values.
		-- If the file sizes are the same, determine that file export is complete.
		log "-- Start Trim"
		repeat
			tell current application
				-- Get the file size after an interval of 0.5 second
				set fileSize1 to do shell script "ls -lt " & outFileForShell & " | awk '{print $5}'"
				delay 0.5
				set fileSize2 to do shell script "ls -lt " & outFileForShell & " | awk '{print $5}'"
			end tell
			-- If the file size is the same, the iterative process is exsited.
			if fileSize1 = fileSize2 then
				exit repeat
			end if
		end repeat
		log "-- End Tim & File Export Complete"
		log "-- Export File Path: " & outFileForShell
		--log "fileSize1: " & fileSize1 & " / " & "fileSize2: " & fileSize1
		quit
	end tell
end trimVideo

(********************************************************
Function:
	main():
	Trim and save the selected video file with QuickTime Player on MacOS. 
	main function to trim and save the file.
	
Argument:
	none
	
Return:
	none
********************************************************)
on main()
	trimVideo()
end main

-- main function call
main()