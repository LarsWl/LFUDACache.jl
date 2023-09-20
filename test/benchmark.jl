using LFUDACache
using BenchmarkTools
using LRUCache

keys = map(i -> Symbol("key_$i"), 1:1000)
values = map(i -> rand(50) |> string, 1:1000)

mutable struct KeyIndex
  value::Int
end

increment_key(key_index) = 
  begin
    if key_index.value == length(keys)
      key_index.value = 1
    else
      key_index.value += 1
    end
  end

read_operation(lfuda, key_index) =
  begin
    get(lfuda, keys[key_index.value], nothing)

    increment_key(key_index)
  end

write_operation(lfuda, key_index) =
  begin
    lfuda[keys[key_index.value]] = values[key_index.value]

    increment_key(key_index)
  end

lfuda = LFUDA{Symbol, String}(maxsize = 750)
lru = LRU{Symbol, String}(maxsize = 750)

key_index = KeyIndex(1)
@benchmark write_operation(lfuda, key_index) samples = 5000 evals = 5
@benchmark read_operation(lfuda, key_index) samples = 5000 evals = 5

key_index = KeyIndex(1)
@benchmark write_operation(lru, key_index) samples = 5000 evals = 5
@benchmark read_operation(lru, key_index) samples = 5000 evals = 5
