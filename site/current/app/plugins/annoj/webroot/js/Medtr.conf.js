
//The Anno-J configuration object
AnnoJ.config = {

    //List of configurations for all tracks in the Anno-J instance
tracks : [

             //Example config for a ModelsTrack
         {
id   : 'models',
       name : 'Gene Models',
       type : 'ModelsTrack',
       path : 'Annotation models',

       //Pointing to a local service
       data : '../annoj/genemodel/Medtr',
       //data : 'http://bioinformatics.psb.ugent.be/testix/boganaceae/annoj/genemodel/deligate/Solly',
		 height : 100,
       showControls : true
         },
			{
id   : 'RNAmodels',
       name : 'RNA Models',
       type : 'ModelsTrack',
       path : 'Annotation models',

       //Pointing to a local service
       data : '../annoj/rnamodel/Medtr',
		 height : 100,
       showControls : true
         },
         {
id   : 'repeats',
       name : 'Repeats',
       type : 'MaskTrack',
       path : 'Annotation models',
       data : '../annoj/repeats/Medtr',
       //data : 'http://bioinformatics.psb.ugent.be/testix/boganaceae/annoj/repeats/deligate/Solly',
       minHeight : 20,
       maxHeight : 40,
       height : 20,
       single : true
         },
         {
id   : 'ESTs',
       name : 'Transcript sequences',
       type : 'ModelsTrack',
       path : 'Messenger RNA',
       data : '../annoj/ests/Medtr/type:EST',

       height : 100,
       single : false,
       showControls : false,
		 showArrows : false
         },
         {
id   : 'Reads',
       name : 'Deep Transcript sequences',
       type : 'ModelsTrack',
       path : 'Messenger RNA',
       data : '../annoj/ests/Medtr/type:READ',

       height : 60,
       single : false,
       showControls : false,
		 showArrows : false,
		 showLabels: false
         },
        /* {
id   : 'markers',
		name : 'Genetic Markers',
		type : 'ModelsTrack',
		path : 'Markers',
		data : '../annoj/markers/Solly',
		height : 30,
		single : true,
		showArrows : false,
		}, */
         ],

         //A list of tracks that will be active by default (use the ID of the track)
         //active : ['models',,'WGTA','ESTs'],
         active : ['models','ESTs','Reads','repeats'],

         //Address of service that provides information about this genome
         //genome : 'http://bioinformatics.psb.ugent.be/testix/boganaceae/annoj/genemodel/deligate/Solly?action=syndicate',
         genome : '../annoj/species/Medtr',
			//genome    : 'http://psbdev01.psb.ugent.be/sites/liste_sandbox/syndicate.php',		

         //Address of service that stores / loads user bookmarks
         //	bookmarks : 'http://psbdev01.psb.ugent.be/sites/liste_sandbox/syndicate.php',

         //A list of stylesheets that a user can select between (optional)
         stylesheets : [
             ],

         //The default 'view'. In this example, chr1, position 1, zoom ratio 20:1.
         location : {
           assembly : 'MtChr05',
           position : 12924000,
           bases    : 20,
           pixels   : 1
         },

         //Site administrator contact details (optional)
admin : {
name  : 'Kenny Billiau',
        email : 'kenny.billiau@psb.ugent.be',
        notes : 'Gent, Europe, Belgium'
        }
};

