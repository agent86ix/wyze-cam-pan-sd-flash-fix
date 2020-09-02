# wyze-cam-pan-sd-flash-fix

An update file (for use with [WyzeUpdater](https://github.com/HclX/WyzeUpdater)) that fixes a bootloader issue with certain Wyze Cam Pan models that keeps them from being able to flash firmware from the SD card.

## WARNING: READ CAREFULLY

This script takes (what I consider to be) appropriate precautions, but since it flashes your bootloader, there is a non-zero chance it will brick your camera.  The only way to recover from this state would be to desolder the flash chip and program it manually.  By using this software, you understand and accept the risk of this issue happening to you.  

# Usage

## Quick Install

- Set up the camera and pair it with the Wyze app.  
- Verify that the Wyze app shows it as online.
- A SD card is required!  Insert an SD card into the camera (used for backing up the previous bootloader image).
- Follow the instructions to set up [WyzeUpdater](https://github.com/HclX/WyzeUpdater) so that it can find your camera in `wyze_updater.py list`. 

Then you can download the latest release of the binary bundle [from this page](https://github.com/agent86ix/wyze-cam-pan-sd-flash-fix/releases), and tell WyzeUpdater to push it to your camera.  The instructions may vary if WyzeUpdater changes, but as of this writing:

```
python wyze_updater.py update -p 18080 -d $CAMERA_MAC -f path/to/pan-fix.tar
```

This will start a small web server on your machine, and then attempt to trigger the same update flow as the app on your camera.  You should see a couple of requests printed from the camera, (one ending in `firmware.bin`).  Afterwards, the camera should reboot shortly after.  Once it has, you can exit (Ctrl-C) the WyzeUpdater program.  Otherwise, it will run forever.

I am not the author of [WyzeUpdater](https://github.com/HclX/WyzeUpdater) so I'm not the best person to ask for support if you have trouble running the tool.  If you have issues serving this update file to a particular model camera or a particular firmware revision, I may or may not be able to help.

## Advanced Usage

**WARNING**: Do not modify the tar file unless you are **very sure** you know what you are doing.  The binary file inside the tar file is NOT a `demo.bin` image.  It is a bootloader image.  Replacing it with something that is not a bootloader binary (ie, `demo.bin`) will **brick your unit.**

The binary bundle is a simple .tar file of the `Upgrade` directory in this repository.  You can modify the script, change the bootloader image, etc.  However, the `Upgrade/upgraderun.sh` script is the main entry point for the app-based updater, and the `Upgrade/PARA` file appears to be mandatory.  

When you're done making modifications, just tar it up again:

```
tar -cvf pan-fix.tar Upgrade/
```

# FAQ

## How do I know if I have an impacted camera?

According to [this thread on the Wyze forums](https://forums.wyzecam.com/t/cant-flash-firmware-to-cam-pan/95238) the impacted cameras have a QR code on the back of the camera (and the box) that contains the substring `F00`.  There may be other variants of the camera that are also impacted.

The symptoms of this issue are that even if you properly [follow the instructions for manually flashing](https://support.wyzecam.com/hc/en-us/articles/360031490871-How-to-flash-firmware-manually), the camera will reboot quickly after the flash process starts, and will still have the same firmware version it had before.

## Does this "hack" my camera?

The short answer is "No."  The longer answer is "Well, not really."

This doesn't install any 3rd party software (ie, this does *not* install [Dafang Hacks](https://github.com/EliasKotlyar/Xiaomi-Dafang-Hacks)) on your camera.  It simply installs another official Wyze bootloader, one taken from a Wyze Cam v2, supplied by @tachang as part of [openmiko.](https://github.com/openmiko/openmiko/blob/master/stock_firmware/wyzecam_v2/wyzecam_v2_stock_bootloader.bin).  I have confirmed that this is the same bootloader image (same md5sum) as an older Wyze Cam Pan that did not have this issue.

Once this "fix" has been applied, you should be able to flash any Wyze firmware or any compatible "hacked" firmware using the "`demo.bin` on the SD card" method.

## What could possibly go wrong?

- If the update process isn't allowed to complete, the bootloader may be left in a corrupt state.  This will keep your camera from booting.  The only fix would be to desolder the flash chip and reprogram it manually.  (Probably not worth the effort for most users...)
- If you use this on the wrong model of camera (ie, if at some point Wyze quietly changes the hardware to something incompatible), then this script might flash an incompatible bootloader to your device, thereby stopping it from booting.

## How do I know that the operation is complete?

The flash is very fast, as it is only erasing/rewriting 256k of data.  The camera reboots itself at the end of the upgrade, so when it comes back up on your WiFi, the operation is done.

## The camera still boots, but it doesn't seem like the fix worked!

The update process writes 2 files to the SD card.  (You did put a FAT32 formatted SD card in the camera, right?)  One file is a backup of the old bootloader.  The other is a log file.  

- The log file may have clues as to what went wrong.  
- If you copy the old bootloader off the card and repeat the update process, you should end up with an identical bootloader to the one in the Update directory.  If that's the case, the bootloader flash was successful, and your issue is likely elsewhere.

## I'm on Windows, how do I Python?

I'm probably the wrong person to ask about this, since all the Python code belongs to HclX's WyzeUpdater tool.  It is possible to use this tool on Windows, but you will have to install Python (and probably run `pip install` to get the packages WyzeUpdater requires).  

# Technical Details

It appears that some Wyze Cam Pan units shipped from the factory with a bootloader that is incapable of flashing even official Wyze firmware binaries from their website.  Despite having the same flashing instructions as other Wyze cameras (including other Pans), these units can't accept a firmware file if it is placed on the SD card.  However, the in-app updater works, presumably because it uses a different system for flashing.  

After disassembling my camera and soldering the serial headers, I discovered that regardless of the `demo.bin`, the bootloader's flash routine consistently failed.  With a combination of assistance from the Gitter chat room for Dafang Hacks, a fair bit of experimentation, and [comments on my issue](https://github.com/EliasKotlyar/Xiaomi-Dafang-Hacks/issues/1563), I learned that:

- WyzeUpdater can push an update request to the camera
- The app-based updater doesn't use the same `demo.bin` structure that the SD-card based updater uses
- The app-based updater has a specific tar file structure that it uses, but in the end it executes a simple shell script
- I could intercept the URL that the app pushes to the camera, and inspect its structure
- Others had already dumped a "good" bootloader, and documented the process for flashing it

From here, it was pretty straightforward to craft an update package that could be used to replace the "broken" bootloader.
