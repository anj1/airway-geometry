rename("stack")
for (i=750; i<=900; i++) {
	// Set amount of smoothing
	sig = (i-750)/20;
	// Smooth slice i only
	setSlice(i);
	run("Gaussian Blur...", "sigma=" + sig + " slice");
}
run("Duplicate...", "duplicate range=840-900");
rename("dup")
selectWindow("stack");
run("Slice Keeper", "first=1 last=839 increment=1");
selectWindow("stack");
run("Close");

selectWindow("dup")
run("Smooth (3D)", "method=Gaussian sigma=0.500 use");
run("Concatenate...", "  title=[Concatenated Stacks] image1=[stack kept stack]] image2=Smoothed image3=[-- None --]");
selectWindow("dup")
run("Close");
selectWindow("Concatenated Stacks")