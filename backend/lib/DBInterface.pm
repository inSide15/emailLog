package DBInterface;

use strict;
use warnings;

use DBI;

sub createTables {
    my ($dbh) = @_;

    $dbh->do('DROP TABLE IF EXISTS message') or die $dbh->errstr;

    $dbh->do(q{
        CREATE TABLE message (
            created TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
            id VARCHAR NOT NULL,
            int_id CHAR(16) NOT NULL,
            str VARCHAR NOT NULL,
            status BOOL,
            CONSTRAINT message_id_pk PRIMARY KEY(id)
        )
    }) or die $dbh->errstr;

    $dbh->do('CREATE INDEX message_created_idx ON message (created)') or die $dbh->errstr;
    $dbh->do('CREATE INDEX message_int_id_idx ON message (int_id)') or die $dbh->errstr;

    $dbh->do('DROP TABLE IF EXISTS log') or die $dbh->errstr;

    $dbh->do(q{
        CREATE TABLE log (
            created timestamp(0) WITHOUT TIME ZONE NOT NULL,
            int_id char(16) NOT NULL,
            address VARCHAR,
            str VARCHAR
        )
    }) or die $dbh->errstr;

    $dbh->do('CREATE INDEX log_address_idx ON log USING hash (address)') or die $dbh->errstr;

    return 1;
}

sub insertValues {
    my ($dbh, $messageRef, $logRef) = @_;

    $dbh->begin_work;
    eval {
        my $sthMessage = $dbh->prepare('INSERT INTO message (created, id, int_id, str) VALUES (?, ?, ?, ?)');
        foreach my $row (@{$messageRef}) {
            my $created = $row->{created};
            my $id = $row->{id};
            my $int_id = $row->{int_id};
            my $str = $row->{str};

            $sthMessage->execute($created, $id, $int_id, $str);
        }

        my $sthLog = $dbh->prepare('INSERT INTO log (created, int_id, address, str) VALUES (?, ?, ?, ?)');
        foreach my $row (@{$logRef}) {
            my $created = $row->{created};
            my $int_id = $row->{int_id};
            my $str = $row->{str};
            my $address = $row->{address};

            $sthLog->execute($created, $int_id, $address, $str);
        }

        $dbh->commit;
    };


    if ($@) {
        print STDERR "Ошибка транзакции: $@\n";
        $dbh->rollback or die "Не удалось откатить транзакцию: $DBI::errstr";
        return 0;
    }

    return 1;
}

sub getValues {
    my ($dbh, $email) = @_;

    my $sthLog = $dbh->prepare(q{
        SELECT created, str, int_id FROM log WHERE address LIKE ?
        UNION ALL
        SELECT m.created, m.str, m.int_id FROM message m WHERE m.int_id IN (
            SELECT DISTINCT int_id
            FROM log
            WHERE address LIKE ?
        )
        ORDER BY int_id, created
    }) or die $dbh->errstr;

    my $likeParam = "%$email%";
    $sthLog->execute($likeParam, $likeParam);

    my $result = $sthLog->fetchall_arrayref({});

    $sthLog->finish;

    return $result;
}

1;