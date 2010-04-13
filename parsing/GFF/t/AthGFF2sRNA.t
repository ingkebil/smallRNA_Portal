use Test::More 'no_plan';

my $package = 'GFF::Ath2sRNA';
use_ok($package) or exit;
can_ok($package, 'run');
can_ok($package, 'get_struct_type');
can_ok($package, 'init_gene');
can_ok($package, 'get_next_id');
can_ok($package, 'get_cur_id');
can_ok($package, 'make_SQL');
can_ok($package, 'get_features');

my @lines = <DATA>; # read from the bottom of this file, from __DATA__ on
my $ath2srna = new GFF::Ath2sRNA;
isa_ok($ath2srna, 'GFF::Ath2sRNA');

$ath2srna->run_parser(\@lines);
is_deeply($ath2srna->{ genes },
    {
    'AT1G01060.4' => {
        start => 33666,
        stop  => 37780,
        strand => q{-},
        type  => 'mRNA',
        'chr' => 'Chr1',
        seq   => q{},
        coords => [
            {
                start => 37569,
                stop  => 37780,
                type  => 'utr',
            },
            {
                start => 37373,
                stop  => 37398,
                type  => 'utr',
            },
            {
                start => 37062,
                stop  => 37203,
                type  => 'utr',
            },
            {
                start => 37023,
                stop  => 37061,
                type  => 'cds',
            },
            {
                start => 36810,
                stop  => 36921,
                type  => 'cds',
            },
            {
                start => 36624,
                stop  => 36685,
                type  => 'cds',
            },
            {
                start => 35730,
                stop  => 35963,
                type  => 'cds',
            },
            {
                start => 35567,
                stop  => 35647,
                type  => 'cds',
            },
            {
                start => 34401,
                stop  => 35471,
                type  => 'cds',
            },
            {
                start => 33992,
                stop  => 34327,
                type  => 'cds',
            },
            {
                start => 33666,
                stop  => 33991,
                type  => 'utr',
            },
        ]
    },
    'AT1G03420.1' => {
        start => 846664,
        stop  => 847739,
        strand => q{+},
        type => 'mRNA_TE_gene',
        seq  => q{},
        'chr' => 'Chr1',
        coords => [
            {
                start => 846664,
                stop  => 847739,
                type  => q{},
            }
        ],
    },
    'AT1G02136.1' => {
        start => 402693,
        stop  => 402961,
        strand => q{-},
        type => 'pseudogenic_transcript',
        seq => q{},
        'chr' => 'Chr1',
        coords => [
            {
                start => 402886,
                stop  => 402961,
                type  => q{},
            },
            {
                start => 402693,
                stop  => 402808,
                type  => q{},
            }
        ]
    },
    'AT1G08115.1' => {
        start => 2538076,
        stop  => 2538237,
        strand => q{-},
        type => 'snRNA',
        seq => q{},
        'chr' => 'Chr1',
        coords => [
            {
                start => 2538076,
                stop  => 2538237,
                type  => q{},
            }
        ]
    },
    'AT2G01010.1' => {
        start => 3706,
        stop  => 5513,
        strand => q{+},
        type => 'rRNA',
        seq => q{},
        'chr' => 'Chr2',
        coords => [
            {
                start => 3706,
                stop  => 5513,
                type  => q{},
            }
        ]
    },
    'AT2G04852.1' => {
        start => 1705148,
        stop  => 1706465,
        strand => q{-},
        type => 'ncRNA',
        seq => q{},
        'chr' => 'Chr2',
        coords => [
            {
                start => 1706420,
                stop  => 1706465,
                type  => q{},
            },
            {
                start => 1705716,
                stop  => 1705798,
                type  => q{},
            },
            {
                start => 1705148,
                stop  => 1705618,
                type  => q{},
            },
        ]
    },
    'AT2G07742.1' => {
        start => 3239657,
        stop  => 3239728,
        strand => q{-},
        type  => 'tRNA',
        seq   => q{},
        'chr' => 'Chr2',
        coords => [
            {
                start => 3239657,
                stop  => 3239728,
                type  => q{},
            }
        ]
    },
    'AT2G17295.1' => {
        start => 7520942,
        stop => 7521021,
        strand => q{+},
        type => 'snoRNA',
        seq => q{},
        'chr' => 'Chr2',
        coords => [
            {
                start => 7520942,
                stop => 7521021,
                type => q{},
            }
        ]
    },
    'AT2G19425.1' => {
        start => 8412516,
        stop => 8412618,
        strand => q{-},
        type => 'miRNA',
        'chr' => 'Chr2',
        seq => q{},
        coords => [
            {
                start => 8412516,
                stop  => 8412618,
                type  => q{},
            }
        ]
    },
    'AT3TE67050' => {
        start => 16540351,
        stop => 16541285,
        strand => q{+},
        type => 'transposable_element',
        'chr' => 'Chr3',
        seq => q{},
        coords => [
            {
                start => 16540351,
                stop  => 16541285,
                type  => q{},
            }
        ]
    },
});

