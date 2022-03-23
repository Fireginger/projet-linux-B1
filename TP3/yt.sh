youtube_video_url="$1"
video_name=$(youtube-dl --get-title $youtube_video_url)
youtube-dl -o "/srv/yt/downloads/$video_name/%(title)s.%(ext)s" $youtube_video_url > /dev/null
youtube-dl --get-description $youtube_video_url >> "/srv/yt/downloads/$video_name/description"

echo "Video $youtube_video_url was downloaded."
echo "File path : /srv/yt/downloads/$video_name/$video_name.mp4"
echo "[$(date '+%D %T')] Video $youtube_video_url was downloaded. File path : /srv/yt/downloads/$video_name/$video_name.mp4" >> "/var/log/yt/download.log"
