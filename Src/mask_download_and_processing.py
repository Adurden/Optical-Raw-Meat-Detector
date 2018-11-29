# coding: utf-8
import numpy as np
import matplotlib.pyplot as plt
import imageio
im = imageio.imread("./cjp1xbfjbzmg00d40hcqcskvt%2Fcjp1xsx7dzqnd0d40ctsqfbs8.png")
cd Data
im = imageio.read("cjp1xbfjbzmg00d40hcqcskvt%2Fcjp1xsx7dzqnd0d40ctsqfbs8 (1).png")
plt.imshow(im)
im
im = imageio.imread("cjp1xbfjbzmg00d40hcqcskvt%2Fcjp1xsx7dzqnd0d40ctsqfbs8 (1).png")
im
im.unique
np.unique(im)
np.unique(im[:,:,0])
np.unique(im[:,:,1])
np.unique(im[:,:,2])
np.unique(im[:,:,3])
np.unique(im[:,:,3], axis=0)
np.unique(im, axis=0)
np.unique(im, axis=1)
np.unique(im, axis=2)
np.histogramdd(im)
im.reshape(-1,3)
im.reshape(-1,3).shape
np.histogramdd(im.reshape(-1,3))
unique_pixels = np.vstack({tuple(r) for r in im.reshape(-1,4)})
im.rehsape(-1,4)
im.reshape(-1,4)
im.reshape(-1,4).shape
im.shape
np.unique(im.reshape(-1,4),axis=0)
mask = np.zeros_like(im[:,:,0])
masks.shape
mask.shape
mask[im[:,:,0] == 255] = 0
mask[im[:,:,1] == 128] = 1
mask[im[:,:,2] == 128] = 2
plt.imshow(mask)
plt.show()
mask[im[:,:,2] == 128] = 1
mask[im[:,:,1] == 128] = 2
plt.imshow(mask)
plt.show()
import pandas as pd
dat = pd.read_csv(meat.csv)
dat = pd.read_csv("meat.csv")
dat
dat.Label
for i in dat.Label:
    print(i.split(':')[1])
    
for i in dat.Label:
    print(i.split('"')[2])
   
    
for i in dat.Label:
    print(i.split('"')[3])
    
import urllib
urllib.urlretrieve("https://us-central1-labelbox-193903.cloudfunctions.net/superpixel-label-export/cjp1xbfjbzmg00d40hcqcskvt%2Fcjp1xsx7dzqnd0d40ctsqfbs8.lbx?alt=media&token=a39dde3e-012f-4a55-b773-7f746c19c950&format=png&visible=true","test.jpg")
import urllib3
urllib3.urlretrieve("https://us-central1-labelbox-193903.cloudfunctions.net/superpixel-label-export/cjp1xbfjbzmg00d40hcqcskvt%2Fcjp1xsx7dzqnd0d40ctsqfbs8.lbx?alt=media&token=a39dde3e-012f-4a55-b773-7f746c19c950&format=png&visible=true","test.jpg")
import requests
requests.get("https://us-central1-labelbox-193903.cloudfunctions.net/superpixel-label-export/cjp1xbfjbzmg00d40hcqcskvt%2Fcjp1xsx7dzqnd0d40ctsqfbs8.lbx?alt=media&token=a39dde3e-012f-4a55-b773-7f746c19c950&format=png&visible=true")
im_dat = requests.get("https://us-central1-labelbox-193903.cloudfunctions.net/superpixel-label-export/cjp1xbfjbzmg00d40
    ...: hcqcskvt%2Fcjp1xsx7dzqnd0d40ctsqfbs8.lbx?alt=media&token=a39dde3e-012f-4a55-b773-7f746c19c950&format=png&visib
    ...: le=true")
im_dat = requests.get("https://us-central1-labelbox-193903.cloudfunctions.net/superpixel-label-export/cjp1xbfjbzmg00d40hcqcskvt%2Fcjp1xsx7dzqnd0d40ctsqfbs8.lbx?alt=media&token=a39dde3e-012f-4a55-b773-7f746c19c950&format=png&visible=true")
im_data
im_dat
im_dat = requests.get("https://us-central1-labelbox-193903.cloudfunctions.net/superpixel-label-export/cjp1xbfjbzmg00d40hcqcskvt%2Fcjp1xsx7dzqnd0d40ctsqfbs8.lbx?alt=media&token=a39dde3e-012f-4a55-b773-7f746c19c950&format=png&visible=true").content
im_dat
plt.imshow(im_dat)
open('./test','wb').write(im_dat)
open('./test3.png','wb').write(im_dat)
for i,j in zip(dat.Label,dat.:
    url = i.split('"')[3]
    
dat = pd.read_csv("meat.csv")
for i,j in zip(dat.Label,dat.External_ID):
    url = i.split('"')[3]
    im_dat = requests.get(url).content
    open('./masks/{}'.format(j),'wb').write(im_dat)
    
for i,j in zip(dat.Label,dat.External_ID):
    url = i.split('"')[3]
    im_dat = requests.get(url).content
    open('./masks/{}'.format(j),'wb').write(im_dat)
import glob
masks = []
for fname in glob.glob('./masks/ideal_frame*.png'):
    im = imageio.imread(im_file)
    mask = np.zeros_like(im[:, :, 0])
    mask[im[:, :, 1] == 128] = 2
    mask[im[:, :, 2] == 128] = 1
    masks.append(mask)
    
masks = []
for im_file in glob.glob('./masks/ideal_frame*.png'):
    im = imageio.imread(im_file)
    mask = np.zeros_like(im[:, :, 0])
    mask[im[:, :, 1] == 128] = 2
    mask[im[:, :, 2] == 128] = 1
    masks.append(mask)
    
plt.imshow(masks[0])
plt.show()
plt.imshow(masks[10])
plt.show()
plt.imshow(masks[20])
plt.imshow(masks[19])
plt.show()
masks = []
for im_file in glob.glob('./masks/ideal_frame*.png'):
    print(im_file)
    im = imageio.imread(im_file)
    mask = np.zeros_like(im[:, :, 0])
    mask[im[:, :, 1] == 128] = 2
    mask[im[:, :, 2] == 128] = 1
    masks.append(mask)
    
masks = []
for im_file in glob.glob('./masks/ideal_frame*.png'):
    print(im_file)
    im = imageio.imread(im_file)
    mask = np.zeros_like(im[:, :, 0])
    mask[im[:, :, 1] == 128] = 2
    mask[im[:, :, 2] == 128] = 1
    masks.append(mask)
    
plt.imshow(masks[19])
plt.show()
masks = np.array(masks)
masks.shape
np.save('ideal_masks.npy',masks)
masks = []
for im_file in glob.glob('./masks/nonideal_frame*.png'):
    print(im_file)
    im = imageio.imread(im_file)
    mask = np.zeros_like(im[:, :, 0])
    mask[im[:, :, 1] == 128] = 2
    mask[im[:, :, 2] == 128] = 1
    masks.append(mask)
    
masks = np.array(masks)
np.save('nonideal_masks.npy',masks)
%save mask_download_and_processing
%save ./mask_download_and_processing
%save -f ./mask_download_and_processing
%save -f ./mask_download_and_processing.py
%save -r ./mask_download_and_processing.py 1-100
