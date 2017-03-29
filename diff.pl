# arguments : <fichier tra> <2ème fichier tra> <numéro d'entrée>
# affiche la différence exacte pour l'entrée entre les 2 ficheirs

use strict;
use v5.10;

my (@t1,@t2);
read_tra(shift @ARGV,\@t1);
read_tra(shift @ARGV,\@t2);
my $n = shift @ARGV || die "pas de numéro d'entrée à comparer";

my $ee = $t1[$n];
my $tob = $t2[$n];
my ($a1,$a2);
for ($a1=0; $a1<length($ee); $a1++) {
	last if (substr($ee,$a1,1) ne substr($tob,$a1,1));
}
for ($a2=0; $a2<length($ee); $a2++) {
	last if (substr($ee,length($ee)-1-$a2,1) ne substr($tob,length($tob)-1-$a2,1));
}
my $l1 = length($ee)-$a2-$a1;
my $l2 = length($tob)-$a2-$a1;
say "$ee\n$tob";
say "diff : ",substr($ee,$a1,$l1)," != ",substr($tob,$a1,$l2);
say "ou en indices $a1,$l1 et $a2,$l2";

sub read_tra {
	my ($name,$tab) = @_;
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
		s/[,;!\?\:\.]/ /g if (/[a-z]/i);
		s/ +/ /g;
		s/ \n/\n/g; # juste un espace en fin de chaine, et ça différencie quelques entrées !!!
		s/(^|\~) /$1/m if (!/^\~ \~/); # en début de ligne aussi...
		s/\~\[/\~ \[/; # espace entre fin de phrase et [
		s/ would've / would have /g;
		s/ gotta / got to /g;
		s/'ve / have /g;
		s/ (the|a) / /g; # un article qui saute des fois...
		s/ that / who /g;
		s/'ey /hey /g;
		s/ wanna / want to /g;
		s/ ya / you /g;
		if (/^\@(\d+) += (.+)/s) {
			$$tab[$1] = $2;
		}
	}
	close(G);
}
