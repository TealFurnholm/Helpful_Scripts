$input = $ARGV[0];
while($input !~ /\w/){ 
	print "please indicate input and output files, ex: perl RemovePoly.pl input.fastq output.fastq \n";
	$input = $ARGV[0];
}
open(INPUT, $input)||die;
$output = $ARGV[1];
while($output !~ /\w/){ 
	print "please indicate input and output files, ex: perl RemovePoly.pl input.fastq output.fastq \n";
	$output = $ARGV[1];
}
open(OUTPUT, ">", $output)||die;
$outbad = "badreads.fastq';
open(OUTBAD, ">", $outbad)||die;

$on=0;
while( my $line = <INPUT> . <INPUT> . <INPUT> . <INPUT> ) {
	$totreads++;
   
	@stuff = split("\n", $line);
	if($stuff[1] =~ /\W/){print "non-nucleotide detected at $line, maybe file parsing issue for sample, make sure all lines in file match fastq format\n"; next;}

	$stuff[1] =~ s/^N+|N+$//g; #remove leading/trailing NNNs
	$len = length($stuff[1]);

	#remove Polys
	my $As = $stuff[1] =~ tr/Aa/AA/;
	my $Ts = $stuff[1] =~ tr/Tt/TT/;
	my $Gs = $stuff[1] =~ tr/Gg/GG/;
	my $Cs = $stuff[1] =~ tr/Cc/CC/;
	if($As > $len*3/4 && $stuff[1] =~ /A{25,}/){$A++; print OUTBAD "$line"; next;}
	if($Ts > $len*3/4 && $stuff[1] =~ /T{25,}/){$T++; print OUTBAD "$line"; next;}
	if($Gs > $len*3/4 && $stuff[1] =~ /G{25,}/){$C++; print OUTBAD "$line"; next;}
	if($Cs > $len*3/4 && $stuff[1] =~ /C{25,}/){$G++; print OUTBAD "$line"; next;}

	#remove short
	$stuff[1]=~ s/^.{0,1}(A{20,}|T{20,}|G{20,}|C{20,})//;
	$stuff[1]=~ s/(A{20,}|T{20,}|G{20,}|C{20,}).{0,1}$//;
	if(length($stuff[1]) < 50){$S++; print OUTBAD "$line"; next;}

	
	#remove repeats
	if($stuff[1] =~ /(.{2,6})\1{5}/){
		$REPs = $stuff[1];
		$REPs =~ s/(.{2,6})\1{5,}//g;
		if(length($REPs)<50){$S++; print OUTBAD "$line"; next;}
		else{ $stuff[1] =~ s/^((.{2,6})\1{5,}|(.{2,6})\1{5,}$)//g;}
		}

	#deduplicate
	#$RC{$stuff[1]}++;
	$good++;
	
	#print "end\t$stuff[1]\n\n";
	$len = length($stuff[1]);
	$score = "J"x$len;
	$line = "$stuff[0]\n$stuff[1]\n+\n$score\n";
	print OUTPUT "$line";
	if($on%1000000==0){$time=localtime; print "on $on time $time\nPolyA\t$A\nPolyT\t$T\nPolyC\t$C\nPolyG\t$G\nToo_Short\t$S\nTotal_RC\t$totreads\nSurviving_RC\t$good\n";} $on++;	
}
	#foreach(keys %RC){$uniq++; print OUTPUT ">Uniq$uniq\;size\=$RC{$_}\n$_\n";}
	print "PolyA\t$A\nPolyT\t$T\nPolyC\t$C\nPolyG\t$G\nToo_Short\t$S\nTotal_RC\t$totreads\nSurviving_RC\t$good\n";
