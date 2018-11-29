import imageio
import numpy as np
import matplotlib.pyplot as plt
import matplotlib


def read_video(vidfile, read_every=900, format="ffmpeg"):
    vidcap = imageio.get_reader(vidfile, format=format, mode="I")
    key = vidfile.split("/")[-1].split(".")[0]

    frames = []
    for index, frame in enumerate(vidcap):
        if index % 900 > 0:
            continue

        # fix for ffmpeg issue on Andrew's compututer
        frame2 = np.copy(frame)
        frame2[:, vid3.shape[1]-51:vid3.shape[1]] = frame[:, 0:51]
        frame2[:, 0:vid3.shape[1]-50] = frame[:, 50:]

        # reorder channels in correct order
        frame = np.copy(frame2)
        frame[:, :, 0] = frame2[:, :, 1]
        frame[:, :, 1] = frame2[:, :, 2]
        frame[:, :, 2] = frame2[:, :, 0]
        print(index)
        frames.append(skimage.img_as_ubyte(frame))

    vid = np.array(frames)
    return(key, vid)


if __name__ == "__main__":
    cwd = os.getcwd()
    parser = argparse.ArgumentParser(
        description=('Reading frames of all videos in a specific directory'
                     ' and saving them as png files.'),
        add_help='How to use', prog='read_video.py <args>')

    # Required arguments.
    parser.add_argument("-i", "--input", required=True,
                        help="Path to a video file or directory of videos.")

    # Optional arguments.
    parser.add_argument("-o", "--output", default=os.path.join(cwd, "videos"),
                        help=("Destination path for extracted frames."
                              " [DEFAULT: cwd]"))
    parser.add_argument("-s", "--skipframes", default=100,
                        help=("Number of frames to skip (downsample) when "
                              "reading videos. [DEFAULT: 100]"))
    parser.add_argument("-f", "--formatpng", action="store_true",
                        help=("If set, frames are saved as pngs"
                              " instead of as npy image stream."
                              " [DEFAULT: False]"))
    parser.add_argument("--n_jobs", type=int, default=-1,
                        help=("Degree of parallelism for reading in videos. -1"
                              " is all cores. [DEFAULT -1]"))
    args = vars(parser.parse_args())
    if not os.path.exists(args['output']):
        os.mkdir(args['output'])

    if os.path.isdir(args['input']):
        files = filter(lambda x: x.split(".")[-1] in ["npy"],
                       os.listdir(args['input']))
        prefix = partial(os.path.join, args['input'])
        vidpaths = list(map(prefix, files))
    else:
        vidpaths = [args['input']]

    # Spawn parallel jobs to read the videos in the directory listing.
    out = joblib.Parallel(n_jobs=args['n_jobs'], verbose=10)(
        joblib.delayed(read_video)
        (v, read_every=args['skipframes'])
        for v in vidpaths
    )

    # Write the files out.
    for key, vid in out:
        if args['formatpng']:
            for i in range(vid.shape[0]):
                fname = "{}_frame{}.png".format(key, i)
                outfile = os.path.join(args['output'], fname)
                imageio.imwrite(outfile, vid)
        else:
            fname = "{}.npy".format(key)
            outfile = os.path.join(args['output'], fname)
            np.save(outfile, vid)
