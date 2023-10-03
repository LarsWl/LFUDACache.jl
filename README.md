# LFUDACache.jl

Thread-safe in memory implementation of Least Frequency Used cache based on min binary heap map. Package provides three policies for calculation of priority key (more information [here](https://www.hpl.hp.com/techreports/98/HPL-98-173.pdf))
1) LFU policy
2) LFU with Dynamic Age policy (by default)
3) GreedyDual-Size with Frequency (GDSF)

## Usage

LFUDA implements AbstractDict interface. Here some examples of usage:

```julia
lfuda = LFUDA{String,String}(maxsize = 2)

lfuda["key"] = "cache_1" 
cache_1 = get(lfuda, "key", nothing) # Now cache 1 have frequency equal to 2

value = "cache_2"
# Pass value size, necessary for GDSF policy
cache_2 = get!(lfuda, "key_2", value, size=sizeof(value)) # Cache 2 have frequncy equal to 1

lfuda["key_3"] = "cache_3" # In this case cache_2 will be evicted

@show haskey(lfuda, "key_2")
```

## Aknowledgments

This package inspired by LRUCache.jl, lfuda-go and squid-cache