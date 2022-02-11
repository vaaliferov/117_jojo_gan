#!/usr/bin/env bash

apt install -y git cmake wget bzip2
apt install -y python3-pip python3-venv
apt install -y libpng-dev python3-opencv
pip3 install --no-cache-dir cython wheel gdown
pip3 install --no-cache-dir -r requirements.txt

mkdir models

gdown --id 1a0QDEHwXQ6hE_FcYEyNMuv5r5UnRQLKT -O models/art.pt
gdown --id 1o6ijA3PkcewZvwJJ73dJ0fxhndn0nnh7 -O models/e4e_ffhq_encode.pt
gdown --id 1ZRwYLRytCEKi__eT2Zxv1IlV6BGVQ_K2 -O models/jojo_preserve_color.pt
gdown --id 1Bnh02DjfvN_Wm8c4JdOiNV4q9J7Z_tsi -O models/disney_preserve_color.pt
gdown --id 1VmKGuvThWHym7YuayXxjv0fSn32lfDpE -O models/supergirl_preserve_color.pt
gdown --id 1jElwHxaYPod5Itdy18izJk49K1nl4ney -O models/arcane_jinx_preserve_color.pt
gdown --id 1SKBu1h0iRNyeKBnya_3BBmLr4pkPeg_L -O models/jojo_yasuho_preserve_color.pt
gdown --id 1enJgrC08NpWpx2XGBmLt1laimjpGCyfl -O models/arcane_multi_preserve_color.pt
gdown --id 1cUTyjU-q98P75a8THCaO545RTwpVV-aH -O models/arcane_caitlyn_preserve_color.pt

wget http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2 -O /tmp/p.dat.bz2
bzip2 -dc /tmp/p.dat.bz2 > models/dlibshape_predictor_68_face_landmarks.dat

git clone https://github.com/mchong6/JoJoGAN.git JoJoGAN
mv JoJoGAN/* ./ && rm -rf JoJoGAN