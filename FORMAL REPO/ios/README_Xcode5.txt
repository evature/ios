If you are using Xcode 5 please read this:

Pay attention that Xcode 5 change storyboard files. In that case if you want to open this project and then open that with Xcode 4.6 version you must reverse Xcode 5 changes (with Xcode 5):
1. Go to file: MainStoryboard.storyboard
2. Open file inspector
3. On "Interface Builder Documents" section change "Open with" to Xcode 4.6 (if it's 5.x).
4. Save, Close the project and open that with old Xcode. It should work.

IMPORTANT: Pay attention that using old "progress view" (Xcode 4.6 one) we use to show mic activity on the sample app, may not work properly with iOS 7. If you compile all project with Xcode 5 that would work.


