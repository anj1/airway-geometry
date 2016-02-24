// Create smooth mask out of interior (a) mask and border (b) mask,
// by smoothing a but not b.
path = getDirectory("Choose the folder that contains the smoothing mask images.");
open(path + "/smooth_maska.png");
open(path + "/smooth_maskb.png");

// blur mask A
selectWindow("smooth_maska.png");
run("Gaussian Blur...", "sigma=24");

// add them together and normalize
imageCalculator("Add create 32-bit", "smooth_maska.png","smooth_maskb.png");
rename("smooth_mask")
run("Divide...", "value=255.000");

// close previous windows
selectWindow("smooth_maska.png")
run("Close");
selectWindow("smooth_maskb.png")
run("Close");
