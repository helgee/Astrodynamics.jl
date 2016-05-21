using JPLEphemeris

const EPHEMERIS_URL = "http://naif.jpl.nasa.gov/pub/naif/generic_kernels/spk/planets/de430.bsp"
const EPHEMERIS_FILE = normpath(joinpath(splitdir(@__FILE__)[1],"..","data","de430.bsp"))

function __init__()
    if !isfile(EPHEMERIS_FILE)
        println("[Astrodynamics.jl] Downloading ephemeris file.")
        dir = splitdir(EPHEMERIS_FILE)[1]
        if !isdir(dir)
            mkdir(dir)
        end
        download(EPHEMERIS_URL, EPHEMERIS_FILE)
    end
    global const EPHEMERIS = SPK(EPHEMERIS_FILE)
end
