use strict;
use warnings;

use File::Spec;
use FindBin qw($Bin);
use lib File::Spec->catdir($Bin, 'modules');

use Dancer2;

use Parsing;
use ConnectDB;

get '/get_logs/:email' => sub {
    my $email = route_parameters->get('email');
    # добавить проверку email
    my @result = Parsing::parsing($email);
    # print STDERR "Get email: $email";
    return '@result';
};

my $isConnect = ConnectDB::connectToDB();

if ($isConnect) {
    start;
}