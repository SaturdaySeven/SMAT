# SMAT
Simple Multithreaded Audio Transcoder

## Features
* Copies embedded album artwork to output folders
* Formats folder names based on audio metadata (Artist - Album (Year) [FORMAT])
* Multithreaded
* Torrent creation (optional)
* Transcodes from FLAC & MP3
* Transcodes to 16-bit FLAC, MP3 320 kbps, and MP3 V0 (as is logically permittable)
* Retains metadata on transcoded audio files

## Dependencies
* Bash
* FFmpeg 
* mktorrent (optional)
* Parallel

## Installation & Usage
1. Download the script (via the method of your choice):
	* Right click and save as: [https://raw.githubusercontent.com/SaturdaySeven/SMAT/master/smat.sh](https://raw.githubusercontent.com/SaturdaySeven/SMAT/master/smat.sh)
	* `wget 'https://raw.githubusercontent.com/SaturdaySeven/SMAT/master/smat.sh'`
	* `curl 'https://raw.githubusercontent.com/SaturdaySeven/SMAT/master/smat.sh' > smat.sh`
	* `git clone https://github.com/SaturdaySeven/SMAT.git && cd smat`
2. Make the script executable:

`chmod +x smat.sh`

3. (Optional) Edit lines 3 & 4 of the script to enable torrent creation.
```
maketorrents=true
announceurl="https://your.url.here"
```
4. Copy the script to a folder containing audio files and run the script. In this case, `~/music/Joe Ressington/Noise With Guitars/` is the directory containing music:
```
cp smat.sh ~/music/Joe Ressington/Noise\ With\ Guitars/
cd ~/music/Joe Ressington/Noise\ With\ Guitars/
./smat.sh
```

---

Audio transcodes are exported to `./output/Artist - Album (Year) [FORMAT]/`. A new directory will be created for each audio format.

Torrent files are exported to `./output/Artist - Album (Year) [FORMAT].torrent`.
