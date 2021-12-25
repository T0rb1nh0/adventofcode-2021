use strict;
use warnings FATAL => 'all';
use feature 'say';

use File::Slurp;
use Data::Dumper;
use List::Util;

$Data::Dumper::Sortkeys = 1;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D19.txt');

my @scanners;
# Load data from file
foreach my $line (@puzzle) {
	$line =~ s/^\s+|\s+$//g;
	next unless $line;

	if ($line =~ m/scanner (\d+)/) {
		push(@scanners, {});
		$scanners[-1]->{id} = $#scanners;
	}
	else {
		$scanners[-1]->{beacons}->{$line} = {};
	}
}

my @positions = ("0,0,0");

my $got_something = 1;
while ($got_something) {
	$got_something = 0;

	say "-----------------------------------------------------------------------";
	say "" . (@scanners - 1) . " scanners left open to get merged into scanner 0.";

	# Reset fingerprints
	foreach my $scanner (@scanners) {
		foreach my $beacon (keys %{$scanner->{beacons}}) {
			$scanner->{beacons}->{$beacon} = {}
		}
	}

	# Calculate fingerprints for each beacon ( List of distances between all other beacons of the same scanner. )
	foreach my $scanner (@scanners) {
		foreach my $beacon1 (keys %{$scanner->{beacons}}) {
			foreach my $beacon2 (keys %{$scanner->{beacons}}) {
				next if $beacon1 eq $beacon2; # Dont calculate distance between itself.
				my ($m1, $n1, $o1) = split ",", $beacon1;
				my ($m2, $n2, $o2) = split ",", $beacon2;
				my $fp = join("#", sort {$a <=> $b} (abs($m1 - $m2), abs($n1 - $n2), abs($o1 - $o2)));
				# Store fingerprint for both beacons
				$scanner->{beacons}->{$beacon1}->{$fp} = $beacon2;
				$scanner->{beacons}->{$beacon2}->{$fp} = $beacon1;
			}
		}
	}

	# Merge next scanner into scanner 0
	foreach my $scanner (@scanners) {
		next if $scanner == $scanners[0];

		my %matches;
		foreach my $beacon1 (keys %{$scanner->{beacons}}) {
			foreach my $beacon0 (keys %{$scanners[0]->{beacons}}) {
				# Both beacons of scanner0 and current scanner have more than ten times the same fp? They must be a match!
				if (10 < scalar grep {$scanners[0]->{beacons}->{$beacon0}->{$_}} keys %{$scanner->{beacons}->{$beacon1}}) {
					say "Fingerprints of beacon $beacon1 of scanner $scanner->{id} does match beacon $beacon0 of scanner 0.";
					@{$matches{$beacon0}} = split(/,/, $beacon1);
				}
			}
		}

		# No matches? Lets move on because the needed beacons seems to be still part of different scanners than scanner 0.
		next unless keys %matches;

		# Detect direction and rotation of scanner X compared to scanner 0 based on previously collected matches.
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

				# Beacon 0 values are always on the correct axes.
				my ($x, $y, $z) = split(/,/, $match);

				my $current_result = ($x - $m) . "," . ($y - $n) . "," . ($z - $o);

				@{$results{$current_result}} = (($x - $m), ($y - $n), ($z - $o), @axes);

				#say "$i: Discrepancy between scanner $scanner->{id} and scanner 0 is $current_result ($x - $m)  ($y - $n)  ($z - $o)" if $i == 26;
			}

			# No results found? Nothing to get merged!
			next if keys %results > 1;

			foreach my $result (keys(%results)) {
				my @vals = @{$results{$result}};

				say "Position of scanner $scanner->{id} from scanner 0 perspective is $result with axes " . join(",", ($vals[3], $vals[4], $vals[5]));

				push(@positions, $result);

				foreach my $beacon1 (keys %{$scanner->{beacons}}) {

					my @beacon_val = split(/,/, $beacon1);
					my $col = 0;
					my $line;
					for my $i (3 .. 5) {
						if ($vals[$i] =~ m/x/) {
							my $val = $beacon_val[0];
							if ($vals[$i] =~ m/^-/) {
								$val *= -1;
							}
							$val += $vals[$col++];
							$line .= $val . ",";
						}
						elsif ($vals[$i] =~ m/y/) {
							my $val = $beacon_val[1];
							if ($vals[$i] =~ m/^-/) {
								$val *= -1;
							}
							$val += $vals[$col++];
							$line .= $val . ",";
						}
						elsif ($vals[$i] =~ m/z/) {
							my $val = $beacon_val[2];
							if ($vals[$i] =~ m/^-/) {
								$val *= -1;
							}
							$val += $vals[$col++];
							$line .= $val . ",";
						}
					}
					chop($line);
					if ($scanners[0]->{beacons}->{$line}) {
						say "Beacon $beacon1 of scanner $scanner->{id} already exists at scanner 0 as $line .. skipped";
					}
					else {
						say "New Beacon $line created at scanner 0 for scanner $scanner->{id} $beacon1";
						$scanners[0]->{beacons}->{$line} = {};
					}
				}
			}
			$got_something = 1;
			say "Scanner $scanner->{id} removed. Lets try to merge another one.";
			@scanners = grep {$_ != $scanner} @scanners;
			last;
		}
	}
}

my $ctr_beacons = 0;
foreach my $scanner (@scanners) {
	foreach my $beacon1 (keys %{$scanner->{beacons}}) {
		++$ctr_beacons;
	}
}

my $biggest_distance = 0;
foreach my $position1 (@positions) {
	foreach my $position2 (@positions) {
		next if $position1 eq $position2;
		my ($x1, $y1, $z1) = split(/,/, $position1);
		my ($x2, $y2, $z2) = split(/,/, $position2);
		my $distance = ($x1 - $x2 + $y1 - $y2 + $z1 - $z2);
		$biggest_distance = $distance if $distance > $biggest_distance;
	}
}

say "Beacons found in total: $ctr_beacons";

say "Biggest distance between two scanners: $biggest_distance";