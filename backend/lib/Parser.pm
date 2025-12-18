package Parser;

use strict;
use warnings;

use DateTime::Format::Strptime;
use DBInterface;

sub parseLogFile {
    open my $logFile, '<', '../data/out' or die "Ошибка чтения файла: $!\n";

    my @logs = <$logFile>;

    close $logFile or die "Ошибка закрытия файла: $!\n";

    my @message = ();
    my @log = ();
    my $format = DateTime::Format::Strptime->new(
        pattern   => '%Y-%m-%d %H:%M:%S',
        time_zone => 'local',
    );
    my $strIndex = 1;
    foreach my $str (@logs) {
        chomp($str);
        my @splitStr = split(/\s+/, $str);

        my %strHash = ();

        my $int_id = $splitStr[2];
        $strHash{'int_id'} = $int_id;

        my $strDateTime = "$splitStr[0] $splitStr[1]";
        my $parsedDate = $format->parse_datetime($strDateTime);

        $strHash{'created'} = $parsedDate;

        my $flag = $splitStr[3];

        my @otherInfo = splice(@splitStr, 2, @splitStr - 1);
        $strHash{'str'} = join(' ', @otherInfo);

        if ($flag eq '<=') {
            if ($str =~ /id=(.+)/) {
                $strHash{'id'} = $1;
            } else {
                $strHash{'id'} = $strIndex;
            }

            push(@message, \%strHash);
        } else {
            if ($str =~ /(=>|->|\*\*|==) (([\w\.-]+)@([\w\.-]+\.[a-z]{2,6}))/) {
                $strHash{'address'} = $2;
            } else {
                $strHash{'address'} = '';
            }

            push(@log, \%strHash);
        }

        $strIndex = $strIndex + 1;
    }

    return (\@message, \@log);
}

1;