
AnnoJ.config = {
tracks : [
    {
       id   : 'models',
       name : 'Gene Models',
       type : 'ModelsTrack',
       path : 'Annotation models',

       //Pointing to a local service
       data : '../annoj/genemodels/arath',
       height : 250,
       showControls : true
    },
    {
       id   : 'srna',
       name : 'Small RNA',
       type : 'ModelsTrack',
       path : 'Srna models',

       //Pointing to a local service
       data : '../annoj/rnamodels/arath',
       height : 150,
       showControls : true
    },
],

//A list of tracks that will be active by default (use the ID of the track)
//active : ['models',,'WGTA','ESTs'],
active : ['models'],

//Address of service that provides information about this genome
genome : '../annoj/annoj_species/arath',

//Address of service that stores / loads user bookmarks
//	bookmarks : 'http://psbdev01.psb.ugent.be/sites/liste_sandbox/syndicate.php',

//A list of stylesheets that a user can select between (optional)
stylesheets : [
    ],

//The default 'view'. In this example, chr1, position 1, zoom ratio 20:1.
location : {
assembly : 'Chr1',
           position : 1,
           bases    : 10,
           pixels   : 1
         },

         //Site administrator contact details (optional)
admin : {
name  : 'Kenny Billiau',
        email : 'billiau@mpimp-golm.mpg.de',
        notes : 'Potsdam, Europe, Belgium'
        }
};
