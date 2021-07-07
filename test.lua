-- Test code for orb.lua
-- update 2021-07-06 01:00 JST

local Orb = require("orb")

-- time conversion
local t = {year=2000,month=1,day=1,hour=12,min=0,sec=0}

-- now
--local t = os.date("!*t")

local utc_str = os.date('%Y-%m-%dT%H:%M:%S', os.time(t))
print("UTC: " .. utc_str)

local jd = Orb.Time.JD(t)
print("JD: " .. jd)

local fjd = Orb.Time.JDToUTC(jd)
print("UTC: " .. fjd.year .. "-" .. fjd.month .. "-" .. fjd.day .. "T" .. fjd.hour .. ":" .. fjd.min .. ":" .. fjd.sec)

local gst = Orb.Time.gst(t)
print("GST: ".. gst)

-- Equatorial Spherical(ra,dec) to Equatorial Rectangular(x,y,z)
-- Note: Right Ascension(ra) must be hours(not degree)

local sirius = {
  ra=6.75257,
  dec = -16.7131,
  distance = 543300
}

local vec = Orb.Coord.RadecToEquatorial(sirius.ra,sirius.dec,1)
print("Sirius(equatorial)\n x:" .. vec.x .. ", y: " .. vec.y .. ", z: " .. vec.z)

local observer = {
  latitude = 35.658,
  longitude = 139.741,
  altitude = 0
}

local obs = Orb.Observe.RadecToHorizontal(t,sirius,observer)
print("Sirius(horizontal)\n azimuth:" .. obs.azimuth .. ", elevation: " .. obs.elevation)

-- Planet Position in Ecliptic Rectangular Coordinate (au) via VSOP Theory
local earth = Orb.Planet.Earth(t)
print("Earth(ecliptic)\n x:" .. earth.x .. ", y: " .. earth.y .. ", z: " .. earth.z)

local mars = Orb.Planet.Mars(t)
print("Mars(ecliptic)\n x:" .. mars.x .. ", y: " .. mars.y .. ", z: " .. mars.z)

-- Ecliptic Coordinate(Normalized)
local normalized = Orb.Normalize(mars)
print("Mars(ecliptic/normalized)\n x:" .. normalized.x .. ", y: " .. normalized.y .. ", z: " .. normalized.z)

-- Ecliptic Coordinate(Earth Centered) Mars Position
local ecm = Orb.Coord.EclipticToEquatorial(t,mars)
print("Mars(equatorial)\n x:" .. ecm.x .. ", y: " .. ecm.y .. ", z: " .. ecm.z)

local mars_radec = Orb.Coord.EquatorialToRadec(t,ecm)
print("Mars(radec)\n x:" .. mars_radec.ra .. ", y: " .. mars_radec.dec .. ", distance: " .. mars_radec.distance)

-- Horizontal Coordinate
local obs = Orb.Observe.RadecToHorizontal(t,mars_radec,observer)
print("Mars(horizontal)\n azimuth:" .. obs.azimuth .. ", elevation: " .. obs.elevation .. ", distance: " .. obs.distance)

-- Phobos elements from JPL Horizons
-- Unit: km & km/s
-- Reference frame : Ecliptic/J2000.0
-- GM:4.2828374329453691E+04 (Mars)
-- 2459396.500000000 = A.D. 2021-Jul-01 00:00:00.0000 TDB 
--  EC= 1.523200192464029E-02 QR= 9.235467741975737E+03 IN= 2.735995152418549E+01
--  OM= 8.099349186026042E+01 W = 1.625229338531760E+02 Tp=  2459396.554348954000
--  N = 1.305572441087194E-02 MA= 2.986935871141673E+02 TA= 2.971485375721970E+02
--  A = 9.378318304438839E+03 AD= 9.521168866901940E+03 PR= 2.757411145261430E+04

local phobos_elements = {
  gm = 4.2828374329453691E+04,
  eccentricity = 1.523200192464029E-02,
  inclination = 2.735995152418549E+01,
  longitude_of_ascending_node = 8.099349186026042E+01,
  argument_of_periapsis = 1.625229338531760E+02,
  time_of_periapsis = 2459396.554348954000,
  semi_major_axis = 9.378318304438839E+03
}

