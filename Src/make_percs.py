import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import imageio
import glob

dat = pd.DataFrame(columns=['vid', 'cooked', 'uncooked', 'perc'])

for key in glob.glob("../Data/masks/logan/ideal/*.png"):
    print(key)
    im = imageio.imread(key)
    frame = np.zeros_like(im[:, :, 0])
    frame[im[:, :, 1] == 128] = 2
    frame[im[:, :, 2] == 128] = 1
    plt.imshow(frame)
    plt.show()
    cooked = np.sum(frame == 1)
    uncooked = np.sum(frame == 2)
    perc = uncooked/(cooked+uncooked)
    vid = key.split("\\")[1].split('.')[0]
    dat = dat.append({'vid': vid, 'cooked': cooked, 'uncooked': uncooked, 'perc': perc}, ignore_index=True)

dat.to_csv('percs_per_frame.csv')
