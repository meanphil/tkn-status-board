#!/usr/local/bin/perl -I/home/status/status-board/aquos

################################################################################
#
#       Created by Ronald Frazier
#       http://www.ronfrazier.net
#
#       Feel free to do anything you want with this, as long as you
#       include the above attribution.
#
#       History:
#          v1.00
#          v1.01 - Jan 2, 2010
#             *modified 'use' lines to specify version of RFLibs modules
#
################################################################################

use strict;
use IO::Socket::INET;
use RFLibs::IOSelectBuffered 1.00;
use RFLibs::Aquos 1.00;

my $listenport = 4684;
my $serialport_device = '/dev/ttyU0';

$|=1;

my $aquos = new RFLibs::Aquos($serialport_device);


my $listensocket = new IO::Socket::INET ( 
	LocalPort => $listenport,
	Proto => 'tcp',
	Listen => 1,
	Reuse => 1,
	Blocking => 1
	);
die ("Could not create socket: $!") unless $listensocket;


my $select = new RFLibs::IOSelectBuffered($listensocket);

while(my @ready = $select->can_read())
{
	return unless scalar(@ready);
	foreach my $handle (@ready)
	{
		#open a socket for the newly connected client
		if ($handle == $listensocket)
		{
			my $client = $listensocket->accept();
			$client->autoflush(1);
			$select->add($client);

			next;
		};

		#read the next line and test for error, EOF, socket disconnect, or just partial lines
		my $line = $select->getline($handle);
		if (!defined($line))
		{
			$select->remove($handle);
			$handle->close();
			next;
		};
		next if $line eq '';

		$line =~ s/[\n\r\f]+$//ms;

		if ($line eq 'EXIT')
		{
			$select->remove($handle);
			$handle->close();
			next;
		};

		my $result = processLine($line);
		syswrite($handle, "$result\n");
	};
};
print "EXITING\n";
exit;
	
sub processLine
{
	my ($line) = @_;

	if ($line =~ /^VOL[_ ]?(.*)/)
	{
		my $param = $1;
		if ($param eq '+')
		{
			return $aquos->adjust_volume(1);
		}
		elsif ($param eq '-')
		{
			return $aquos->adjust_volume(-1);
		}
		elsif ($param =~ /^\d+$/)
		{
			return $aquos->volume($param);
		}
		else
		{
			return $aquos->volume();
		};
	}
	elsif ($line =~ /^MUTE[_ ]?(.*)/)
	{
		my $param = $1;
		if ($param eq 'ON')
		{
			return $aquos->mute(1);
		}
		elsif ($param eq 'OFF')
		{
			return $aquos->mute(0);
		}
		elsif ($param eq 'TOGGLE')
		{
			return $aquos->toggle_mute();
		}
		else
		{
			return $aquos->mute();
		};
	}
	elsif ($line =~ /^POWER[_ ]?(.*)/)
	{
		my $param = $1;
		if ($param eq 'ON')
		{
			return $aquos->power(1);
		}
		elsif ($param eq 'OFF')
		{
			return $aquos->power(0);
		}
		elsif ($param eq 'TOGGLE')
		{
			my $state = $aquos->power() ? 0 : 1;
			return $aquos->power($state);
		}
		else
		{
			return $aquos->power();
		};
	}
	elsif ($line =~ /^INPUT[_ ]?(.*)/)
	{
		my $param = $1;
		if ($param =~ /^\d+$/)
		{
			return $aquos->input($param);
		}
		else
		{
			return $aquos->input();
		};
	}
	elsif ($line =~ /^SERIALPOWERUP[_ ]?(.*)/)
	{
		my $param = $1;
		if ($param eq 'ENABLE')
		{
			return $aquos->enable_serial_powerup(1);
		}
		elsif ($param eq 'DISABLE')
		{
			return $aquos->enable_serial_powerup(0);
		}
		else
		{
			#this doesn't seem to work
			return $aquos->enable_serial_powerup();
		};
	}
	elsif ($line =~ /^DEBUG[_ ]?(.*)/)
	{
		my $param = $1;
		if ($param ne '')
		{
			return $aquos->debug($param);
		}
		else
		{
			return $aquos->debug();
		};
	}
	elsif ($line =~ /^CMD[_ ]?(.{4})\s*(.*)/)
	{
		my $code = $1;
		my $param = $2;
		if ($param ne '')
		{
			return $aquos->set($code, $param);
		}
		else
		{
			return $aquos->get($code);
		};
	};
};
