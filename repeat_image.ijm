// ask user how many times it should be repeated.
Dialog.create("Stack beginning repeater");
Dialog.addNumber("Number of times:", 57);
Dialog.show();
n_rep = Dialog.getNumber();

// go to first slice
setSlice(1);
// copy the slice
run("Copy");
// repeat it N times
for (i=0;i<n_rep;i++){
	run("Add Slice");
	run("Paste");
}
