import os
import telegram
import PIL.Image
import numpy as np
import telegram.ext
import torch, torchvision
import util, model, e4e_projection
from secret import *

def load_generator(path):
    generator = model.Generator(1024, 512, 8, 2).to('cpu')
    ckpt = torch.load(path, map_location=lambda storage, loc: storage)
    generator.load_state_dict(ckpt['g'], strict=False)
    generator.eval()
    return generator

def generate_sample(w, g, path):
    s = g(w.unsqueeze(0), input_is_latent=True)
    s = s.squeeze(0).permute(1,2,0).detach().numpy()
    smin, smax = s.min(), s.max()
    s = (s - smin) / (smax - smin)
    s = (s * 255).astype(np.uint8)
    PIL.Image.fromarray(s).save(path)

torch.manual_seed(3000)
torch.set_grad_enabled(False)

ms = os.listdir('models')
ms.remove('e4e_ffhq_encode.pt')
ms.remove('dlibshape_predictor_68_face_landmarks.dat')
gs = [load_generator(f'models/{m}') for m in ms]

def handle_photo(update, context):
    user = update.message.from_user
    file_id = update.message.photo[-1]['file_id']
    context.bot.getFile(file_id).download('in.jpg')
    context.bot.send_message(user['id'], 'please, wait (~1min)')
    
    if user['id'] != TG_BOT_OWNER_ID:
        msg = f"@{user['username']} {user['id']}"
        context.bot.send_message(TG_BOT_OWNER_ID, msg)
    
    aligned_face = util.align_face('in.jpg')
    w = e4e_projection.projection(aligned_face, 'm.pt', 'cpu')
    
    os.makedirs('out', exist_ok=True)
    aligned_face.save('out/00.jpg')
    
    for i, g in enumerate(gs):
        generate_sample(w, g, f'out/{i+1:02}.jpg')
    
    fds = [open(f'out/{im}', 'rb') for im in os.listdir('out')]
    mps = [telegram.InputMediaPhoto(fd) for fd in fds]
    update.message.reply_media_group(media=mps[:10])
    for fd in fds: fd.close()

f = telegram.ext.Filters.photo
h = telegram.ext.MessageHandler
u = telegram.ext.Updater(TG_BOT_TOKEN)
u.dispatcher.add_handler(h(f,handle_photo))
u.start_polling(); u.idle()