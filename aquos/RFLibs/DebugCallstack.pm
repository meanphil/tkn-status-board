package RFLibs::DebugCallstack;

use strict;
use Exporter;


@RFLibs::DebugCallstack::ISA = qw(Exporter);
@RFLibs::DebugCallstack::EXPORT = qw(
			installDebug
                      );

# Common signals:	
#	INT, USR1
#
sub installDebug
{
	my ($signal, $terminate) = @_;

	my $func = 'RFLibs::DebugCallstack::print_callstack';
	$func .= '_and_exit' if $terminate;

	$SIG{$signal} = $func;
};

sub print_callstack
{
        foreach my $i (0..50)
        {
                my ($package, $filename, $line, $subroutine, $hasargs, $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthash) = caller($i);
                last if $package eq '';

                print "$subroutine called from $filename line $line\n";
        };
};

sub print_callstack_and_exit
{
	print_callstack();
	exit;
};
return 1;
