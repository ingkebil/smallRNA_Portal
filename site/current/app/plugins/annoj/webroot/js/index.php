<?php

# this file will be called as soon as the javascript is not found. Then we 
# generate a default script.

$genome = $_GET['url']; # e.g. trpee.conf.js

# remove the last parts
$genome = array_shift(explode('.', $genome));

echo "

//The Anno-J configuration object
AnnoJ.config = {

    //List of configurations for all tracks in the Anno-J instance
tracks : [ {
    id   : 'models',
    name : 'Gene Models',
    type : 'ModelsTrack',
    path : 'Annotation models',
    data : '/BOGAS/branches/V2/annoj/deligate/$genome',
    height : 100,
    showControls : true
}, ],

    //A list of tracks that will be active by default (use the ID of the track)
    active : ['models'],

    //Address of service that provides information about this genome
    genome : 'http://bioinformatics.psb.ugent.be/webtools/boganaceae/annoj/deligate/$genome?action=syndicate',

    //A list of stylesheets that a user can select between (optional)
    stylesheets : [
    ],

    //The default 'view'. In this example, chr1, position 1, zoom ratio 20:1.
    range : {
        assembly : 'sctg_0',
        position : 1,
        bases    : 20,
        pixels   : 1
    },

    //Site administrator contact details (optional)
    admin : {
        name  : 'Kenny Billiau',
        email : 'billiau@mpimp-golm.mpg.de',
        notes : 'Potsdam, Europe, Belgium'
     }
};"

?>
