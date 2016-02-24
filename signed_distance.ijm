// Select image and set voxel size
selectWindow("avg");
run("Properties...", "channels=1 slices=300 frames=1 unit=pixel pixel_width=0.1000 pixel_height=0.1000 voxel_depth=0.512");

// Compute signed distance.
// First, compute forward and inverse distance maps.
run("3D Distance Map", "map=EDT image=avg mask=None threshold=1");
run("3D Distance Map", "map=EDT image=avg mask=None threshold=1 inverse");
rename("EDTi")

// Subtract the distance maps from each other
// (and close original windows to save space)
imageCalculator("Subtract create 32-bit stack", "EDT","EDTi");
selectWindow("EDT");
run("Close");
selectWindow("EDTi");
run("Close");

// Perform single-pixel smoothing so that we
// get nice sub-pixel curves.
selectWindow("Result of EDT");
run("Smooth (3D)", "method=Gaussian sigma=0.100 use");
rename("signdist_smth")

selectWindow("Result of EDT");
run("Close")

// Smooth out orbital regions.
// This is done by selectively smoothing (using a mask)
// areas outside the nasal cavity, with radius=5.0
selectWindow("signdist_smth");
run("Duplicate...", "duplicate");
imageCalculator("Multiply create 32-bit stack", "signdist_smth-1", "smooth_mask.tif");
selectWindow("signdist_smth-1");
run("Close")
selectWindow("signdist_smth");
run("Smooth (3D)", "method=Gaussian sigma=5.000 use");
selectWindow("signdist_smth");
run("Close")
selectWindow("smooth_mask.tif");
run("Invert")
imageCalculator("Multiply create 32-bit stack", "Smoothed", "smooth_mask.tif");
selectWindow("Smoothed");
run("Close")

imageCalculator("Add create 32-bit stack", "Result of signdist_smth-1", "Result of Smoothed");
saveAs("Tiff", "signdist_smth.tif");
selectWindow("Result of signdist_smth-1");
run("Close")
selectWindow("Result of Smoothed");
run("Close")
