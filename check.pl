use strict;

open(F,"<bg2eetrans/tob.tph") || die "tob.tph\n";
open(H,">bg2eetrans/tob2.tph") || die "can't create tob2.tph\n";
my %us = ();
read_tra("us.tra",\%us);
if (!$us{1}) {
	die "problème lecture us.tra\n";
}
my $orig;
while (<F>) {
	if (/^\/\//) {
		print H $_;
		next;
	}
	$orig = $_;
	if (/STRING_SET ~(\d+)~ @(\d+)/) {
		if ($1 != $2) {
			my $a = $1;
			my $b = $2;
			print "$1 != $2... ";
			my $sa = $us{$a};
			my $sb = $us{$b};
			die "pas trouvé chaine $a.\n" if (!$sa);
			die "pas trouvé chaine $b.\n" if (!$sb);
			if (($a == 16274 && $b == 17648) ||
				($a == 23811 && $b == 14043) ||
				($a == 23813 && $b == 388) ||
				($a == 24910 && $b == 24906) ||
				(($a == 33721 || $a == 33730) && $b == 33712) ||
			   	lc($sa) eq lc($sb)) {
				print "match\n";
			} elsif ($b != 30 && $b != 4927 && $sa !~ /\]$/ && $sb !~ /\]$/) {
				my $match = 0;
				if (length($sa) == length($sb)) {
					$match = 1;
					for (my $n=0; $n<length($sa); $n++) {
						my $c = substr($sa,$n,1);
						my $d = substr($sb,$n,1);
						if (!(mylc($c) eq mylc($d))) {
							$match = 0;
							last;
						}
					}
				} else {
					$match = check($sa,$sb);
				}
				if ($match) {
					print "ponctuation !\n";
				} else {
					print "differ :\n$a : $sa\n$b : $sb\n";
					sortie();
				}
			} else {
				print "auto-update...\n";
				print H "\tSTRING_SET ~$a~ \@$a	// updated by perl script\n";
				next;
			}
		}
	}
	print H $orig;
}
close(F);
close(H);

sub read_tra {
	my ($name,$hash) = @_;
	open(G,"<$name") || die "read_tra: $name\n";
	while (<G>) {
		next if (/^\/\//);
		while (!/\~$/ && !/\]$/) {
			$_ .= <G>;
		}
		chomp;
		if (/^\@(\d+) += (.+)/s) {
			$$hash{$1} = $2;
		}
	}
	close(G);
}

sub sortie {
	print H $orig;
	while (<F>) {
		print H;
	}
	close(F);
	close(H);
	exit(0);
}

sub mylc {
	my $a = lc(shift);
	$a = "." if ($a eq "," || $a eq "?" || $a eq ";");
	$a;
}

sub check {
	my ($sa,$sb) = @_;
	if (length($sb) > length($sa)) {
		return check($sb,$sa);
	}
	# Trouve le caractère qui change
	my ($a,$b) = (0,0);
	while ($a < length($sa)) {
		while (mylc(substr($sa,$a,1)) eq mylc(substr($sb,$b,1)) && $a < length($sa)) {
			$a++; $b++;
		}
		last if ($a == length($sa));
		print "check: differing character : ",substr($sa,$a,1)," n=$a\n";
		if (substr($sa,$a,1) !~ /[\, ]/) {
			return 0;
		}
		$a++;
	}
	return 1;
}
