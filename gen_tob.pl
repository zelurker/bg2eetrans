# tiré de gen_bgee mais pour tob, donc on ne adapte l'existant...

use strict;
use v5.20;

my (%us,%tob,%fr);
read_tra("us.tra",\%us);
read_tra("tob_us.tra",\%tob);
read_tra("bg2eetrans/language/fr_fr/dialogtob.tra",\%fr);
my %out;
my ($min,$max) = (200000,0);
foreach (keys %us) {
	if ($tob{$_} && !$fr{$_}) {
		my $s = $_;
		my $bg = 200000;
		foreach (@{$tob{$s}}) { # on garde l'indice le + petit trouvé parce que certaines chaines ne sont pas traduites dans la vf de tob !
			# malheureusement même comme ça on récupère quand même des
			# chaines anglaises !
			$bg = $_ if ($_ < $bg);
		}
		next if ($bg > 74106); # + de traducs sur l'us que sur le fr !!!
		$min = $bg if ($bg < $min);
		$max = $bg if ($bg > $max);
		foreach (@{$us{$s}}) {
			$out{$_} = $bg;
		}
	}
}
my @fr;
open(F,"<bg2eetrans/tob.tph") || die "can't read tob.tph !\n";
open(G,">tob.tph") || die "can't create tob2.tph\n";
say G "// tob.tph : automatically generated, exact matches only !";
say G "// (ignoring ponctuation)";
say G "";
my ($key,$last,$val);
foreach (sort { $a <=> $b } keys %out) {
	my $num = $_;
	if (!$key || $key < $_) {
		while (<F>) {
			if (/STRING_SET ~(\d+)~ @(\d+)/) {
				$key = $1;
				$last = $_;
				$val = $2;
				print G $last if ($key < $num);
				last if ($key >= $num);
			}
		}
	}
	if ($key != $num || ($key == $num &&
			($last =~ /^\/\// || $val != $out{$num}))) {
		say "$num added/fixed";
		say G "\tSTRING_SET ~$num~ \@$out{$num}\t// gen_tob.pl prev: $key / $val";
	} elsif ($key == $num) {
		print G $last;
	}
}
close(G);
close(F);

sub read_tra {
	my ($name,$hash) = @_;
	say "reading tra $name";
	open(G,"<$name") || die "read_tra: $name\n";
	while (<G>) {
		next if (/^\/\//);
		/^\@(\d+) += (.)(.+)/;
		my $pre = $2; # préfixe de la valeur à réutiliser
		my $nb = 0;
		while (!/($pre|\])$/) {
			$_ .= <G>;
		}
		chomp;
		$_ = lc($_);
		s/[,;!\?\:\.]/ /g;
		s/ +/ /g;
		s/ \n/\n/g; # juste un espace en fin de chaine, et ça différencie quelques entrées !!!
		s/ would've / would have /g;
		s/ gotta / got to /g;
		s/'ve / have /g;
		s/ (the|a) / /g; # un article qui saute des fois...
		s/ that / who /g;
		if (/^\@(\d+) += (.+)/s) {
			if (!$$hash{$2}) {
				$$hash{$2} = [$1];
			} else {
				push @{$$hash{$2}}, $1;
			}
		}
	}
	close(G);
}

