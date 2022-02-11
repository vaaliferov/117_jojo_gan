#!/usr/bin/env bash

USER=ubuntu
NAME=jojo_gan

DIR=/opt/$NAME
SERVICE_NAME="${NAME}_bot.service"
SERVICE_FILE_PATH=/etc/systemd/system/$SERVICE_NAME

rm -rf $DIR $SERVICE_FILE_PATH
systemctl disable --now $SERVICE_NAME

cat bot.service > $SERVICE_FILE_PATH
sed -i "s/<name>/$NAME/g" $SERVICE_FILE_PATH
sed -i "s/<user>/$USER/g" $SERVICE_FILE_PATH

mkdir $DIR $DIR/env $DIR/models
apt install -y git cmake wget bzip2
apt install -y python3-pip python3-venv
apt install -y libpng-dev python3-opencv
pip3 install -U virtualenv gdown

python3 -m venv $DIR/env
source $DIR/env/bin/activate
pip3 install --no-cache-dir cython wheel
pip3 install --no-cache-dir -r requirements.txt
deactivate

cp -r . $DIR

gdown --id 1a0QDEHwXQ6hE_FcYEyNMuv5r5UnRQLKT -O $DIR/models/art.pt
gdown --id 1o6ijA3PkcewZvwJJ73dJ0fxhndn0nnh7 -O $DIR/models/e4e_ffhq_encode.pt
gdown --id 1ZRwYLRytCEKi__eT2Zxv1IlV6BGVQ_K2 -O $DIR/models/jojo_preserve_color.pt
gdown --id 1Bnh02DjfvN_Wm8c4JdOiNV4q9J7Z_tsi -O $DIR/models/disney_preserve_color.pt
gdown --id 1VmKGuvThWHym7YuayXxjv0fSn32lfDpE -O $DIR/models/supergirl_preserve_color.pt
gdown --id 1jElwHxaYPod5Itdy18izJk49K1nl4ney -O $DIR/models/arcane_jinx_preserve_color.pt
gdown --id 1SKBu1h0iRNyeKBnya_3BBmLr4pkPeg_L -O $DIR/models/jojo_yasuho_preserve_color.pt
gdown --id 1enJgrC08NpWpx2XGBmLt1laimjpGCyfl -O $DIR/models/arcane_multi_preserve_color.pt
gdown --id 1cUTyjU-q98P75a8THCaO545RTwpVV-aH -O $DIR/models/arcane_caitlyn_preserve_color.pt

wget http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2 -O /tmp/p.dat.bz2
bzip2 -dc /tmp/p.dat.bz2 > $DIR/models/dlibshape_predictor_68_face_landmarks.dat

git clone https://github.com/mchong6/JoJoGAN.git $DIR/JoJoGAN
mv $DIR/JoJoGAN/* $DIR && rm -rf $DIR/JoJoGAN

chmod 755 $DIR
chown -R $USER:$USER $DIR

systemctl daemon-reload
systemctl enable --now $SERVICE_NAME