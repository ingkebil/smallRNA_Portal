
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
       data : '../annoj/genemodel/Tetur',
       //data : 'http://bioinformatics.psb.ugent.be/testix/boganaceae/annoj/genemodel/deligate/Ectsi',
		 height : 100,
       showControls : true
         },
			{
id   : 'RNAmodels',
       name : 'RNA Models',
       type : 'ModelsTrack',
       path : 'Annotation models',

       //Pointing to a local service
       data : '../annoj/rnamodel/Tetur',
		 height : 100,
       showControls : true
         },
         {
id   : 'repeats',
       name : 'Repeats',
       type : 'MaskTrack',
       path : 'Annotation models',
       data : '../annoj/repeats/Tetur',
       //data : 'http://bioinformatics.psb.ugent.be/testix/boganaceae/annoj/repeats/deligate/Ectsi',
       minHeight : 20,
       maxHeight : 40,
       height : 20,
       single : true
         },
         {
id   : 'ESTs1',
       name : 'Transcript sequences',
       type : 'ModelsTrack',
       path : 'Messenger RNA',
       data : '../annoj/ests/Tetur/type:EST',

       height : 100,
       single : false,
       showControls : false,
		 showArrows : false
         },
         {
id   : 'ESTs2',
       name : 'Deep Transcript sequences',
       type : 'ModelsTrack',
       path : 'Messenger RNA',
       data : '../annoj/ests/Tetur/type:READ',

       height : 100,
       single : false,
       showControls : false,
		 showArrows : false,
		 showLabels: false
         },
			{
id   : 'illumina',
		name : 'deep seq RNAs',
		type : 'ReadsTrack',
		path : 'RNA reads',
		data : '../annoj/smrna/Tetur',
	   height : 60,
		single : false
			},

         ],

         //A list of tracks that will be active by default (use the ID of the track)
         //active : ['models',,'WGTA','ESTs'],
         active : ['models','ESTs1','ESTs2','repeats'],

         //Address of service that provides information about this genome
         //genome : 'http://bioinformatics.psb.ugent.be/testix/boganaceae/annoj/genemodel/deligate/Ectsi?action=syndicate',
         genome : '../annoj/species/Tetur',
			//genome    : 'http://psbdev01.psb.ugent.be/sites/liste_sandbox/syndicate.php',		

         //Address of service that stores / loads user bookmarks
         //	bookmarks : 'http://psbdev01.psb.ugent.be/sites/liste_sandbox/syndicate.php',

         //A list of stylesheets that a user can select between (optional)
         stylesheets : [
             ],

         //The default 'view'. In this example, chr1, position 1, zoom ratio 20:1.
         location : {
           assembly : 'sctg_0',
           position : 1,
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

