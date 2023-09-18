using LFUDACache
using BenchmarkTools

keys = map(i -> Symbol("key_$i"), 1:1000)
values = map(i -> rand(50) |> string, 1:1000)

global key_index = 1

increment_key() = 
  begin
    if key_index == length(keys)
      global key_index = 1
    else
      global key_index += 1
    end
  end

read_operation(lfuda) =
  begin
    get(lfuda, keys[key_index], nothing)

    increment_key()
  end

write_operation(lfuda) =
  begin
    lfuda[keys[key_index]] = values[key_index]

    increment_key()
  end

lfuda = LFUDA{Symbol, String}(maxsize = 750)

@benchmark write_operation(lfuda) samples = 5000 evals = 5
@benchmark read_operation(lfuda) samples = 5000 evals = 5