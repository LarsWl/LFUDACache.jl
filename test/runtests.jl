using LFUDACache
using Test
using Dates

function log(str)
    "$(Dates.format(Dates.now(), "dd.mm.yyyy HH:MM:SS")) - $(str)\n"
end

tests = [
    "./cache_item_test.jl",
    "./lfuda_cache_test.jl",
    "./benchmark.jl"
]

@info log("Running tests....")
Test.@testset verbose = true showtiming = true "All tests" begin
    for test in tests
        @info log("Test: " * test)
        Test.@testset "$test" begin
            include(test)
        end
    end
end
@info log("done.")