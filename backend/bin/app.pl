use strict;
use warnings;

use File::Spec;
use FindBin qw($Bin);
use lib File::Spec->catdir($Bin, '../lib');

use Dancer2;
use Dotenv;
Dotenv->load;

use Parser;
use DBInterface;

my $db = $ENV{db};
my $dbname = $ENV{dbname};
my $dbhost = $ENV{dbhost};
my $dbport = $ENV{dbport};
my $dbusername = $ENV{dbusername};
my $dbpassword = $ENV{dbpassword};

my $dbh = DBI->connect(
    "DBI:$db:database=$dbname;host=$dbhost;port=$dbport", 
    $dbusername, 
    $dbpassword
) or die "Не удалось подключиться к базе данных: $DBI::errstr";

get '/get_logs/:email' => sub {
    response_header 'Access-Control-Allow-Origin' => '*';
    response_header 'Access-Control-Allow-Methods' => 'GET';
    response_header 'Access-Control-Allow-Headers' => 'Content-Type, Accept';
    response_header 'Content-Type' => 'application/json';

    my $email = route_parameters->get('email');
    unless ($email) {
        return to_json({ error => "Адрес не может быть пустым" });
    }

    my $resValues = DBInterface::getValues($dbh, $email);

    unless ($resValues) {
        return to_json({ error => "Произошла ошибка получения данных" });
    }

    my $totalCount = @$resValues;
    if ($totalCount > 100) {
        splice(@$resValues, 100);
    }

    my $response = {
        data => $resValues,
        count => $totalCount,
        error => undef
    };
    my $encodeRes = to_json($response);

    return $encodeRes;
};

DBInterface::createTables($dbh);
my ($message, $log) = Parser::parseLogFile();
my $isReadyDB = DBInterface::insertValues($dbh, $message, $log);

if ($isReadyDB) {
    start;
}

1;