# essaye de trouver les correspondances pour tob
# l'idée est que tout le fichier y est, il y a juste des trous à trouver où
# ils ont inséré autre chose

use strict;
use v5.20;
use String::Similarity;

my ($f,$g);
open($f,"<us.tra") || die "us.tra";
open($g,"tob_us.tra") || die "tob_us.tra";

my $start = 0;
my ($us,$tob);
my $n = $start;
while ($us = read_tra($f)) {
	my $tob = read_tra($g);
	if ($us ne $tob && !grep /^$n$/,(1254,1255, # Pour ces 2 là, insertions ee, traduits par bgee
		4644, # livre de sorts infinis renommé ?
		5497,5498,5631,5656,5852,5925, # des trucs qui n'avaient pas de son dans tob, qui en ont maintenant
		6073,6483,6644, # artefact renommé
		6651, # test string !
		6662, # armure de cuir+2 -> protecteur du second
	   6663,  # la desc de l'armure du second devient "fiche du personnage"
	   6688, # desc armure ankeg améliorée
	   6714,6723,6740,6750,6787,6788,6794,6796,6799,6800,6801,6802,6810,6822,6826,6827,6828,6829,6832,6833,6834,6835,6837,6838,6849,6850,6868,6870,6878,6888, # artefact renommé
	   6890,6892,6896,6899, # et encore
	   8339, # spécial
	   # déscriptions de classes : courtes dans tob, longues dans ee,
	   # reprises de bgee pour la traduc
	   9557, # ranger
	   9558, # paladin
	   9559, # cleric
	   9560, # druide
	   9561, # voleur
	   9564, # abjurer
	   9565, # conjurer
	   9566, # diviner
	   9567, # enchanter
	   9568, # illusionist
	   9569,
	   9570,
	   9571,
	   9577, # cleric/mage
	   10062, # chaine vide dans tob, copie du 10096 dans bg2ee... !
	   10231, # alora lucky rabit foot, version longue
	   10677,10678,10679,10680,10681, # paroles d'intro "le seigneur du meurtre périra..."
	   # 11040 : c'est carrément une voix d'imoen, imoen22, qui a un
	   # mauvais texte associé, mais bizarrement l'audio français était
	   # bon! Corrigé dans dialogtob, c'est bon. 11041: imoen26 !
	   11040,11041,11056,
	   11053, 11056, # renommage d'artefacts... cimeterres de Drizzt
	   11063,11065, # clip audio felff, la vf est ridicule, texte parfois corrigé
	   11178,11221,11226,11231,11232,11233,11236,11237,11243,11244,11273, # corrigé dialogtob
	   11287,11288,11289,11290, # pareil, dialogue prostituée
	   11294, # mineur
	   11297,11361,11542,11544,11568,11570, # dialogues audio...
	   11618,11640,11693,11713,11714,11715,11716,11717,11718,11719,11723,11724,11725,11726,11876,11877,11878,
	   13967,15064,15909,15910,
	   # les sons du joueur, 16235 à 60, je n'ai traduit qu'homme5, je
	   # laisse les autres !
	   16235,16236,16237,16238,16239,16240,16241,16242,16243,16244,
	   16245,16246,16247,16248,16249,16250,16251,16252,16253,16254,
	   16255,16256,16257,16258,16259,16260,
	   16301, # un texte du début de bg1, n'est pas dans tob, uniquement dans bg2ee, laissé tel quel.
	   17134,17135,17136, # 3 résolutions dans bg2ee, probablement inutilisées !
	   17188,17190, # recette portraits custom, traduit et ajouté l'info linux !
	   17245, # kit mage, traduit par bgee
	   19314,20617,
	   22213, # doublon avec la desc au-dessus (22211), donc supprimé.
	   22219,22221, # mis à jour desc artefact
	   22262, # kneecapper ? Gardé l'ancien nom... !
	   22738, # bombe de proximité, mis à jour desc
	   23984,23985, # édité par bgee
	   24160, # màj du texte pas mal en fr
	   25213, # bgee
	   29092, # mis à jour fr
	   31119, # bgee
	   31656, # alors là le son ssword20 n'est pas du tout le même en fr et en us ! Bon... On a traduit le texte, mais on peut pas faire grand chose pour la voix !
	   32122, # encore du son où ils ont mis des sous titres...
	   34171,38803,39678,39769,49477,55369,57352,60102,60403,60674,60724,60741,61979,64973,64975,70994, # mis à jour fr

	)) {
		my $sim = similarity($us,$tob);
		say "$n: $sim";
		last if ($sim < 0.5);
	}
	$n++;
}
close($f);
close($g);
say "terminé à n=$n";

