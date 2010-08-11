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
       data : '../annoj/genemodel/Trpee',
		 height : 100,
       showControls : true
         },
			{
id   : 'RNAmodels',
       name : 'RNA Models',
       type : 'ModelsTrack',
       path : 'Annotation models',

       //Pointing to a local service
       data : '../annoj/rnamodel/Trpee',
		 height : 100,
       showControls : true
         },
         {
id   : 'repeats',
       name : 'Repeats',
       type : 'MaskTrack',
       path : 'Annotation models',
       data : '../annoj/repeats/Trpee',
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
       data : '../annoj/ests/Trpee',

       height : 100,
       single : false,
       showControls : false,
		 showArrows : false
         },
			{
id   : 'WGTA',
       name : 'tiling array',		
       type : 'MicroarrayTrack',
       path : 'Messenger RNA',
       data : '../annoj/tiling/Trpee',
       minHeight : 60,
       maxHeight : 160,
       height : 100,
         },
         {
id   : 'smRNA_gameto',
		name : 'deep seq small RNAs (gametophyte)',
		type : 'ReadsTrack',
		path : 'Small RNA',
		data : '../annoj/smrna/Trpee/type:gameto',
	   height : 60,
		single : false
		},
      {
id   : 'smRNA_sporo',
		name : 'deep seq small RNAs (sporophyte)',
		type : 'ReadsTrack',
		path : 'Small RNA',
		data : '../annoj/smrna/Trpee/type:sporo',
	   height : 60,
		single : false
		},
         ],

         //A list of tracks that will be active by default (use the ID of the track)
         //active : ['models',,'WGTA','ESTs'],
         active : ['models','ESTs','repeats','WGTA','smRNA_gameto'],

         //Address of service that provides information about this genome
         genome : '../annoj/species/Trpee',
         
         //Address of service that stores / loads user bookmarks
         //	bookmarks : 'http://psbdev01.psb.ugent.be/sites/liste_sandbox/syndicate.php',

         //A list of stylesheets that a user can select between (optional)
         stylesheets : [
			              
             ],

         //The default 'view'. In this example, chr1, position 1, zoom ratio 20:1.
         location : {
           assembly : 'sctg_3',
           position : 500,
			  bases    : 10,
           pixels   : 1,
			  
         },
			

         //Site administrator contact details (optional)
admin : {
name  : 'Kenny Billiau',
        email : 'kenny.billiau@psb.ugent.be',
        notes : 'Gent, Europe, Belgium'
        }
};
