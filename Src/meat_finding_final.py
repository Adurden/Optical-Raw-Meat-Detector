import argparse
import joblib
from functools import partial
import os
import numpy as np
import skimage.morphology as morph
from scipy.signal import argrelextrema
import imageio


def meat_find(im_file, convex_hull=False, min_seed=40, max_seed=200):
    im = imageio.imread(im_file)
    key = im_file.split(os.path.sep)[-1].split(".")[0]

    im_RLG = im[:, :, 0] - (im[:, :, 1])  # Re-encode to Red Less Green
    y, x = np.histogram(im_RLG.flatten(), bins=125)  # create histogram
    minm = argrelextrema(y, np.less)  # find local minima
    # Find upper and lower thresholds using seed values
    low_t = x[minm][(np.abs(x[minm] - min_seed)).argmin()]
    high_t = x[minm][(np.abs(x[minm] - max_seed)).argmin()]

    # create threshold masks
    im_RLG[im_RLG < low_t] = 0
    im_RLG[im_RLG > high_t] = 0
    im_RLG[im_RLG > 0] = 1

    # connected components filtering 1/5 the size of the largest
    im_RLG = morph.label(im_RLG)  # creates connected components
    v, c = np.unique(im_RLG.flat, return_counts=True)  # get object sizes
    im_RLG = im_RLG != 0
    im_RLG = morph.remove_small_objects(im_RLG,
                                        min_size=np.max(c[1:])/5)
    if(convex_hull):
        im_RLG = morph.convex_hull_image(im_RLG)
    return(key, im_RLG.astype(int))


if __name__ == "__main__":
    cwd = os.getcwd()
    parser = argparse.ArgumentParser(
        description=('Reading frames and return meat masks.'),
        add_help='How to use', prog='meat_finding_final.py <args>')

    # Required arguments.
    parser.add_argument("-i", "--input", required=True,
                        help="Path to a image file or directory of frames.")

    # Optional arguments.
    parser.add_argument("-o", "--output", default=os.path.join(cwd, "masks"),
                        help=("Destination path for masks."
                              " [DEFAULT: cwd]"))
    parser.add_argument("-x", "--max_seed", default=200,
                        help=("max threshold seed."
                              " [DEFAULT: 200]"))
    parser.add_argument("-n", "--min_seed", default=40,
                        help=("min threshold seed."
                              " [DEFAULT: 40]"))
    parser.add_argument("-c", "--convex_hull", action="store_true",
                        help=("If set, convex_hull will be applied"
                              " [DEFAULT: False]"))
    parser.add_argument("--n_jobs", type=int, default=-1,
                        help=("Degree of parallelism for reading in videos. -1"
                              " is all cores. [DEFAULT -1]"))
    args = vars(parser.parse_args())
    if not os.path.exists(args['output']):
        os.mkdir(args['output'])

    if os.path.isdir(args['input']):
        files = filter(lambda x: x.split(".")[-1] in ["png", 'jpg', 'jpeg'],
                       os.listdir(args['input']))
        prefix = partial(os.path.join, args['input'])
        vidpaths = list(map(prefix, files))
    else:
        vidpaths = [args['input']]

    # Spawn parallel jobs to read the videos in the directory listing.
    out = joblib.Parallel(n_jobs=args['n_jobs'], verbose=10)(
        joblib.delayed(meat_find)
        (v, convex_hull=args['convex_hull'], min_seed=args['min_seed'],
         max_seed=args['max_seed'])
        for v in vidpaths
    )

    # Write the files out.
    for key, vid in out:
            fname = "{}_mask.png".format(key)
            outfile = os.path.join(args['output'], fname)
            imageio.imwrite(outfile, vid)
