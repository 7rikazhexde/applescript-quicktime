(********************************************************
 Summary:
	Using the screen recording function of QuickTime Player on MacOS 
	AppleScript to record the screen at a specified time

 SupportVersion:
	macOS Monterey(version 12.4)
	QuickTime Player(version 10.5)

 Usage:
	1.QuickTime Player settings
		Select 'Record Selection' and set the area you want to record and 
		Set the area you want to record and the location where 
		you want to save the file (Options→Destination).
	2.Set the recording time
		Enter the recording time in the dialog that appears after startup.
		ex)3600(seconds) = 60(minutes) = 1(hour)
		Recording time depends on the process and 
		may deviate by a few seconds to a few tens of seconds.
		Set the recording time to a value larger than the desired recording time.
		
 reference:
	1.AppleScript sample code / AppleScript のサンプルコード
	https://dev.classmethod.jp/articles/applescript-sample/
	2.QuickTime Player to head all open movies and play them at the same time / 
	QuickTime Playerでオープン中の全ムービーを頭出しして同時再生
	http://piyocast.com/as/archives/tag/quicktime-player
********************************************************)

(******************************************************** 
 Function Name:
	ask_number(thePrompt):
	Function to enter recording time
 Arguments:
	None
 Return value:
	recording_time: recording time
 Description:
	Returns only the value entered as a number as the recording time
********************************************************)
on ask_recording_time()
	-- Non-numeric repetition
	repeat
		set results to (display dialog "Please enter the recording time(sec)" default answer "" with icon note buttons {"Cancel", "Continue"} default button "Continue")
		set input_returned to text returned of results
		set button_returned to button returned of results
		
		if button_returned = "Cancel" then
			(display alert "Pushed cancel button. Quit script.")
			quit {}
		end if
		
		try
			-- If it's a number, it exits the loop
			set recording_time to input_returned as number
			exit repeat
		end try
		
	end repeat
	log "[ask_recording_time()]Recording time" & recording_time & "sec"
	return recording_time
end ask_recording_time

(********************************************************
 Function Name:
	quicktimeplayer_runnning_check():
	Function to determine if QuickTime Player is running
 Arguments:
	None
 Return value:
	true:QuickTime Player is running
	false:QuickTime Player is not running
 Description:
	Returns true if the QuickTime Player is runnning, false otherwise
********************************************************)
on quicktimeplayer_runnning_check()
	-- Initialize the flag for QuickTime Player execution judgment with false
	set qtRunningFlag to false
	if application "QuickTime Player" is running then
		-- QuickTime Player execution flag is updated with true
		set qtRunningFlag to true
	end if
	-- Returns flags for QuickTime Player execution judgment
	return qtRunningFlag
end quicktimeplayer_runnning_check

(********************************************************
 Function Name:
	quicktimeplayer_play_multiscreens()
	Function to determine if QuickTime Player playback process has been executed
 Arguments :
	None
 Return value:
	true:QuickTime Player playback processing was executed
	false: QuickTime Player playback processing could not be executed
 Description:
	Obtain the number of elements from the document class and 
	if the number of elements is not zero, execute the playback process.
********************************************************)
on quicktimeplayer_play_multiscreens()
	tell application "QuickTime Player"
		-- Initialize QuickTime Player playback processing execution judgment flag with false
		set qtActiveScreenFlag to false
		-- Designated as frontmost
		activate
		-- Refer to all elements by specifying the document class and set them to dList.
		set dList to every document
		-- Number of elements (number of screens to be recorded) acquisition
		set dList_num to count of dList
		log "[quicktimeplayer_play_multiscreens()]Number of screens:" & dList_num
		-- If the number of elements is not zero, set the playback process.
		if dList_num is not 0 then
			-- QuickTime Player playback processing availability flag is updated with true
			set qtActiveScreenFlag to true
			-- Element count playback process
			repeat with i in dList
				tell i
					-- Enable to play from 0 seconds
					-- set current time to 0
					-- Enable loop
					set looping to true
				end tell
			end repeat
			tell every document to play
		end if
	end tell
	-- Returns the QuickTime Player playback processing execution decision flag
	return qtActiveScreenFlag
end quicktimeplayer_play_multiscreens

(********************************************************
 Function name:
	screen_recording(input_time):
	Screen recording processing function
 Arguments:
	input_num: time to record
 Return value:
	None
 Description:
	A shortcut key input from System Events launches the screenshot toolbar and starts recording.
	The elapsed time to be recorded is obtained from the data object using the current date command,
	calculated, and set.
	After the recording time has elapsed, recording is stopped by inputting a shortcut key 
	in the same way as for the start of recording.
********************************************************)
on screen_recording(input_time)
	tell application "System Events"
		-- command+shift+5 activates the screenshot toolbar
		key code 23 using {command down, shift down}
		-- Allow 0.5 seconds to activate the record button (adjust by number of screens)
		delay 0.5
		-- return
		key code 36
		log "[screen_recording()]Recording start"
	end tell
	
	set cDate to (current date)
	delay input_time
	set elapsedTime to ((current date) - cDate)
	
	tell application "System Events"
		-- command+control+esc to complete recording
		key code 53 using {command down, control down}
		-- Commentout the dialog display if it is not needed.
		log "[screen_recording()]Recording end:Elapsed time" & elapsedTime & "sec"
	end tell
	
	return
end screen_recording

(******************************************************** 
 Function Name:
	quit_quicktimeplayer():
	Function to quit QuickTime Player
 Arguments:
	None
 Return value:
	None
 Description:
	Quit QuickTime Player with the quit command
********************************************************)
on quit_quicktimeplayer()
	tell application "QuickTime Player"
		log "[quit_quicktimeplayer()]QuickTime Player quit"
		quit
	end tell
end quit_quicktimeplayer

(********************************************************
 Function Name:
	main():
	main function that executes screen recording with QuickTime Player
 Arguments:
	None
 Return value:
	None
 Description:
	Allow screen recording process only while QuickTime Player is running
	If there are screens that can be recorded, recording is performed for the specified time (start to stop).
	If there are no screens available for recording or If there is no screen available for recording and 
	QuickTime Player is not running QuickTime Player is terminated and an error dialog is displayed.
********************************************************)
on main()
	if quicktimeplayer_runnning_check() = true then
		set input_num to ask_recording_time()
		if input_num is greater than 0 then
			if quicktimeplayer_play_multiscreens() = true then
				screen_recording(input_num)
				quit_quicktimeplayer()
				display dialog "Screen recording is complete. Quit script."
			else
				quit_quicktimeplayer()
				display dialog "Video file does not exist. Quit script."
			end if
		else
			(display dialog "Please enter a positive integer for the elapsed time.Quit script." buttons {"Cancel", "OK"} default button "OK")
		end if
	else
		display dialog "Please Activate QuickTime Player. Quit script."
	end if
	log "[main()]Script end"
	return
end main

-- main function call
main()