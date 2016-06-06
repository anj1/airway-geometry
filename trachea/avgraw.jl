# run this via: $ avgraw.jl <size> file1.raw file2.raw file3.raw ...
N = parse(Int,ARGS[1])
avgarr =  zeros(UInt8,N,N,N)
for filename in ARGS[2:end]
	@show filename
	f = open(filename,"r")
	arr = read(f,UInt8,(N,N,N))
	avgarr += div(arr,0xff)
	close(f)
end
f = open("/tmp/avg.raw","w")
write(f,avgarr)
close(f)