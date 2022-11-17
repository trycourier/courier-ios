# Welcome to Courier android contributing guide

## Getting Started

1. Clone the repo and navigate to any of the three example repos inside courier-ios.
2. Click on ``.xcodeproj`` file
3. The project should open in xcode.
2. create a new Swift file named `Env`
3. Copy contents from `EnvSample.kt` and paste it in `Env.kt`
4. Provide your fcm and courier credentials

From here, you are all set to start working on the package! 🙌

## Developing
To develop the project you have to make changes in ``courier-ios/Sources/Courier`` directory.
after development is done push your changes to remote directory.
Click on project, go to package Dependencies change the branch to working branch.
Navigate to File->Packages->Update to latest package version.

## Testing 

While developing, you can run the project from xcode to test your changes. To see
Any changes you make in your library code will be reflected in the example app everytime you rebuild the app.


To start the packager:
you'll need a real iphone, notification's won't work on simulators.

connect your ios device 
build and run the project

you can write and run test cases in ``Examples/(projectName)/Tests/CourierTests`` directory
