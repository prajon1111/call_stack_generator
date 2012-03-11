$depth = 0;
sub printline($$);
#sub printecmd;
#sub printnconfigindex;
#sub nParamIndex;
open(MYFILE, "callflow.txt");
@lines = <MYFILE>;
close(MYFILE);

open(MYFILE, ">output.txt");
print MYFILE "\t\t\t A9 \t\t\t         Ducati";
foreach $line (@lines)
{
	if($line =~ m/i2c/)
	{
		next;

	}
	if($line =~ m/Entering/)
	{
		printline($line, "enter");
		$depth++;
	}
	if($line =~ m/Exiting/)
	{
		printline($line, "exit");
		$depth--;
	}
	if($line=~m/PARAMETERS/)
	{
		if($line=~m/nConfigIndex/)
		{
				printline($line,"nConfigIndex");
		}
		elsif($line=~m/nParamIndex/)
		{
			printline($line,"nParamIndex");
		}
		elsif($line=~m/eCmd/)
		{
			printline($line,"eCmd");
		}
	}
}

system("type output.txt");



sub printline($$)
{
	my $line = shift @_;
	my $dir = shift @_;
	my $temp_depth=$depth;

	while($temp_depth >= 0)
	{
		print MYFILE  "\n\t\t\t\|\t\t\t\t\|";
		print MYFILE  "\n\t\t\t\|";
		$temp_depth--;
	}



	if($dir eq "enter")#FOR EX==Prasad Log:Entering Function RPC_SKEL_SendCommand
	{
		my ($field, $value) = $line =~ m/(.*unction)(.*)$/;
		print MYFILE $value;
		print MYFILE "\n\t\t\t\|=============================>>\|";
	}

	elsif ($dir eq "exit")#FOR EX==Prasad Log:Exiting Function RPC_SKEL_SendCommand with return value 0x0
	{
		my ($field, $value) = $line =~ m/(.*unction)(.*)$/;
		my @val=split /\s/,$value;
	 	print MYFILE $val[1]," ",$val[5];
		print MYFILE  "\n\t\t\t\|<<=============================\|";
		print MYFILE  "\n\t\t\t\|\t\t\t\t\|";
		print MYFILE  "\n\t\t\t\|\t\t\t\t\|";
		print MYFILE  "\n\t\t\t\|\t\t\t\t\|";
	}

	elsif ($dir eq "eCmd")#FOR EX==Prasad Log:PARAMETERS:Function RPC_SKEL_SendCommand, hComp=0x4289c0, eCmd=0x0, nParam=3, pCmdData=0xa006c8cc
	{
		require 'OMX_COMMANDTYPE.pl';
		my ($field,$value)=$line=~m/(.*unction)(.*)$/;
		my @value=split /,/,$value;  #value contains parameters starting with space(as in log there is space)
		my $eCmd=$value[2];
		my $nParam=$value[3];
		my ($ignore,$eCmd)=$eCmd=~m/(.*0x)(.*)$/;
		my ($ignore,$nParam)=$nParam=~m/(.*=)(.*)$/;
		print MYFILE  "\n\t\t\t\|-------------------------------\|";
		print MYFILE "\r\t\t\t";
		for ($i=1;$i<@value;$i++)
		{		
			if ($i eq 2)
			{
				
				if ($eCmd=~m/0/)
				{
					print MYFILE $OMX_COMMANDTYPE{$eCmd}," to ";
					print MYFILE $OMX_STATETYPE{$nParam}," ";
					$i++;
				}
				else
				{
					print MYFILE $OMX_COMMANDTYPE{$eCmd};
					##print MYFILE "(Target Port ID)";
				}
			}
			else
			{
				print MYFILE $value[$i]," ";  ###print $i ne $value-1?",":".\n";
			}
		}
		print  MYFILE "\n\t\t\t\|\t\t\t\t\|";
		print  MYFILE "\n\t\t\t\|\t\t\t\t\|";
		print  MYFILE "\n\t\t\t\|\t\t\t\t\|";
			
	}

	elsif ($dir eq "nParamIndex")#FOR EX=Prasad Log:PARAMETERS:Function Name RPC_SKEL_GetParameter,nParamIndex=0x7f000025,pCompParam=0xa006a1c8
	{
                my $nParamIndexFlag=10000;
		require 'OMX_TI_INDEXTYPE.pl';
                my ($field,$value)=$line=~m/(.*unction)(.*)$/;
		my @value=split /,/,$value;  
		my $nParamIndex=$value[1];
		($ignore,$nParamIndex)=$nParamIndex=~m/(.*=)(.*)$/;    ##debugprint $nParamIndex,"\n";
		print MYFILE  "\n\t\t\t\|<------------------------------\|";
		print MYFILE "\r\t\t\t";
		for ($i=1;$i<@value;$i++)
		{		
			if ($i eq 1)
			{
				print MYFILE $OMX_TI_INDEXTYPE{"$nParamIndex"},"  ";
			}
			else
			{
				print MYFILE $value[$i]," ";  ###print $i ne $value-1?",":".\n";
			}
		}

		print  MYFILE "\n\t\t\t\|\t\t\t\t\|";
		print  MYFILE "\n\t\t\t\|\t\t\t\t\|";
		print  MYFILE "\n\t\t\t\|\t\t\t\t\|";
			
	}


	elsif ($dir eq "nConfigIndex")#FOR EX==Prasad Log:PARAMETERS:Function RPC_SKEL_GetConfig, nConfigIndex=0x7f000019,pCompConfig=0xa0067dc8
	{
		require 'OMX_TI_INDEXTYPE.pl';
             	require 'OMX_nCONFIGINDEXTYPE.pl';   		
		my ($field,$value)=$line=~m/(.*unction)(.*)$/;
		my @value=split /,/,$value;
               	my $nConfigIndex=$value[1];
		($ignore,$nConfigIndex)=$nConfigIndex=~m/(.*=)(.*)$/;  ##debugprint $nConfigIndex,"======",$OMX_nCONFIGINDEXTYPE{$nConfigIndex},"\n";
		
		print MYFILE  "\n\t\t\t\|<------------------------------\|";
		print MYFILE "\r","\t\t\t";
		for ($i=1;$i<@value;$i++)
		{		
			if ($i eq 1)
			{
				if(exists($OMX_nCONFIGINDEXTYPE{$nConfigIndex}))
					{
						        
							print MYFILE $OMX_nCONFIGINDEXTYPE{$nConfigIndex}," ";
					}
					elsif(exists($OMX_TI_INDEXTYPE{$nConfigIndex}))
						{
							print MYFILE $OMX_TI_INDEXTYPE{$nConfigIndex}," ";
						}

			}
				
			else
			{
					print MYFILE $value[$i]," ";  ###print $i ne $value-1?",":".\n";
			}
		}
		print  MYFILE "\n\t\t\t\|\t\t\t\t\|";
		print  MYFILE "\n\t\t\t\|\t\t\t\t\|";
		print  MYFILE "\n\t\t\t\|\t\t\t\t\|";
			
	}


}


