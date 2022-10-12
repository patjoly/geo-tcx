# t/02_trackpoint.t - testing file for Trackpoint.pm
use strict;
use warnings;

use Test::More tests => 32;
use Geo::TCX::Trackpoint;

# Section A - new() constructor

my $basic_str = '<Position><LatitudeDegrees>45.304996</LatitudeDegrees><LongitudeDegrees>-72.637243</LongitudeDegrees></Position>';
my $full_str  = '<Trackpoint><Time>2014-08-11T10:25:26Z</Time><Position><LatitudeDegrees>45.304996</LatitudeDegrees><LongitudeDegrees>-72.637243</LongitudeDegrees></Position><AltitudeMeters>211.082</AltitudeMeters><DistanceMeters>13.030</DistanceMeters><HeartRateBpm><Value>80</Value></HeartRateBpm></Trackpoint>';

my $tp_basic = Geo::TCX::Trackpoint->new( $basic_str );
isa_ok ($tp_basic, 'Geo::TCX::Trackpoint');
isnt ($tp_basic, 'Geo::TCX::Trackpoint::Full');

my $tp = Geo::TCX::Trackpoint::Full->new( $full_str );
isa_ok ($tp, 'Geo::TCX::Trackpoint');
isa_ok ($tp, 'Geo::TCX::Trackpoint::Full');

#
# AUTOLOAD methods

is($tp->LatitudeDegrees,  '45.304996',  "    LatitudeDegrees, AUTOLOAD method");
is($tp->LongitudeDegrees, '-72.637243', "    LongitudeDegrees, AUTOLOAD method");
is($tp->AltitudeMeters, '211.082',      "    AltitudeMeters, AUTOLOAD method");
is($tp->DistanceMeters, '13.030',       "    DistanceMeters, AUTOLOAD method");
is($tp->HeartRateBpm, 80,               "    HeartRateBpm, AUTOLOAD method");
is($tp->Cadence, undef,                 "    Cadence, AUTOLOAD method");
is($tp->SensorState, undef,             "    SensorState, AUTOLOAD method");

# Time method is now defined (no longer AUTOLOAD, to prevent setting it)
is($tp->Time, '2014-08-11T10:25:26Z',   "    Time, AUTOLOAD method");

#
# to_gpx()

my $gpp = $tp->to_gpx();
isa_ok ($gpp, 'Geo::Gpx::Point');
is($gpp->time, '1407752726',     "   test to_gpx()");

#
# to_geocalc()

my $gc = $tp->to_geocalc();
isa_ok ($gc, 'Geo::Calc');

#
# to_basic()

my $bas = $tp->to_basic();
isa_ok ($bas, 'Geo::TCX::Trackpoint');
isnt ($bas, 'Geo::TCX::Trackpoint::Full');

# check that $tp is still what it was
isa_ok ($tp, 'Geo::TCX::Trackpoint');
isa_ok ($tp, 'Geo::TCX::Trackpoint::Full');

#
# clone()

my $clone = $tp->clone;
isa_ok ($clone, 'Geo::TCX::Trackpoint');

#
# distance_to(), distance_meters(), time_local, time_add, time_epoch, xml_string()

#
# time_add(), time_subtract()
my $c = $tp->clone;
$c->time_add( seconds => 45 );
is ( ($c->time_epoch - $tp->time_epoch), '45',    "   time_add(): checking that internal date fields are updated");
$c->time_subtract( seconds => 45 );
is ( ($c->time_epoch - $tp->time_epoch), 0,       "   time_sutract(): checking that time_add() and time_subtract() by the same amount, provide the same time");

is ($tp->Time, '2014-08-11T10:25:26Z',             "   test Time before time_subtract()");

TODO: {
    local $TODO = "time_local() will fail across timezone given that, by design, it always returns local time from the caller's perspecitive. Design different tests or ignore";

    is ($tp->time_local, 'Mon Aug 11 06:25:26 2014',    "   test time_local before time_subtract()");
    $tp->time_subtract( days => 2, hours => 3, , minutes => 59, seconds => 20 );
    is ($tp->time_local, 'Sat Aug  9 02:26:06 2014',    "   test time_local after time_subtract()")
}
is ($tp->Time, '2014-08-09T06:26:06Z',             "   test Time after time_subtract()");

#
# time_duration()

my ($dur1, $dur2, $dur3);
my $epoch = '1407565666';
my $str = '2014-07-08T04:26:06Z';
$dur1 = $tp->time_duration( $epoch );
$dur2 = $tp->time_duration( $str );
$dur3 = $tp->time_duration( $tp->Time );
my @dur1 = $dur1->in_units('minutes', 'seconds');
my @dur2 = $dur2->in_units('months', 'days', 'hours');
my @dur3 = $dur3->in_units('hours', 'minutes', 'seconds');
is(	$dur1->is_negative, 1,           "   test time_duration()");
is(	$dur2->is_positive, 1,           "   test time_duration()");
is(	$dur3->is_zero, 1,           "   test time_duration()");
is(	join(' ', @dur1), '-1 -40',        "   test time_duration()");
is(	join(' ', @dur2), '1 1 2',        "   test time_duration()");
is(	join(' ', @dur3), '0 0 0',        "   test time_duration()");


print "so debugger doesn't exit\n";
