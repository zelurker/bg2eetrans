# Génère le fichier bgee.tph à partir de 0
# l'idée est de se rabattre sur la traduc de bgee quand on y trouve ce
# qu'on veut. Donc on l'a ou pas, on ne veut pas de devinette à base
# d'approximations, juste ce qui y est

use strict;
use v5.20;

my (%us,%bgee);
read_tra("us.tra",\%us);
read_tra("bgee_us.tra",\%bgee);
my %out;
my ($min,$max) = (200000,0);
foreach (keys %us) {
	if ($bgee{$_}) {
		my $s = $_;
		my $bg = 200000;
		foreach (@{$bgee{$s}}) { # on garde l'indice le + petit trouvé parce que certaines chaines ne sont pas traduites dans la vf de bgee !
			# malheureusement même comme ça on récupère quand même des
			# chaines anglaises !
			$bg = $_ if ($_ < $bg);
		}
		$min = $bg if ($bg < $min);
		$max = $bg if ($bg > $max);
		foreach (@{$us{$s}}) {
			$out{$_} = $bg;
		}
	}
}
open(F,"<bg2eetrans/bgee_manual.tph") || die "peut pas lire les modifs manuelles: bgee_manual.tph\n";
my %manual;
while (<F>) {
	if (/STRING_SET ~(\d+)~ @(\d+)/) {
		$manual{$2} = $2;
	}
}
close(F);
my @fr;
load_fr("bgee_fr.tra",\@fr);
open(F,">dialogbgee.tra") || die "can't create dialogbgee.tra !\n";
open(G,">bgee.tph") || die "can't create bgee2.tph\n";
say G "// bgee.tph : automatically generated, exact matches only !";
say G "// (ignoring ponctuation)";
say G "";
foreach (sort { $a <=> $b } keys %out) {
	if ($fr[$out{$_}] !~ /(This|It's|what|No )/i) {
		say F sprintf("\@%-5d",$_)," = $fr[$out{$_}]";
		say G "STRING_SET ~$_~ \@$_";
#	} elsif ($out{$_} == 32341) {
#		my $truc = $fr[$out{$_}];
#		say "rejeté sur $truc\n";
#		die "this\n" if ($truc =~ /This/i);
#		die "its\n" if ($truc =~ /It's/i);
#		die "what\n" if ($truc =~ /what/i);
#		die "no\n" if ($truc =~ /no /i);
	}
}
# pas de string_set pour les manual ils sont déjà indiqués !
foreach (sort { $a <=> $b } keys %manual) {
	if ($fr[$manual{$_}] !~ /(This|It's|what|No )/i) {
		say F sprintf("\@%-5d",$_)," = $fr[$manual{$_}]";
	}
}
close(F);
close(G);

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
		if (/^\@(\d+) += (.+)/s) {
			if (!$$hash{$2}) {
				$$hash{$2} = [$1];
			} else {
				push @{$$hash{$2}}, $1;
			}
#			my $s = $2;
#			if (/a know alignment spell/) {
#				say join(",",@{$$hash{$s}});
#			}
		}
	}
	close(G);
}

sub load_fr {
	my ($name,$rtab) = @_;
	say "reading fr $name";
	open(G,"<$name") || die "read_fr $name\n";
	my $last;
	while (<G>) {
		next if (/^\/\//);
		/^\@(\d+) += (.)(.+)/;
		my $pre = $2; # préfixe de la valeur à réutiliser
		if (length($pre) > 1) {
			die "pre merdoie pour $_ : pre=$pre last=$last\n";
		}
		while (!/($pre|\])$/ || /\\\]$/) {
			$_ .= <G>;
		}
		chomp;
		if (/^\@(\d+) += (.+)/s) {
			$$rtab[$1] = $2;
		} else {
			say "sale chaine $_";
		}
		$last = $_;
	}
	close(G);
}