# to test if the output is correct, I simply c/p what the script outputs in here everytime I make a change to the belowmentioned GFF
my @sql = (
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`, species_id, seq, comment, source_id)
VALUES (1, 'AT2G19425', '1', '8412516', '8412618', '-', 'Chr2', 'miRNA', '1', NULL, NULL, '1');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 1, 8412516, 8412618, 'Y');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`, species_id, seq, comment, source_id)
VALUES (2, 'AT2G17295', '1', '7520942', '7521021', '+', 'Chr2', 'snoRNA', '1', NULL, NULL, '1');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 2, 7520942, 7521021, 'Y');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`, species_id, seq, comment, source_id)
VALUES (3, 'AT2G01010', '1', '3706', '5513', '+', 'Chr2', 'rRNA', '1', NULL, NULL, '1');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 3, 3706, 5513, 'Y');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`, species_id, seq, comment, source_id)
VALUES (4, 'AT1G03420', '1', '846664', '847739', '+', 'Chr1', 'mRNA_TE_gene', '1', NULL, NULL, '1');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 4, 846664, 847739, 'Y');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`, species_id, seq, comment, source_id)
VALUES (5, 'AT1G02136', '1', '402693', '402961', '-', 'Chr1', 'pseudogenic_transcript', '1', NULL, NULL, '1');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 5, 402886, 402961, 'Y');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 5, 402693, 402808, 'Y');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`, species_id, seq, comment, source_id)
VALUES (6, 'AT2G07742', '1', '3239657', '3239728', '-', 'Chr2', 'tRNA', '1', NULL, NULL, '1');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 6, 3239657, 3239728, 'Y');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`, species_id, seq, comment, source_id)
VALUES (7, 'AT1G08115', '1', '2538076', '2538237', '-', 'Chr1', 'snRNA', '1', NULL, NULL, '1');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 7, 2538076, 2538237, 'Y');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`, species_id, seq, comment, source_id)
VALUES (8, 'AT3TE67050', '1', '16540351', '16541285', '+', 'Chr3', 'transposable_element', '1', NULL, NULL, '1');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 8, 16540351, 16541285, 'Y');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`, species_id, seq, comment, source_id)
VALUES (9, 'AT2G04852', '1', '1705148', '1706465', '-', 'Chr2', 'ncRNA', '1', NULL, NULL, '1');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 9, 1706420, 1706465, 'Y');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 9, 1705716, 1705798, 'Y');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 9, 1705148, 1705618, 'Y');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`, species_id, seq, comment, source_id)
VALUES (10, 'AT1G01060', '4', '33666', '37780', '-', 'Chr1', 'mRNA', '1', NULL, NULL, '1');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 10, 37569, 37780, 'Y');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 10, 37373, 37398, 'Y');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 10, 37062, 37203, 'Y');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 10, 37023, 37061, 'N');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 10, 36810, 36921, 'N');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 10, 36624, 36685, 'N');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 10, 35730, 35963, 'N');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 10, 35567, 35647, 'N');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 10, 34401, 35471, 'N');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 10, 33992, 34327, 'N');
",
"INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (NULL, 10, 33666, 33991, 'Y');
",
);

# test the SQL format
# run the make_SQL with source_id 1 and species_id 1
my @made_sql = @{ $ath2srna->make_SQL(1, 1) };
my @sort_ath_sql = sort { $a cmp $b } grep { /INSERT/ } @made_sql;
my @sort_sql     = sort { $a cmp $b } @sql;

is_deeply(
    \@sort_ath_sql,
    \@sort_sql
);

# test if we make the correct ALTER TABLE
# (Well, kind of, as we should only get this alter table when a type is added.)
my @alter_table = grep { /ALTER TABLE/ } @made_sql;
if (@alter_table) {
    is(@alter_table[0], q{ALTER TABLE annotations MODIFY type enum('transposable_element','mRNA_TE_gene','mRNA','snRNA','rRNA','snoRNA','miRNA','pseudogenic_transcript','tRNA','ncRNA');
});
}

