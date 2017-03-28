var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": "(Image: Astrodynamics.jl)"
},

{
    "location": "time.html#",
    "page": "Epochs and Timescales",
    "title": "Epochs and Timescales",
    "category": "page",
    "text": ""
},

{
    "location": "state.html#",
    "page": "State Vectors and Reference Frame Transformations",
    "title": "State Vectors and Reference Frame Transformations",
    "category": "page",
    "text": ""
},

{
    "location": "propagators.html#",
    "page": "Propagators and Events",
    "title": "Propagators and Events",
    "category": "page",
    "text": ""
},

{
    "location": "api/time.html#AstronomicalTime.Epoch-Union{NTuple{4,Any}, NTuple{5,Any}, NTuple{6,Any}, NTuple{7,Any}, Tuple{Any,Any,Any}, Tuple{T}} where T<:Timescale",
    "page": "Time",
    "title": "AstronomicalTime.Epoch",
    "category": "Method",
    "text": "Epoch{T}(year, month, day,\n    hour=0, minute=0, seconds=0, milliseconds=0) where T<:Timescale\n\nConstruct an Epoch with timescale T at the given date and time.\n\nExample\n\njulia> Epoch{TT}(2017, 3, 14, 7, 18, 20, 325)\n2017-03-14T07:18:20.325 TT\n\n\n\n"
},

{
    "location": "api/time.html#AstronomicalTime.Epoch-Union{Tuple{AbstractString}, Tuple{T}} where T<:Timescale",
    "page": "Time",
    "title": "AstronomicalTime.Epoch",
    "category": "Method",
    "text": "Epoch{T}(timestamp::AbstractString) where T<:Timescale\n\nConstruct an Epoch with timescale T from a timestamp.\n\nExample\n\njulia> Epoch{TT}(\"2017-03-14T07:18:20.325\")\n2017-03-14T07:18:20.325 TT\n\n\n\n"
},

{
    "location": "api/time.html#AstronomicalTime.Epoch-Union{Tuple{AstronomicalTime.Epoch{S}}, Tuple{S}, Tuple{T}} where S<:Timescale where T<:Timescale",
    "page": "Time",
    "title": "AstronomicalTime.Epoch",
    "category": "Method",
    "text": "Epoch{T}(ep::Epoch{S}) where {T<:Timescale, S<:Timescale}\n\nConvert an Epoch with timescale S to an Epoch with timescale T.\n\nExample\n\njulia> Epoch{TT}(Epoch{TAI}(2000, 1, 1))\n2000-01-01T00:00:32.184 TT\n\n\n\n"
},

{
    "location": "api/time.html#AstronomicalTime.Epoch-Union{Tuple{DateTime}, Tuple{T}} where T<:Timescale",
    "page": "Time",
    "title": "AstronomicalTime.Epoch",
    "category": "Method",
    "text": "Epoch{T}(dt::DateTime) where T<:Timescale\n\nConvert a DateTime object to an Epoch with timescale T.\n\nExample\n\njulia> Epoch{TT}(DateTime(2017, 3, 14, 7, 18, 20, 325))\n2017-03-14T07:18:20.325 TT\n\n\n\n"
},

{
    "location": "api/time.html#AstronomicalTime.Epoch-Union{Tuple{Float64,Float64}, Tuple{Float64}, Tuple{T}} where T<:Timescale",
    "page": "Time",
    "title": "AstronomicalTime.Epoch",
    "category": "Method",
    "text": "Epoch{T}(jd1, jd2=0.0) where T<:Timescale\n\nConstruct an Epoch with timescale T from a two-part Julian date.\n\nExample\n\njulia> Epoch{TT}(2.4578265e6, 0.30440190993249416)\n2017-03-14T07:18:20.325 TT\n\n\n\n"
},

{
    "location": "api/time.html#AstronomicalTime.Timescale",
    "page": "Time",
    "title": "AstronomicalTime.Timescale",
    "category": "Type",
    "text": "All timescales are subtypes of the abstract type Timescale. The following timescales are defined:\n\nUTC — Coordinated Universal Time\nUT1 — Universal Time\nTAI — International Atomic Time\nTT — Terrestrial Time\nTCG — Geocentric Coordinate Time\nTCB — Barycentric Coordinate Time\nTDB — Barycentric Dynamical Time\n\n\n\n"
},

{
    "location": "api/time.html#AstronomicalTime.@timescale-Tuple{Any}",
    "page": "Time",
    "title": "AstronomicalTime.@timescale",
    "category": "Macro",
    "text": "@timescale scale\n\nDefine a new timescale and the corresponding Epoch type alias.\n\nExample\n\njulia> @timescale Custom\n\njulia> Custom <: Timescale\ntrue\njulia> CustomEpoch == Epoch{Custom}\ntrue\n\n\n\n"
},

{
    "location": "api/time.html#Base.Dates.DateTime-Union{Tuple{AstronomicalTime.Epoch{T}}, Tuple{T}} where T<:Timescale",
    "page": "Time",
    "title": "Base.Dates.DateTime",
    "category": "Method",
    "text": "DateTime{T<:Timescale}(ep::Epoch{T})\n\nConvert an Epoch with timescale T to a DateTime object.\n\nExample\n\njulia> DateTime(Epoch{TT}(2017, 3, 14, 7, 18, 20, 325))\n2017-03-14T07:18:20.325\n\n\n\n"
},

{
    "location": "api/time.html#",
    "page": "Time",
    "title": "Time",
    "category": "page",
    "text": "DocTestSetup = quote\n    using AstronomicalTime\nendModules = [AstronomicalTime]DocTestSetup = nothing"
},

]}
