#! /usr/local/bin/perl -w
use strict;
use warnings;

# An example script to test and use Interactive.pm, well interactively

use Geo::TCX::Interactive;
use Geo::Gpx;

# default locations and parameters
my $recent = 25;
my ( $src_dir, $wrk_dir, $dev_dir, $gpx_dir, $trk_dir );
	$src_dir =  '~/Data/Src/Garmin/History/';
	$wrk_dir =  '~/Data/Garmin/History';
	$dev_dir =  '/media/pat/GARMIN/Garmin/GPX/';
	$gpx_dir =  '~/Data/Garmin/Gpx/';
	$trk_dir =  '/home/pat/.pytrainer/gpx';


my $tolerance_meters;           # default is 10
$DB::single=1;
$tolerance_meters = 0;        # comment out or set to 10 or greater if did NOT use temporary exploratory points before the ride

# For example, after a ride:
#   load new tcx file, save laps, and add begin and
#   end points of each lap to a waypoints file

if ($trk_dir) { chdir $trk_dir or die "can't chdir to $trk_dir: $!" }

$DB::single=1;
my $o= Geo::TCX::Interactive->new( $src_dir, recent => $recent, work_dir => $wrk_dir, device_dir => $dev_dir );
$o->prompt_and_set_wd;
# $o->lap_summary($_) for ( 1 .. $o->laps );

$o->save_laps( force => 1 );

my $gpx = $o->gpx_load( $gpx_dir );

# $o->way_add_device;
$o->way_add_endpoints( tolerance_meters => $tolerance_meters );
$o->gpx_save(force => 1 );

# $o->way_edge_send;

#
# Usage and Examples
my (@a, @s);
@a = $gpx->waypoints_search( name => qr/19/ );
@s = $gpx->waypoints_search( desc => qr/(?i:salamander)/ );
my ($name, $regex1, $regex2);
$name = 'MO-FP';
$regex1 = qr/O-FP/;
$regex2 = qr/(?i:larrimac)/;
my @a1 = $o->way_clip( $name );
my @a2 = $o->way_clip( $regex1 );
my @a3 = $o->way_clip( $o->gpx->waypoints_search( desc => $regex2 ) );


# quit here if not interested in remaining section(s)
$DB::single=1;

#
# create and save a course from an activity's lap

my ($lap_no, $course_name, $course_fname, $wd, $c);
$lap_no = 3;
$course_name  = 'Happy-loop';
$course_fname = $course_name;          # nothing wrong in having the same name
$wd = '/tmp/';
$c = $o->activity_to_course(lap => $lap_no, filename => $course_fname . '.tcx', course_name => $course_name, work_dir => $wd);
$c->save( force => 1 );

# Save waypoints with different filename:
# my $new_fname = 'MSM 2022.gpx';
# $o->way_save(filename => $new_fname );

print "so debugger doesn't exit\n";

