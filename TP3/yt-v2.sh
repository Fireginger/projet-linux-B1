while true
do
    n=0
    while read -r line; do
        if [[ "$line" =~ "https://www.youtube.com/watch?="* ]]; then
            video_name=$(youtube-dl --get-title $line)
            youtube-dl -o "/srv/yt/downloads/$video_name/%(title)s.%(ext)s" $line > /dev/null
            youtube-dl --get-description $line >> "/srv/yt/downloads/$video_name/description"
            echo "Video $line was downloaded."
            echo "File path : /srv/yt/downloads/$video_name/$video_name.mp4"
            echo "[$(date '+%D %T')] Video $line was downloaded. File path : /srv/yt/downloads/$video_name/$video_name.mp4" >> "/var/log/yt/download.log"
        fi
        : $((n++))
    done < /srv/yt/urls.txt
    if [ $n -gt 0 ]; then
        sed -i "1,$n d" /srv/yt/urls.txt
    fi
 sleep 10
done
