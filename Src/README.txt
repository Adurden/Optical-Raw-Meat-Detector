========================================
|             OpenCVSwift              |
========================================

REQUIREMENTS:
   - Macbook
   - Xcode 10.*
   - iPhone (if you want to try out the real-time beta)

HOW TO RUN:
   - Open OpenCVSwift/OpenCVSwift.xcodeproj
   - Change your emulator device to an iPhone 8 Plus or to your connected iPhone (top right corner next to Stop button)
   - Press Run in the top right corner
   - By default, the project is setup to demo our test data using our channel re-encoding algorithm. You can enumerate through our test data by tapping the image.
   - To change the algorithm on the test data, go to line 150 in OpenCamera.mm and comment/uncomment the desired algorithm.
   - To switch to the real-time beta using the iPhone camera, go to line 29 in ViewController.swift and switch cameraMode to true.
   - The real-time beta uses the same algorithms as the test cases. To switch the algorithm on the real-time beta, go to line 494 in OpenCamera.mm comment/uncomment the desired algorithm.

QUESTIONS?
jahnke@uga.edu

==============================================
|           meat_finding_final.py             |
==============================================

REQUIREMENTS:
  - Python 3.*
    - argparse 1.1
    - joblib 0.12.5
    - numpy 1.14.3
    - skimage 0.13.1
    - scipy 1.1.0
    - imageio 2.3.0

HOW TO RUN:
  - in terminal "python meat_finding_final.py [flags]"
  HELP MESSAGE:
  -h, --help            show this help message and exit
  -i INPUT, --input INPUT
                      relative path to a image file or directory of frames.
  -o OUTPUT, --output OUTPUT
                      Destination path for masks. [DEFAULT: cwd]
  -x MAX_SEED, --max_seed MAX_SEED
                      max threshold seed. [DEFAULT: 200]
  -n MIN_SEED, --min_seed MIN_SEED
                      min threshold seed. [DEFAULT: 40]
  -c, --convex_hull     If set, convex_hull will be applied to output masks
                      [DEFAULT: False]
  --n_jobs N_JOBS       Degree of parallelism for reading in videos. -1 is all
                      cores. [DEFAULT -1]

OUTPUT:
  This program will output a png for each image passed into which where the
  meat pixels are 1 and the background pixels are 0
