use strict;
use warnings FATAL => 'all';
use feature 'say';

use File::Slurp;
use Data::Dumper;
use List::Util;

$Data::Dumper::Sortkeys = 1;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D19.txt');

my @scanners;
foreach my $line (@puzzle) {
	$line =~ s/^\s+|\s+$//g;
	next unless $line;

	if ($line =~ m/scanner (\d+)/) {
		push(@scanners, {});
	}
	else {
		$scanners[-1]->{beacons}->{$line} = {};
	}
}

my $got_something = 1;
while ($got_something) {
	$got_something = 0;
	say "Scanners left open to get merged is " . (scalar(@scanners) - 1);

	foreach my $scanner (@scanners) {
		foreach my $beacon (keys %{$scanner->{beacons}}) {
			$scanner->{beacons}->{$beacon} = {}
		}
	}

	foreach my $scanner (@scanners) {
		foreach my $beacon1 (keys %{$scanner->{beacons}}) {
			foreach my $beacon2 (keys %{$scanner->{beacons}}) {
				next if $beacon1 eq $beacon2;
				my ($m1, $n1, $o1) = split ",", $beacon1;
				my ($m2, $n2, $o2) = split ",", $beacon2;
				my $fp = join("#", sort {$a <=> $b} (abs($m1 - $m2), abs($n1 - $n2), abs($o1 - $o2)));
				$scanner->{beacons}->{$beacon1}->{$fp} = $beacon2;
				$scanner->{beacons}->{$beacon2}->{$fp} = $beacon1;
			}
		}
	}

	foreach my $scanner (@scanners) {
		next if $scanner == $scanners[0];

		my %matches;
		foreach my $beacon1 (keys %{$scanner->{beacons}}) {
			foreach my $beacon0 (keys %{$scanners[0]->{beacons}}) {
				if (10 < scalar grep {$scanners[0]->{beacons}->{$beacon0}->{$_}} keys %{$scanner->{beacons}->{$beacon1}}) {
					#say "$beacon1 matches $beacon0";
					@{$matches{$beacon0}} = split(/,/, $beacon1);
				}
			}
		}

		next unless keys %matches;

		# Check all possibilities
		foreach my $i (1 .. 48) {
			my %results;
			foreach my $match (keys %matches) {
				my ($m, $n, $o, @axes);

				if ($i % 6 < 2) {
					$m = $matches{$match}[0];
					if ($i % 6 == 1) {
						$n = $matches{$match}[1];
						$o = $matches{$match}[2];
						@axes = ("x", "y", "z");
					}
					else {
						$n = $matches{$match}[2];
						$o = $matches{$match}[1];
						@axes = ("x", "z", "y");
					}
				}
				elsif ($i % 6 < 4) {
					$m = $matches{$match}[1];
					if ($i % 6 == 3) {
						$n = $matches{$match}[0];
						$o = $matches{$match}[2];
						@axes = ("y", "x", "z");
					}
					else {
						$n = $matches{$match}[2];
						$o = $matches{$match}[0];
						@axes = ("y", "z", "x");
					}
				}
				else {
					$m = $matches{$match}[2];
					if ($i % 6 == 5) {
						$n = $matches{$match}[0];
						$o = $matches{$match}[1];
						@axes = ("z", "x", "y");
					}
					else {
						$n = $matches{$match}[1];
						$o = $matches{$match}[0];
						@axes = ("z", "y", "x");
					}
				}

				if ($i > 6 && $i < 13 || $i > 24 && $i < 37 || $i > 42) {
					$m *= -1;
					$axes[0] = "-" . $axes[0];
				}

				if ($i > 12 && $i < 19 || $i > 24 && $i < 31 || $i > 36) {
					$n *= -1;
					$axes[1] = "-" . $axes[1];
				}
				if ($i > 18 && $i < 25 || $i > 30) {
					$o *= -1;
					$axes[2] = "-" . $axes[2];
				}

				my ($x, $y, $z) = split(/,/, $match);

				my $current_result = ($x - $m) . "," . ($y - $n) . "," . ($z - $o);

				@{$results{$current_result}} = (($x - $m), ($y - $n), ($z - $o), @axes, $i);

				last if keys %results > 1;
			}

			if (keys(%results) == 1) {
				foreach my $result (keys(%results)) {
					say "Position of scanner $scanner from scanner 0 perspective is $result";
					my @vals = @{$results{$result}};
					foreach my $beacon1 (keys %{$scanner->{beacons}}) {
						my @beacon_val = split(/,/, $beacon1);
						for my $i (0 .. 2) {
							$beacon_val[$i] *= -1 if $vals[$i + 3] =~ m/^-/;
							$beacon_val[$i] += $vals[$i];
						}
						my $line;
						foreach my $axe (qw(x y z)) {
							for my $i (0 .. 2) {
								if ($vals[$i + 3] =~ m/$axe/) {
									$line .= $beacon_val[$i] . ",";
								}
							}
						}
						chop($line);
						if ($scanners[0]->{beacons}->{$line}) {
							#say "Beacon already detected before .. skipped ... $line";
						}
						else {
							#say "New Beacon created at sensor 0! .... $line";
							$scanners[0]->{beacons}->{$line} = {};
						}
					}
				}
				$got_something = 1;
				say "Scanner $scanner removed .. Lets retry to try to merge another one.";
				@scanners = grep {$_ != $scanner} @scanners;
			}
		}
	}
}

my $ctr_beacons = 0;
foreach my $scanner (@scanners) {
	foreach my $beacon1 (keys %{$scanner->{beacons}}) {
		++$ctr_beacons;
	}
}

say "Beacons found in total: $ctr_beacons";