using JPLEphemeris

const PATH = normpath(joinpath(splitdir(@__FILE__)[1],"..","data"))
const DATA_FILES = Dict(
    :ephemeris  =>  Dict(:name => "DE430 ephemeris", :url => "http://naif.jpl.nasa.gov/pub/naif/generic_kernels/spk/planets/de430.bsp", :path => joinpath(PATH, "de430.bsp")),
    :leapseconds  =>  Dict(:name => "leap seconds", :url => "http://naif.jpl.nasa.gov/pub/naif/generic_kernels/lsk/naif0011.tls", :path => joinpath(PATH, "naif0011.tls")),
    :iau1980  =>  Dict(:name => "IAU1980 Earth orientation", :url => "http://maia.usno.navy.mil/ser7/finals.all", :path => joinpath(PATH, "finals.all")),
    :iau2000  =>  Dict(:name => "IAU2000 Earth orientation", :url => "http://maia.usno.navy.mil/ser7/finals2000A.all", :path => joinpath(PATH, "finals2000A.all")),
)

function download_data(;force=false)
    !isdir(PATH) && mkdir(PATH)
    for file in values(DATA_FILES)
        if !isfile(file[:path]) || force
            log("Downloading $(file[:name]) data.")
            download(file[:url], file[:path])
        end
    end
end

function __init__()
    download_data()
    pm, dut1, iau1980, iau2000 = load_iers(DATA_FILES[:iau1980][:path], DATA_FILES[:iau2000][:path])
    global const DATA = Dict(
        :ephemeris => SPK(DATA_FILES[:ephemeris][:path]),
        :leapseconds => LSK(DATA_FILES[:leapseconds][:path]),
        :polarmotion => pm,
        :dut1 => dut1,
        :iau1980 => iau1980,
        :iau2000 => iau2000,
    )
    return nothing
end
