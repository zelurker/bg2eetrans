use strict;
use v5.20;

# detects small text differences, like an s added in ee, a slight change or
# so
# it looks at the difference between the strings and if the length of the
# difference is < 5 (arbitrary !), then we suppose it's just a small fix
# and the string is validated

my (@ee,@tob);
say "reading ee us version...";
read_tra("us.tra",\@ee);
say "reading tob us version...";
read_tra("/home/manu/bg2us/us.tra",\@tob);
say "reading tob.tph...";
open(F,"<bg2eetrans/tob.tph") || die "tob.tph\n";
open(G,">bg2eetrans/tob2.tph") || die "tob2.tph\n";
my $nb = 0;
while(<F>) {
	if (!/^\/\/[ \t]*STRING_SET \~(\d+)\~ \@(\d+)/ || $1 == 1212 || $1 == 1213) {
		print G;
		next;
	}
	my $ee = $ee[$1];
	my $tob = $tob[$2];
	my ($a1,$a2);
	for ($a1=0; $a1<length($ee); $a1++) {
		last if (substr($ee,$a1,1) ne substr($tob,$a1,1));
	}
	for ($a2=0; $a2<length($ee); $a2++) {
		last if (substr($ee,length($ee)-1-$a2,1) ne substr($tob,length($tob)-1-$a2,1));
	}
    my $l1 = length($ee)-$a2-$a1;
    my $l2 = length($tob)-$a2-$a1;
	if ($l1 < 5 || $l2 < 5) {
		print "$_";
		say "$ee\n$tob";
		say "diff : ",substr($ee,$a1,$l1)," != ",substr($tob,$a1,$l2);
		say "ou en indices $a1,$l1 et $a2,$l2";
		print G "\tSTRING_SET ~$1~ \@$2 // revalidated by check2.pl !\n";
		$nb++;
	} else {
		print G;
	}
}
close(F);
close(G);
say "trouvé : $nb";

sub read_tra {
	my ($name,$rtab) = @_;
	open(G,"<$name") || die "read_tra: $name\n";
	while (<G>) {
		next if (/^\/\//);
		while (!/\~$/ && !/\]$/) {
			$_ .= <G>;
		}
		chomp;
		if (/^\@(\d+) += (.+)/s) {
			$$rtab[$1] = $2;
		}
	}
	close(G);
}

