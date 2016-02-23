run("Duplicate...", "duplicate");
run("Invert", "stack");
run("Distance Map", "stack");
selectWindow("avg4-mu0.3");
run("Distance Map", "stack");
imageCalculator("Subtract create 32-bit stack", "avg4-mu0-1.3","avg4-mu0.3");
selectWindow("Result of avg4-mu0-1.3");
run("Smooth (3D)", "method=Gaussian sigma=1.000 use");
saveAs("Tiff", "signdist_smth.tif");
