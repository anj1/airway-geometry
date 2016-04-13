// Before running script:
// 1. Load image stack.
// 2. Make binary.
// 3. Rename to 'avg'

// settings.
// use Plugins->Process->Exact Euclidean Distance Transform (3D)
// instead of subtraction.
use_native_edt=false;
// if the above is false, subtract 1 and clamp to 0
// before subtraction
clamp_zero=false;
// Anisotropic smooth at the end.
aniso_smth=true;
// Smooth before interpolation?
pre_smth=false;
// Interpolate?
interp=true;
// Smooth trachea?
smooth_trachea=true;

path = getDirectory("Choose the folder for output.");
runMacro(path + "/smooth_mask.ijm");

// Select image and set voxel size
selectWindow("avg");
run("Properties...", "channels=1 slices=300 frames=1 unit=pixel pixel_width=0.1000 pixel_height=0.1000 voxel_depth=0.512");

// Compute signed distance.
// There are two ways to do this: the built-in plugin,
// Or forward and inverse distance maps and subtraction.
selectWindow("avg");
if(use_native_edt){
	run("Exact Signed Euclidean Distance Transform (3D)");
} else {
	// First, compute forward and inverse distance maps.
	run("3D Distance Map", "map=EDT image=avg mask=None threshold=1");
	run("3D Distance Map", "map=EDT image=avg mask=None threshold=1 inverse");
	rename("EDTi");

	if(clamp_zero){
		selectWindow("EDT");
		run("Subtract...", "value=0.1 stack");
		run("Min...", "value=0 stack");
		selectWindow("EDTi");
		run("Subtract...", "value=0.1 stack");
		run("Min...", "value=0 stack");
	}

	// Subtract the distance maps from each other
	// (and close original windows to save space)
	imageCalculator("Subtract create 32-bit stack", "EDT","EDTi");
	selectWindow("EDT");
	run("Close");
	selectWindow("EDTi");
	run("Close");
	selectWindow("Result of EDT");
	rename("EDT");
}


selectWindow("EDT");
// Perform single-pixel smoothing so that we
// get nice sub-pixel curves.
if(pre_smth){
	run("Smooth (3D)", "method=Gaussian sigma=0.100 use");
	rename("signdist_smth");
	selectWindow("EDT");
	run("Close");
} else {
	rename("signdist_smth");
}


// Smooth out orbital regions.
// This is done by selectively smoothing (using a mask)
// areas outside the nasal cavity, with radius=5.0
selectWindow("signdist_smth");
run("Duplicate...", "duplicate");
imageCalculator("Multiply create 32-bit stack", "signdist_smth-1", "smooth_mask");
selectWindow("signdist_smth-1");
run("Close");
selectWindow("signdist_smth");
run("Smooth (3D)", "method=Gaussian sigma=5.000 use");
selectWindow("signdist_smth");
run("Close");
selectWindow("smooth_mask");
run("Invert");
imageCalculator("Multiply create 32-bit stack", "Smoothed", "smooth_mask");
selectWindow("Smoothed");
run("Close");

imageCalculator("Add create 32-bit stack", "Result of signdist_smth-1", "Result of Smoothed");
if(interp){
	run("Size...", "width=600 height=800 depth=900 constrain average interpolation=Bilinear");
}
if(aniso_smth){
	run("Gaussian Blur 3D...", "x=1 y=1 z=1");
}
if(smooth_trachea){
	runMacro(path + "/smooth_trachea.ijm");
}
saveAs("Tiff", path + "/signdist_smth.tif");
selectWindow("Result of signdist_smth-1");
run("Close");
selectWindow("Result of Smoothed");
run("Close");
