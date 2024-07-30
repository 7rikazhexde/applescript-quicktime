(********************************************************
 Summary:
	Using the screen recording function of QuickTime Player on MacOS 
	AppleScript to record the screen at a specified time

 Verified Version:
	macOS Ventura(version 13.6.1)
	QuickTime Player(version 10.5)

 Usage:
	1.QuickTime Player settings
		Select 'Record Selection' and set the area you want to record and 
		Set the area you want to record and the location where 
		you want to save the file (OptionsÅ®Destination).
	2.Set the recording time
		Enter the recording time in the dialog that appears after startup.
		ex)3600(seconds) = 60(minutes) = 1(hour)
		Recording time depends on the process and 
		may deviate by a few seconds to a few tens of seconds.
		Set the recording time to a value larger than the desired recording time.
		
 reference:
	1. AppleScript sample code
	https://dev.classmethod.jp/articles/applescript-sample/
	2. QuickTime Player to head all open movies and play them at the same time
	http://piyocast.com/as/archives/tag/quicktime-player
********************************************************)

(******************************************************** 
 Function Name:
	ask_recording_time():
	Function to display a dialog box to request the input of recording time and return the input value
 Arguments:
	None
 Return value:
	recording_time: recording time
 Description:
	Recorded time is processed only for numerical values.
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
	return recording_time * 60
end ask_recording_time

(********************************************************
 Function name:
	screen_recording(input_time):
	Screen recording processing function
 Arguments:
	input_time: time to record
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
	stop_googlechrome():
	Function to stop Google Chrome processes
 Arguments:
	None
 Return value:
	None
 Note:
	Use kill -9 with caution, as it kills the process and may result in the loss of any work being performed.
	When executing commands in the terminal, be careful not to accidentally kill other important processes.
	Please work with extreme caution.
********************************************************)
on stop_googlechrome()
	do shell script "kill -9 $(pgrep 'Google Chrome')"
end stop_googlechrome

(********************************************************
 Function Name:
	main():
	main function that executes screen recording with QuickTime Player
 Arguments:
	None
 Return value:
	None
 Description:
	Record for a specified time with QuickTime Player (start to stop)
	After the specified time has elapsed, recording is completed and QuickTime Player exits to display dialog
********************************************************)
on main()
	set input_num to ask_recording_time()
	if input_num is greater than 0 then
		screen_recording(input_num)
		quit_quicktimeplayer()
		-- stop_googlechrome()
	else
		(display dialog "Please enter a positive integer for the elapsed time.Quit script." buttons {"Cancel", "OK"} default button "OK")
	end if
	log "[main()]Script end"
	return
end main

-- main function call
main()