sub comp {
	my ($us,$tob) = @_;
	my ($a1,$a2);
	for ($a1=0; $a1<length($us); $a1++) {
		last if (substr($us,$a1,1) ne substr($tob,$a1,1));
	}
	for ($a2=0; $a2<length($us); $a2++) {
		last if (substr($us,length($us)-1-$a2,1) ne substr($tob,length($tob)-1-$a2,1));
	}
	if (length($us) > length($tob) && length($us)-length($tob) < 10) {
		# faut trouver où ça reprend...
		my $l;
		for ($l=1; $l<=length($us)-length($tob); $l++) {
			last if (substr($us,$a1+$l,1) eq substr($tob,$a1,1));
		}
		die "l overflow:$l n=$n\nus =$us.\ntob=$tob.\n"."us:".length($us)." tob:".length($tob) if ($l > length($us)-length($tob));
		return comp(substr($us,$a1+$l), substr($tob,$a1));
	} elsif (length($tob) > length($us) && length($tob) - length($us) < 10) {
		return comp(substr($tob,$a1+length($tob)-length($us)), substr($us,$a1));
	} elsif (length($us) != length($tob)) {
		die "diff len ".(length($tob)-length($us))."\nus :$us\ntob:$tob\nn=$n a1=$a1";
	}
	my $l1 = length($us)-$a2-$a1;
	my $l2 = length($tob)-$a2-$a1;
	return if ($l1 < 10 && $l2 < 10);
	for (my $l=1; $l<10; $l++) {
		return comp(substr($us,$a1+$l),substr($tob,$a1+$l)) if (substr($us,$a1+$l,3) eq substr($tob,$a1+$l,3));
	}
	my $s1 = substr($us,$a1,$l1);
	say "diff : $s1 (",asc($s1),") != ",substr($tob,$a1,$l2);
	say "ou en indices $a1,$l1 et $a2,$l2";
	die "diff n=$n\ntob: $tob\nus : $us";
}
sub asc {
	my $s = shift;
	my $ret = "";
	for (my $n=0; $n<length($s); $n++) {
		$ret .= sprintf("0x%x ",ord(substr($s,$n,1)));
	}
	$ret;
}

sub read_tra {
	my ($f) = @_;
	while (<$f>) {
		next if (/^\/\//);
		/^\@(\d+) += (.)(.+)/;
		my $pre = $2; # préfixe de la valeur à réutiliser
		my $nb = 0;
		while (!/($pre|\])$/) {
			$_ .= <$f>;
		}
		chomp;
		$_ = lc($_);
		s/[,;!\?\:\.]/ /g if (/[a-z]/i);
		s/ \n/\n/g; # juste un espace en fin de chaine, et ça différencie quelques entrées !!!
		s/(^|\~) /$1/m if (!/^\~ \~/); # en début de ligne aussi...
		s/\~\[/\~ \[/; # espace entre fin de phrase et [
		s/ would've / would have /g;
		s/ gotta / got to /g;
		s/'ve / have /g;
		s/'re/ are /g;
		s/'twas/it was/g;
		s/<pro_himher>/him/g;
		s/<pro_heshe>/he/g;
		s/ (the|a) / /g; # un article qui saute des fois...
		s/ that / who /g;
		s/'ey /hey /g;
		s/ wanna / want to /g;
		s/ ya / you /g;
		s/alright/all right/g;
		s/twelve hundred/1 200/g;
		s/a thousand/1 000/g;
		s/<charname>//g;
		s/thousand/1 000/g;
		s/'(.+)'/"$1"/g;
		s/'/"/g;
		s/\xe2\x80\x94/\-/g;
		s/\-/ /g;
		s/ +/ /g;
		if (/^\@(\d+) += (.+)/s) {
			die "n=$n mais lu $1" if ($1 != $n);
			return $2;
		}
	}
}

