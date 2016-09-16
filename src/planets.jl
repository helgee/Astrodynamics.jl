# [1] Luzum, Brian, et al. "The IAU 2009 system of astronomical constants: the report of the IAU working group on numerical standards for Fundamental Astronomy." Celestial Mechanics and Dynamical Astronomy 110.4 (2011): 293-304.
# [2] Archinal, Brent Allen, et al. "Report of the IAU working group on cartographic coordinates and rotational elements: 2009." Celestial Mechanics and Dynamical Astronomy 109.2 (2011): 101-135.

const MERCURY = Mercury(
    # μ
    2.2032e4,
    # j2
    2.027e-4,
    # mean radius
    2439.7,
    # equatorial radius
    2439.7,
    # polar radius
    2439.7,
    # deviation
    1.0,
    # maximum elevation
    4.6,
    # maximum depression
    2.5,
    # id
    199,
    # ra0
    deg2rad.(281.0097),
    # ra1
    deg2rad.(-0.0328),
    # ra2
    0,
    # dec0
    deg2rad.(61.4143),
    # dec1
    deg2rad.(-0.0049),
    # dec2
    0.0,
    # w0
    deg2rad.(329.5469),
    # w1
    deg2rad.(6.1385025),
    # w2
    0,
    # a
    [0.0],
    # d
    [0.0],
    # w
    deg2rad.([0.00993822, -0.00104581, -0.00010280, -0.00002364, -0.00000532]),
    # theta 0
    deg2rad.([174.791086, 349.582171, 164.373257, 339.164343, 153.955429]),
    # theta 1
    deg2rad.([4.092335, 8.184670, 12.277005, 16.369340, 20.461675])*JULIAN_CENTURY
)
const VENUS = Venus(
    # μ
    3.24859e5,
    # j2
    6e-5,
    # mean radius
    6051.8,
    # equatorial radius
    6051.8,
    # polar radius
    6051.8,
    # deviation
    1.0,
    # maximum elevation
    11,
    # maximum depression
    2,
    # id
    299,
    # ra0
    deg2rad.(272.76),
    # ra1
    0,
    # ra2
    0,
    # dec0
    deg2rad.(67.16),
    # dec1
    0,
    # dec2
    0,
    # w0
    deg2rad.(160.20),
    # w1
    deg2rad.(-1.4813688),
    # w2
    0,
    # a
    [0.0],
    # d
    [0.0],
    # w
    [0.0],
    # theta 0
    [0.0],
    # theta 1
    [0.0],
)
const EARTH = Earth(
    # μ
    3.986004418e5,
    # j2
    1.08262668e-3,
    # mean radius
    6371.0084,
    # equatorial radius
    6378.1366,
    # polar radius
    6356.7519,
    # deviation
    3.57,
    # maximum elevation
    8.85,
    # maximum depression
    11.52,
    # id
    399,
    # ra0
    0,
    # ra1
    deg2rad.(-0.641),
    # ra2
    0,
    # dec0
    deg2rad.(90),
    # dec1
    deg2rad.(-0.557),
    # dec2
    0,
    # w0
    deg2rad.(190.147),
    # w1
    deg2rad.(360.9856235),
    # w2
    0,
    # a
    [0.0],
    # d
    [0.0],
    # w
    [0.0],
    # theta 0
    [0.0],
    # theta 1
    [0.0],
)
const MARS = Mars(
    # μ
    4.282837e4,
    # j2
    1.964e-3,
    # mean radius
    3389.5,
    # equatorial radius
    3396.19,
    # polar radius
    3376.20,
    # deviation
    3.0,
    # maximum elevation
    22.64,
    # maximum depression
    7.55,
    # id
    4,
    # ra0
    deg2rad.(317.68143),
    # ra1
    deg2rad.(-0.1061),
    # ra2
    0.0,
    # dec0
    deg2rad.(52.88650),
    # dec1
    deg2rad.(-0.0609),
    # dec2
    0,
    # w0
    deg2rad.(176.630),
    # w1
    deg2rad.(350.89198226),
    # w2
    0,
    # a
    [0.0],
    # d
    [0.0],
    # w
    [0.0],
    # theta 0
    [0.0],
    # theta 1
    [0.0],
)
const JUPITER = Jupiter(
    # μ
    1.26686534e8,
    # j2
    1.475e-2,
    # mean radius
    69911,
    # equatorial radius
    71492,
    # polar radius
    66854,
    # deviation
    62.1,
    # maximum elevation
    31,
    # maximum depression
    102,
    # id
    5,
    # ra0
    deg2rad.(268.056595),
    # ra1
    deg2rad.(-0.006499),
    # ra2
    0.0,
    # dec0
    deg2rad.(64.495303),
    # dec1
    deg2rad.(0.002413),
    # dec2
    0.0,
    # w0
    deg2rad.(284.95),
    # w1
    deg2rad.(870.536),
    # w2
    0.0,
    # a
    deg2rad.([0.000117, 0.000938, 0.001432, 0.00003, 0.002150]),
    # d
    deg2rad.([0.00005, 0.000404, 0.000617, -0.000013, 0.000926]),
    # w
    [0.0],
    # theta 0
    deg2rad.([99.360714, 175.895369, 300.323162, 114.012305, 49.511251]),
    # theta 1
    deg2rad.([4850.4046, 1191.9605, 262.5475, 6070.2476, 64.3]),
)
const SATURN = Saturn(
    # μ
    3.7931187e7,
    # j2
    1.645e-2,
    # mean radius
    58232,
    # equatorial radius
    60268,
    # polar radius
    54364,
    # deviation
    102.9,
    # maximum elevation
    8,
    # maximum depression
    205,
    # id
    6,
    # ra0
    deg2rad.(40.589),
    # ra1
    deg2rad.(-0.036),
    # ra2
    0.0,
    # dec0
    deg2rad.(83.537),
    # dec1
    deg2rad.(-0.004),
    # dec2
    0.0,
    # w0
    deg2rad.(38.90),
    # w1
    deg2rad.(810.7939024),
    # w2
    0.0,
    # a
    [0.0],
    # d
    [0.0],
    # w
    [0.0],
    # theta 0
    [0.0],
    # theta 1
    [0.0],
)
const URANUS = Uranus(
    # μ
    5.793939e6,
    # j2
    1.2e-2,
    # mean radius
    25362,
    # equatorial radius
    25559,
    # polar radius
    24973,
    # deviation
    16.8,
    # maximum elevation
    28,
    # maximum depression
    0,
    # id
    7,
    # ra0
    deg2rad.(257.311),
    # ra1
    0,
    # ra2
    0,
    # dec0
    deg2rad.(-15.175),
    # dec1
    0,
    # dec2
    0,
    # w0
    deg2rad.(203.81),
    # w1
    deg2rad.(-501.1600928),
    # w2
    0.0,
    # a
    [0.0],
    # d
    [0.0],
    # w
    [0.0],
    # theta 0
    [0.0],
    # theta 1
    [0.0],
)
const NEPTUNE = Neptune(
    # μ
    6.836529e6,
    # j2
    4e-3,
    # mean radius
    24622,
    # equatorial radius
    24764,
    # polar radius
    24341,
    # deviation
    8,
    # maximum elevation
    14,
    # maximum depression
    0,
    # id
    8,
    # ra0
    deg2rad.(299.36),
    # ra1
    0,
    # ra2
    0,
    # dec0
    deg2rad.(43.46),
    # dec1
    0,
    # dec2
    0,
    # w0
    deg2rad.(253.18),
    # w1
    deg2rad.(536.3128492),
    # w2
    0.0,
    # a
    deg2rad.([0.7]),
    # d
    deg2rad.([-0.51]),
    # w
    deg2rad.([-0.48]),
    # theta 0
    deg2rad.([357.85]),
    # theta 1
    deg2rad.([52.316]),
)
