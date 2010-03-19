use Test::More 'no_plan';

my $package = 'GFF::Ath2sRNA';
use_ok($package) or exit;
can_ok($package, 'run');
can_ok($package, 'get_struct_type');
can_ok($package, 'init_gene');
can_ok($package, 'get_next_id');
can_ok($package, 'get_cur_id');
can_ok($package, 'make_SQL');

my @lines = <DATA>;
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
});

my @sql = (
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`)
VALUES (1 'AT2G19425', '1', '8412516', '8412618', '-', 'Chr2', 'miRNA');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (1, 8412516, 8412618, 'Y');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`)
VALUES (2 'AT2G17295', '1', '7520942', '7521021', '+', 'Chr2', 'snoRNA');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (2, 7520942, 7521021, 'Y');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`)
VALUES (3 'AT2G01010', '1', '3706', '5513', '+', 'Chr2', 'rRNA');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (3, 3706, 5513, 'Y');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`)
VALUES (4 'AT1G03420', '1', '846664', '847739', '+', 'Chr1', 'mRNA_TE_gene');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (4, 846664, 847739, \'Y\');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`)
VALUES (5 'AT1G02136', '1', '402693', '402961', '-', 'Chr1', 'pseudogenic_transcript');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (5, 402886, 402961, 'Y');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (5, 402693, 402808, 'Y');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`)
VALUES (6 'AT2G07742', '1', '3239657', '3239728', '-', 'Chr2', 'tRNA');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (6, 3239657, 3239728, 'Y');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`)
VALUES (7 'AT1G08115', '1', '2538076', '2538237', '-', 'Chr1', 'snRNA');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (7, 2538076, 2538237, 'Y');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`)
VALUES (8 'AT2G04852', '1', '1705148', '1706465', '-', 'Chr2', 'ncRNA');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (8, 1706420, 1706465, 'Y');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (8, 1705716, 1705798, 'Y');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (8, 1705148, 1705618, 'Y');
",
"INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`)
VALUES (9 'AT1G01060', '4', '33666', '37780', '-', 'Chr1', 'mRNA');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (9, 37569, 37780, 'Y');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (9, 37373, 37398, 'Y');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (9, 37062, 37203, 'Y');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (9, 37023, 37061, 'N');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (9, 36810, 36921, 'N');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (9, 36624, 36685, 'N');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (9, 35730, 35963, 'N');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (9, 35567, 35647, 'N');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (9, 34401, 35471, 'N');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (9, 33992, 34327, 'N');
",
"INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES (9, 33666, 33991, 'Y');
");

my @sort_ath_sql = sort { $a cmp $b } @{ $ath2srna->make_SQL };
my @sort_sql     = sort { $a cmp $b } @sql;

is_deeply(
    \@sort_ath_sql,
    \@sort_sql
);


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

