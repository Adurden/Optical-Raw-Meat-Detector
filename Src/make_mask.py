import numpy as np
import imageio
import requests
import pandas as pd


def make_mask(im_file):
    im = imageio.imread(im_file)
    mask = np.zeros_like(im[:, :, 0])
    mask[im[:, :, 1] == 128] = 2
    mask[im[:, :, 2] == 128] = 1

    return mask


def download_ims(labelbox_csv):
    dat = pd.read_csv(labelbox_csv)
    for i, j in zip(dat.Label, dat.External_ID):
        url = i.split('"')[3]
        im_dat = requests.get(url).content
        open('./masks/{}'.format(j), 'wb').write(im_dat)
