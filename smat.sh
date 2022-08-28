#!/bin/bash

maketorrents=false
announceurl="https://your.url.here"

files=(*)

flac24_to_flac16 () {
	[ ! -d "output/FLAC16" ] && mkdir -p "output/FLAC16"
	echo "###Transcoding to FLAC 16###"
	parallel ffmpeg -loglevel error -i {} -sample_fmt s16 -ar 48000 ./output/FLAC16/{.}.flac ::: ./*.flac
	cp cover.jpg output/FLAC16
	if [ $maketorrents = true ]
	then
		mktorrent -l 19 -p -s RED -a $announceurl "./output/FLAC16/" -o "./output/$artist - $album ($date) [FLAC 16/48].torrent" > /dev/null
	fi
}

flac16_to_320 () {
	echo "###Transcoding to MP3 320###"
	[ ! -d "output/320" ] && mkdir -p "output/320"
	parallel ffmpeg -loglevel error -i {} -ab 320k "output/320/{.}.mp3" ::: ./*.flac
	cp cover.jpg output/320
	if [ $maketorrents = true ]
	then
		mktorrent -l 19 -p -s RED -a $announceurl "./output/320/" -o "./output/$artist - $album ($date) [MP3 320].torrent" > /dev/null
	fi
}

flac16_to_v0 () {
	[ ! -d "output/V0" ] && mkdir -p output/V0
	echo "###Transcoding to MP3 V0###"
	parallel ffmpeg -loglevel error -i {} -qscale:a 0 ./output/V0/{.}.mp3 ::: ./*.flac
	cp cover.jpg output/V0
	if [ $maketorrents = true ]
	then
		mktorrent -l 19 -p -s RED -a $announceurl "./output/V0/" -o "./output/$artist - $album ($date) [MP3 V0].torrent" > /dev/null
	fi
}

320_to_v0 () {
	[ ! -d "output/V0" ] && mkdir -p output/V0
	echo "###Transcoding to MP3 V0###"
	parallel ffmpeg -loglevel error -i {} -qscale:a 0 ./output/V0/{.}.mp3 ::: ./*.mp3
	cp cover.jpg output/V0
	if [ $maketorrents = true ]
	then
		mktorrent -l 19 -p -s RED -a $announceurl "./output/V0/" -o "./output/$artist - $album ($date) [MP3 V0].torrent" > /dev/null
	fi
}

rename_folders () {
	[ -d "output/FLAC16" ] && mkdir "output/$artist - $album ($date) [FLAC 16/48]/" && mv output/FLAC16/* "output/$artist - $album ($date) [FLAC 16/48]/"
	[ -d "output/320" ] && mkdir "output/$artist - $album ($date) [MP3 320]/" && mv output/320/* "output/$artist - $album ($date) [MP3 320]/"
	[ -d "output/V0" ] && mkdir "output/$artist - $album ($date) [MP3 V0]" && mv output/V0/* "output/$artist - $album ($date) [MP3 V0]/"
	rm -rf output/FLAC16
	rm -rf output/320
	rm -rf output/V0
}

get_metadata () {
	artist=$(ffprobe -v quiet -of json -show_entries format_tags "${files[0]}" | jq -r .format.tags.ARTIST)
	if [[ ! $artist = "null" ]]
	then
		album=$(ffprobe -v quiet -of json -show_entries format_tags "${files[0]}" | jq -r .format.tags.ALBUM)
		date=$(ffprobe -v quiet -of json -show_entries format_tags "${files[0]}" | jq -r .format.tags.DATE)
	else
		artist=$(ffprobe -v quiet -of json -show_entries format_tags "${files[0]}" | jq -r .format.tags.artist)
		album=$(ffprobe -v quiet -of json -show_entries format_tags "${files[0]}" | jq -r .format.tags.album)
		date=$(ffprobe -v quiet -of json -show_entries format_tags "${files[0]}" | jq -r .format.tags.date)
	fi
}

get_metadata
echo "Transcoding $artist - $album ($date)"

ffmpeg -loglevel error -i "${files[0]}" -an -vcodec copy cover.jpg
codec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "${files[0]}")
if [ $codec = "flac" ]
then
	bitdepth=$(ffprobe -v error -select_streams a:0 -show_entries stream=bits_per_raw_sample -of default=noprint_wrappers=1:nokey=1 "${files[0]}")
	if [ $bitdepth = 24 ]
	then
		flac24_to_flac16
		flac16_to_320
		flac16_to_v0
	elif [ $bitdepth = 16 ]
	then
		flac16_to_320
		flac16_to_v0
	fi
elif [ $codec = "mp3" ]
then
	mp3_bitrate=$(ffprobe -v quiet -of json -show_streams -select_streams a "files[0]}" | jq -r .streams[].bit_rate)
	if [ $mp3_bitrate = 320000 ]
	then
		320_to_v0
	else
		echo "MP3 has invalid bitrate."
	fi
fi

rename_folders
rm cover.jpg
