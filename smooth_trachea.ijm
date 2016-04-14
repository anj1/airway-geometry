for (i=750; i<=900; i++) {
	// Set amount of smoothing
	sig = (i-750)/30;
	// Smooth slice i only
	setSlice(i);
	run("Gaussian Blur...", "sigma=" + sig + " slice");
}