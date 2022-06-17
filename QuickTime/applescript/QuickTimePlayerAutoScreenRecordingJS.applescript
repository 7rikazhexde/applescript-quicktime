/********************************************************
 Summary:
	Using the screen recording function of QuickTime Player on MacOS 
	JavaScript for Automation(JXA) to record the screen at a specified time

 SupportVersion:
	macOS Monterey(version 12.4)
	QuickTime Player(version 10.5)

 Usage:
	1.QuickTime Player settings
		Select 'Record Selection' and set the area you want to record and 
		Set the area you want to record and the location where 
		you want to save the file (Options¨Destination).
	2.Set the recording time
		Enter the recording time in the dialog that appears after startup.
		ex)3600(seconds) = 60(minutes) = 1(hour)
		Recording time depends on the process and 
		may deviate by a few seconds to a few tens of seconds.
		Set the recording time to a value larger than the desired recording time.
		 
 reference
	1.JavaScript for Automation Release Notes
	https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/Introduction.html#//apple_ref/doc/uid/TP40014508-CH111-SW1
	2.Mac : JavaScript for Automation (JXA) —á•¶Ž«“T
	http://www.openspc2.org/reibun/JXA/Yosemite/
	3.JavaScript for Automation (JXA)
	http://tonbi.jp/AppleScript/JavaScript/
	4.JavaScript for Automation Cookbook
	https://github.com/JXA-Cookbook/JXA-Cookbook/wiki/
********************************************************/


/******************************************************** 
 Function Name:
	ask_recording_time():
	Function to enter recording time
 Arguments:
	None
 Return value:
	response.textReturned: recording time
 Description:
	Returns only the value entered as a number as the recording time
********************************************************/
function ask_recording_time(){
	var app = Application.currentApplication()
	app.includeStandardAdditions = true
 	var str_check = true;
	
	// Non-numeric repetition
	while(str_check == true){
		var response = app.displayDialog("Please enter the recording time(sec)", {
    	defaultAnswer: "",
    	withIcon: "note",
   		buttons: ["Cancel", "OK"],
    	defaultButton: "OK"
		})
	
		if(!(isNaN(response.textReturned))){
			// If it's a number, it exits the loop
			str_check = false;
		}

		if(response.buttonReturned == "Cancel"){
			app.displayAlert('Pushed cancel button. Quit script.');
			app.quit()
		}
	}
	console.log('[ask_recording_time()]Recording time%isec', response.textReturned);
	return response.textReturned
}

/********************************************************
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
********************************************************/
function quicktimeplayer_runnning_check(){
	var qtRunningFlag = false;
	var qt = Application('QuickTime Player')
	if (qt.running()){
		qtRunningFlag = true;
	}
	else{
		qtRunningFlag = false;
	}
	return qtRunningFlag;
}

/********************************************************
 Function Name:
 	quicktimeplayer_play_multiscreens()
	Function to determine if QuickTime Player playback process has been executed
 Arguments:
	None
 Return value:
	true:QuickTime Player playback processing was executed
	false: QuickTime Player playback processing could not be executed
 Description:
	Obtain the number of elements from the document class and 
	if the number of elements is not zero, execute the playback process.
********************************************************/
function quicktimeplayer_play_multiscreens(){
	var qt = Application('QuickTime Player')
	var qtActiveScreenFlag = false;
	qt.activate();
	var screen_num = qt.documents.length;
	console.log('[quicktimeplayer_play_multiscreens()]Number of screens:%i',screen_num);
	if (screen_num != 0){
		qtActiveScreenFlag = true
		// Enable loop
		qt.document.looping = true;
		qt.document.play();
	}
	return qtActiveScreenFlag;
}

/********************************************************
 Function name:
	screen_recording(input_time):
	Screen recording processing function
 Arguments
	input_num: time to record
 Return value:
	None
 Description:
	A shortcut key input from System Events launches the screenshot toolbar and starts recording.
	The elapsed time to be recorded is obtained from the data object calculated, and set.
	After the recording time has elapsed, 
	recording is stopped by inputting a shortcut key in the same way as for the start of recording.
********************************************************/
function screen_recording(input_time){
	var sys = Application('System Events');
	// command+shift+5
	sys.keyCode('23', { using: ['command down', 'shift down']});
	delay(0.5);
	// return
	sys.keyCode('36');
	console.log('[screen_recording()]Recording start')
	
	const startTime = Date.now();
	delay(input_time);
	const elapsedTime = (Date.now() - startTime) / 1000;
	
	// command+control+esc
	sys.keyCode('53', { using: ['command down', 'control down']});
	console.log('[screen_recording()]Recording end:Elapsed time%isec', elapsedTime);
	return
}

/******************************************************** 
 Function Name:
	quit_quicktimeplayer():
	Function to quit QuickTime Player
 Arguments:
	None
 Return value:
	None
 Description:
	Exit QuickTime Player with the quit command
********************************************************/
function quit_quicktimeplayer(){
	var qt = Application('QuickTime Player')
	console.log('[quit_quicktimeplayer()]QuickTime Player quit');
	qt.quit()
	return
}

/******************************************************** 
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
********************************************************/
function main(){
	var input_num = ask_recording_time()
	var app = Application.currentApplication();
	app.includeStandardAdditions = true;
		
	if(input_num > 0){
		console.log(input_num)
		screen_recording(input_num);
		quit_quicktimeplayer();
		app.displayAlert('Screen recording is complete. Quit script.');
		console.log('[main()]Script end')
	}
	else{
		app.displayAlert('Please enter a positive integer for the elapsed time.€n Quit script.');
	}
	return
}

//main function call
main()