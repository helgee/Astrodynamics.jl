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
    "location": "api/time.html#AstronomicalTime.Epoch",
    "page": "Time",
    "title": "AstronomicalTime.Epoch",
    "category": "Constant",
    "text": "Epoch{T}(timestamp::AbstractString) where T<:Timescale\n\nConstruct an Epoch with timescale T from a timestamp.\n\nExample\n\njulia> Epoch{TT}(\"2017-03-14T07:18:20.325\")\n2017-03-14T07:18:20.325 TT\n\n\n\n"
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
    "location": "api/time.html#Base.Dates.DateTime-Tuple{AstronomicalTime.Epoch{T}} where T<:Timescale",
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