# now test the CSV format
$ath2srna->run_parser(\@lines);
my $results = $ath2srna->make_CSV(1, 1);
my @annotations = (
    "1	'AT2G19425'	'1'	'8412516'	'8412618'	'-'	'Chr2'	'miRNA'	'1'	NULL	NULL	'1'",
    "2	'AT2G17295'	'1'	'7520942'	'7521021'	'+'	'Chr2'	'snoRNA'	'1'	NULL	NULL	'1'",
    "3	'AT2G01010'	'1'	'3706'	'5513'	'+'	'Chr2'	'rRNA'	'1'	NULL	NULL	'1'",
    "4	'AT1G03420'	'1'	'846664'	'847739'	'+'	'Chr1'	'mRNA_TE_gene'	'1'	NULL	NULL	'1'",
    "5	'AT1G02136'	'1'	'402693'	'402961'	'-'	'Chr1'	'pseudogenic_transcript'	'1'	NULL	NULL	'1'",
    "6	'AT2G07742'	'1'	'3239657'	'3239728'	'-'	'Chr2'	'tRNA'	'1'	NULL	NULL	'1'",
    "7	'AT1G08115'	'1'	'2538076'	'2538237'	'-'	'Chr1'	'snRNA'	'1'	NULL	NULL	'1'",
    "8	'AT3TE67050'	'1'	'16540351'	'16541285'	'+'	'Chr3'	'transposable_element'	'1'	NULL	NULL	'1'",
    "9	'AT2G04852'	'1'	'1705148'	'1706465'	'-'	'Chr2'	'ncRNA'	'1'	NULL	NULL	'1'",
    "10	'AT1G01060'	'4'	'33666'	'37780'	'-'	'Chr1'	'mRNA'	'1'	NULL	NULL	'1'",
);
my @structures = (
    "NULL	1	8412516	8412618	'Y'",
    "NULL	2	7520942	7521021	'Y'",
    "NULL	3	3706	5513	'Y'",
    "NULL	4	846664	847739	'Y'",
    "NULL	5	402886	402961	'Y'",
    "NULL	5	402693	402808	'Y'",
    "NULL	6	3239657	3239728	'Y'",
    "NULL	7	2538076	2538237	'Y'",
    "NULL	8	16540351	16541285	'Y'",
    "NULL	9	1706420	1706465	'Y'",
    "NULL	9	1705716	1705798	'Y'",
    "NULL	9	1705148	1705618	'Y'",
    "NULL	10	37569	37780	'Y'",
    "NULL	10	37373	37398	'Y'",
    "NULL	10	37062	37203	'Y'",
    "NULL	10	37023	37061	'N'",
    "NULL	10	36810	36921	'N'",
    "NULL	10	36624	36685	'N'",
    "NULL	10	35730	35963	'N'",
    "NULL	10	35567	35647	'N'",
    "NULL	10	34401	35471	'N'",
    "NULL	10	33992	34327	'N'",
    "NULL	10	33666	33991	'Y'",
);

is_deeply($results, { annotations => \@annotations, structures => \@structures, sql => \@alter_table });

__DATA__

Chr1	TAIR9	mRNA	33666	37780	.	-	.	ID=AT1G01060.4;Parent=AT1G01060;Name=AT1G01060.4;Index=1
Chr1	TAIR9	protein	33992	37061	.	-	.	ID=AT1G01060.4-Protein;Name=AT1G01060.4;Derives_from=AT1G01060.4
Chr1	TAIR9	five_prime_UTR	37569	37780	.	-	.	Parent=AT1G01060.4
Chr1	TAIR9	exon	37569	37780	.	-	.	Parent=AT1G01060.4
Chr1	TAIR9	five_prime_UTR	37373	37398	.	-	.	Parent=AT1G01060.4
Chr1	TAIR9	exon	37373	37398	.	-	.	Parent=AT1G01060.4
Chr1	TAIR9	five_prime_UTR	37062	37203	.	-	.	Parent=AT1G01060.4
Chr1	TAIR9	CDS	37023	37061	.	-	0	Parent=AT1G01060.4,AT1G01060.4-Protein;
Chr1	TAIR9	exon	37023	37203	.	-	.	Parent=AT1G01060.4
Chr1	TAIR9	CDS	36810	36921	.	-	0	Parent=AT1G01060.4,AT1G01060.4-Protein;
Chr1	TAIR9	exon	36810	36921	.	-	.	Parent=AT1G01060.4
Chr1	TAIR9	CDS	36624	36685	.	-	2	Parent=AT1G01060.4,AT1G01060.4-Protein;
Chr1	TAIR9	exon	36624	36685	.	-	.	Parent=AT1G01060.4
Chr1	TAIR9	CDS	35730	35963	.	-	0	Parent=AT1G01060.4,AT1G01060.4-Protein;
Chr1	TAIR9	exon	35730	35963	.	-	.	Parent=AT1G01060.4
Chr1	TAIR9	CDS	35567	35647	.	-	0	Parent=AT1G01060.4,AT1G01060.4-Protein;
Chr1	TAIR9	exon	35567	35647	.	-	.	Parent=AT1G01060.4
Chr1	TAIR9	CDS	34401	35471	.	-	0	Parent=AT1G01060.4,AT1G01060.4-Protein;
Chr1	TAIR9	exon	34401	35471	.	-	.	Parent=AT1G01060.4
Chr1	TAIR9	CDS	33992	34327	.	-	0	Parent=AT1G01060.4,AT1G01060.4-Protein;
Chr1	TAIR9	three_prime_UTR	33666	33991	.	-	.	Parent=AT1G01060.4
Chr1	TAIR9	exon	33666	34327	.	-	.	Parent=AT1G01060.4

