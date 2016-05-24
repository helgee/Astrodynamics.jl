using JPLEphemeris

const PATH = normpath(joinpath(splitdir(@__FILE__)[1],"..","data"))
const DATA_FILES = Dict(
    :ephemeris => Dict(:url=>"http://naif.jpl.nasa.gov/pub/naif/generic_kernels/spk/planets/de430.bsp", :path=>joinpath(PATH, "de430.bsp")),
    :leapseconds => Dict(:url=>"http://naif.jpl.nasa.gov/pub/naif/generic_kernels/lsk/naif0011.tls", :path=>joinpath(PATH, "naif0011.tls")),
)

function download_data(;force=false)
    !isdir(PATH) && mkdir(PATH)
    for (data, file) in DATA_FILES
        if !isfile(file[:path]) || force
            log("Downloading $data data.")
            download(file[:url], file[:path])
        end
    end
end

function __init__()
    download_data()
    global const EPHEMERIS = SPK(DATA_FILES[:ephemeris][:path])
end
