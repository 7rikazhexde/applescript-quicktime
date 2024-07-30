# show-grid-quicktime

AppleScript for arranging video files stored in specified folders in a grid format.

## Demo

![show_grid_quicktime.gif](.demofile/show_grid_quicktime.gif)

## Usage

1. Open `show_grid_quicktime.applescript` in ScriptEditer or VScode
2. Adjustable parameters settings
See `Adjustable parameters`.  
Then activate the parameters for the file size you want to use from "Configuration for video".
3. Run script and check result

## Note:

- Target files are `mov` and `mp4`.
- This script supports the following file sizes.
  - 640x360 (reduced to 320x180)
  - 640x360
  - 486x360 (reduced to 243x180)
- Other sizes can be supported by changing the `Adjustable parameters`, but the parameters need to be adjusted.
- This script supports the process of launching and playing video files.  
Comment out `playAllVideosSimultaneously()` if you do not need the playback process.
