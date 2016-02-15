using Base.Test
using Astrodynamics

dt = now()
utc = UTC(dt)
dt1 = DateTime(utc)
@test dt==dt1

epoch2000 = TT("2000-01-01T00:00:00.000")
epoch1950 = TT("1950-01-01T00:00:00.000")
@test jd2000(epoch2000) == 0.0
@test jd1950(epoch1950) == 0.0