Chr1	TAIR9	transposable_element_gene	846664	847739	.	+	.	ID=AT1G03420;Note=transposable_element_gene;Name=AT1G03420;Derives_from=AT1TE02770
Chr1	TAIR9	mRNA_TE_gene	846664	847739	.	+	.	ID=AT1G03420.1;Parent=AT1G03420;Name=AT1G03420.1;Index=1
Chr1	TAIR9	exon	846664	847739	.	+	.	Parent=AT1G03420.1

Chr1	TAIR9	pseudogene	402693	402961	.	-	.	ID=AT1G02136;Note=pseudogene;Name=AT1G02136
Chr1	TAIR9	pseudogenic_transcript	402693	402961	.	-	.	ID=AT1G02136.1;Parent=AT1G02136;Name=AT1G02136.1;Index=1
Chr1	TAIR9	pseudogenic_exon	402886	402961	.	-	.	Parent=AT1G02136.1
Chr1	TAIR9	pseudogenic_exon	402693	402808	.	-	.	Parent=AT1G02136.1

Chr1	TAIR9	gene	2538076	2538237	.	-	.	ID=AT1G08115;Note=snRNA;Name=AT1G08115
Chr1	TAIR9	snRNA	2538076	2538237	.	-	.	ID=AT1G08115.1;Parent=AT1G08115;Name=AT1G08115.1;Index=1
Chr1	TAIR9	exon	2538076	2538237	.	-	.	Parent=AT1G08115.1

Chr2	TAIR9	gene	3706	5513	.	+	.	ID=AT2G01010;Note=rRNA;Name=AT2G01010
Chr2	TAIR9	rRNA	3706	5513	.	+	.	ID=AT2G01010.1;Parent=AT2G01010;Name=AT2G01010.1;Index=1
Chr2	TAIR9	exon	3706	5513	.	+	.	Parent=AT2G01010.1

Chr2	TAIR9	gene	1705148	1706465	.	-	.	ID=AT2G04852;Note=other_RNA;Name=AT2G04852
Chr2	TAIR9	ncRNA	1705148	1706465	.	-	.	ID=AT2G04852.1;Parent=AT2G04852;Name=AT2G04852.1;Index=1
Chr2	TAIR9	exon	1706420	1706465	.	-	.	Parent=AT2G04852.1
Chr2	TAIR9	exon	1705716	1705798	.	-	.	Parent=AT2G04852.1
Chr2	TAIR9	exon	1705148	1705618	.	-	.	Parent=AT2G04852.1

Chr2	TAIR9	gene	3239657	3239728	.	-	.	ID=AT2G07742;Note=tRNA;Name=AT2G07742
Chr2	TAIR9	tRNA	3239657	3239728	.	-	.	ID=AT2G07742.1;Parent=AT2G07742;Name=AT2G07742.1;Index=1
Chr2	TAIR9	exon	3239657	3239728	.	-	.	Parent=AT2G07742.1

Chr2	TAIR9	gene	7520942	7521021	.	+	.	ID=AT2G17295;Note=snoRNA;Name=AT2G17295
Chr2	TAIR9	snoRNA	7520942	7521021	.	+	.	ID=AT2G17295.1;Parent=AT2G17295;Name=AT2G17295.1;Index=1
Chr2	TAIR9	exon	7520942	7521021	.	+	.	Parent=AT2G17295.1

Chr2	TAIR9	gene	8412516	8412618	.	-	.	ID=AT2G19425;Note=miRNA;Name=AT2G19425
Chr2	TAIR9	miRNA	8412516	8412618	.	-	.	ID=AT2G19425.1;Parent=AT2G19425;Name=AT2G19425.1;Index=1
Chr2	TAIR9	exon	8412516	8412618	.	-	.	Parent=AT2G19425.1

Chr3	TAIR9	transposable_element	16540351	16541285	.	+	.	ID=AT3TE67050;Name=AT3TE67050;Alias=ATREP4
Chr3	TAIR9	transposon_fragment	16540351	16541285	.	+	.	Parent=AT3TE67050

