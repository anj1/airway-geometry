for (i=250; i<=300; i++) {
	// Set amount of smoothing
	sig = (i-250);
	// Smooth slice i only
	setSlice(i);
	run("Gaussian Blur...", "sigma=" + sig + " slice");
}