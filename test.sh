#!/bin/bash
# set up a variable of the input video from $1 
INPUT_VIDEO=$1

# if there is a second argument, then we will use the second argument as the number of speakers
if [ $# -eq 2 ]
then
    NUM_SPEAKERS=$2
else
    NUM_SPEAKERS="1"
fi

ffmpeg -i ./test_videos/${INPUT_VIDEO}.mp4 -filter:v fps=fps=25 ./test_videos/${INPUT_VIDEO}25fps.mp4
mv ./test_videos/${INPUT_VIDEO}25fps.mp4 ./test_videos/${INPUT_VIDEO}.mp4
python ./utils/detectFaces.py --video_input_path ./test_videos/${INPUT_VIDEO}.mp4 --output_path ./test_videos/${INPUT_VIDEO}/ --number_of_speakers ${NUM_SPEAKERS} --scalar_face_detection 1.5 --detect_every_N_frame 8
ffmpeg -i ./test_videos/${INPUT_VIDEO}.mp4 -vn -ar 16000 -ac 1 -ab 192k -f wav ./test_videos/${INPUT_VIDEO}/${INPUT_VIDEO}.wav
python ./utils/crop_mouth_from_video.py --video-direc ./test_videos/${INPUT_VIDEO}/faces/ --landmark-direc ./test_videos/${INPUT_VIDEO}/landmark/ --save-direc ./test_videos/${INPUT_VIDEO}/mouthroi/ --convert-gray --filename-path ./test_videos/${INPUT_VIDEO}/filename_input/${INPUT_VIDEO}.csv
./


python testRealVideo.py \
--mouthroi_root ./test_videos/${INPUT_VIDEO}/mouthroi/ \
--facetrack_root ./test_videos/${INPUT_VIDEO}/faces/ \
--audio_path ./test_videos/${INPUT_VIDEO}/${INPUT_VIDEO}.wav \
--weights_lipreadingnet pretrained_models/lipreading_best.pth \
--weights_facial pretrained_models/facial_best.pth \
--weights_unet pretrained_models/unet_best.pth \
--weights_vocal pretrained_models/vocal_best.pth \
--lipreading_config_path configs/lrw_snv1x_tcn2x.json \
--num_frames 64 --audio_length 2.55 --hop_size 160 --window_size 400 --n_fft 512 \
--unet_output_nc 2 --normalization --visual_feature_type both \
--identity_feature_dim 128 --audioVisual_feature_dim 1152 --visual_pool maxpool --audio_pool maxpool --compression_type none \
--reliable_face --audio_normalization --desired_rms 0.058 --number_of_speakers ${NUM_SPEAKERS} --mask_clip_threshold 5 --hop_length 2.55 --lipreading_extract_feature --number_of_identity_frames 1 \
--output_dir_root ./test_videos/${INPUT_VIDEO}/
