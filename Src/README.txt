========================================
|             OpenCVSwift              |
========================================

REQUIREMENTS:
   - Macbook
   - Xcode 10 or higher
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

========================================
|           Python Scripts             |
========================================