local phobos = Orb.Kepler(t,phobos_elements);
print("Phobos(Mars center)\n x:" .. phobos.x .. "km, y:" .. phobos.y .. "km, z:" .. phobos.z .. "km")

local au = 49597870.700;

local phobos_ecliptic = {
  x = mars.x - phobos.x/au,
  y = mars.y - phobos.y/au,
  z = mars.z - phobos.z/au,
}

local phobos_equatorial = Orb.Coord.EclipticToEquatorial(t,phobos_ecliptic);
print("Phobos(equatorial)\n x:" .. phobos_equatorial.x .. "au, y:" .. phobos_equatorial.y .. "au, z:" .. phobos_equatorial.z .. "au")

local phobos_horizontal = Orb.Observe.EquatorialToHorizontal(t,phobos_equatorial,observer)
print("Phobos(horizontal)\n azimuth:" .. phobos_horizontal.azimuth .. ", elevation: " .. phobos_horizontal.elevation .. ", distance: " .. phobos_horizontal.distance)

-- Pluto elements from JPL Horizons
-- Unit: au & au/d
-- Reference frame : Ecliptic/J2000.0
-- GM:2.9591220828411951E-04 (Sun)
-- 2459396.500000000 = A.D. 2021-Jul-01 00:00:00.0000 TDB 
--  EC= 2.515592767106864E-01 QR= 2.967588460857290E+01 IN= 1.729107375790253E+01
--  OM= 1.103546798589673E+02 W = 1.141843508986021E+02 Tp=  2447879.317561375909
--  N = 3.947613990481508E-03 MA= 4.546539052564052E+01 TA= 7.086411718013353E+01
--  A = 3.965028049001756E+01 AD= 4.962467637146222E+01 PR= 9.119432671685543E+04

local pluto_elements = {
  gm = 2.9591220828411951E-04,
  eccentricity = 0.2519446,
  inclination = 17.09860,
  longitude_of_ascending_node = 110.29702,
  argument_of_periapsis = 115.37952,
  time_of_periapsis = 2448031.24959,
  semi_major_axis = 39.8362800
}
local pluto_ecliptic = Orb.Kepler(t,pluto_elements);
print("Pluto(ecliptic)\n x:" .. pluto_ecliptic.x .. "au, y:" .. pluto_ecliptic.y .. "au, z:" .. pluto_ecliptic.z .. "km")

local pluto_equatorial = Orb.Coord.EclipticToEquatorial(t,pluto_ecliptic)
print("Pluto(equatorial)\n x:" .. pluto_equatorial.x .. ", y: " .. pluto_equatorial.y .. ", z: " .. pluto_equatorial.z)

local pluto_horizontal = Orb.Observe.EclipticToHorizontal(t,pluto_ecliptic,observer)
print("Pluto(horizontal)\n azimuth:" .. pluto_horizontal.azimuth .. ", elevation: " .. pluto_horizontal.elevation .. ", distance: " .. pluto_horizontal.distance)


Orb.Moon = require("luna")

local moon_equatorial = Orb.Moon.Equatorial(t)
print("Moon(equatorial)\n  x:" .. moon_equatorial.x .. ", y: " .. moon_equatorial.y .. ", z: " .. moon_equatorial.z)

local moon_ecliptic = Orb.Moon.Ecliptic(t)
print("Moon(ecliptic)\n  x:" .. moon_ecliptic.x .. ", y: " .. moon_ecliptic.y .. ", z: " .. moon_ecliptic.z)

local moon_radec = Orb.Moon.RaDec(t)
print("Moon(radec)\n  ra:" .. moon_radec.ra .. ", dec: " .. moon_radec.dec .. ", distance: " .. moon_radec.distance)

local moon_horizontal = Orb.Moon.Horizontal(t,observer)
print("Moon(horizontal)\n  azimuth:" .. moon_horizontal.azimuth .. ", elevation: " .. moon_horizontal.elevation .. ", distance: " .. moon_horizontal.distance)

