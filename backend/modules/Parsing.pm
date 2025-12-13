package Parsing;

use strict;
use warnings;

sub parsing {
    my $email = @_;

    open my $logFile, '<', './out' or die "Ошибка чтения файла: $!\n";

    my @logs = <$logFile>;

    close $logFile or die "Ошибка закрытия файла: $!\n";

    foreach my $str (@logs) {
        #check each str;
    }

    return @logs;
}

1;