package ConnectDB;

use strict;
use warnings;

use DBI;

use Dotenv;
Dotenv->load;

sub connectToDB {
    my $db = $ENV{db};
    my $dbname = $ENV{dbname};
    my $dbhost = $ENV{dbhost};
    my $dbport = $ENV{dbport};
    my $dbusername = $ENV{dbusername};
    my $dbpassword = $ENV{dbpassword};

    my $dbh = DBI->connect(
        "DBI:$db:database=$dbname;host=$dbhost;port=$dbport", 
        $dbusername, 
        $dbpassword,
        { RaiseError => 1, AutoCommit => 1 }
    ) or die "Не удалось подключиться к базе данных: $DBI::errstr";

    if (!$@) {
        print STDERR "connect to DB successfully\n";
        return 1;
    }
    return 0;
}