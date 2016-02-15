using Base.Dates: year, month, day, hour, minute, second, millisecond, datetime2julian
import Base.convert, Base.promote_rule
import ERFA

export TT, UTC, TAI, UT1
export juliandate, jd2000, jd1950, mjd
export JULIAN_CENTURY, J2000

const JULIAN_CENTURY = 36525
const J2000 = Dates.datetime2julian(DateTime(2000, 1, 1, 12, 0, 0))

abstract AbstractEpoch

scales = (:TT, :UTC, :TAI, :UT1)
names = map(string, scales)

for (scale, name) in zip(scales, names)
    eval(quote
        immutable $scale <: AbstractEpoch
            jd::Float64
            jd1::Float64
        end

        function $(scale)(year, month, day, hour, minute, seconds)
            $(scale)(ERFA.eraDtf2d($name, year, month, day, hour,
            minute, seconds)...)
        end

        function $(scale)(dt::DateTime)
            ($(scale)(year(dt), month(dt), day(dt), hour(dt),
            minute(dt), second(dt) + millisecond(dt)/1000))
        end

        function $(scale)(iso::ASCIIString)
            $(scale)(DateTime(iso))
        end

        function DateTime(epoch::$(scale))
            DateTime(ERFA.eraD2dtf($name, 3,
            epoch.jd, epoch.jd1)...)
        end
    end)
end

juliandate(epoch::AbstractEpoch) = epoch.jd + epoch.jd1
mjd(epoch::AbstractEpoch) = juliandate(epoch) - 2400000.5
jd1950(epoch::AbstractEpoch) = juliandate(epoch) - 2433282.5
jd2000(epoch::AbstractEpoch) = juliandate(epoch) - 2451544.5
@vectorize_1arg AbstractEpoch juliandate
@vectorize_1arg AbstractEpoch mjd
@vectorize_1arg AbstractEpoch jd2000
@vectorize_1arg AbstractEpoch jd1950
