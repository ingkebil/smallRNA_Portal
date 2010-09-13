var paper; // our canvas

function genestruct(div, coords, start, stop) {
    var box_width = document.getElementById(div).clientWidth - 20;
    if (paper==undefined) {
        paper = Raphael(div, box_width, $(div).height());
    }
    paper.setSize(box_width, $(div).height());
    paper.clear();
    var coords = coords.split(';');

    var h_utr = 15;
    var h_cds = 20;
    var f = box_width / (stop - start);
    var line = paper.path('M0 '+(h_cds/2)+'L'+(box_width)+' '+(h_cds/2)).attr({stroke: 'grey'});
    var boxes = new Array();
    for(i in coords) {
        var st = coords[i].split(/Y|N/);
        var color = '#f88';
        var h = h_cds;
        var y1 = 1;
        if (coords[i].match(/Y/)) {
            color = '#88f';
            h = h_utr;
            y1 = h/2 - (h_cds - h_utr) + 1;
        }

        var x1 = (st[0] - start) * f;
        var x2 = (st[1] - start) * f;

        boxes[i] = paper.rect(x1, y1, x2-x1, h);
        boxes[i].attr({ fill: color });
    }
}

function srnastruct(div, coords, start, stop) {
    var box_width = document.getElementById(div).clientWidth - 20;
    var f = box_width / (stop - start);

    paper.setSize(box_width, $(div).height());
    paper.clear();

    var srnas = Array();
    for(i in coords) {
        var y = i*1+30;
        var srna_start = (coords[i][0] - start) * f;
        var srna_stop  = (coords[i][1] - start) * f;
        srnas[i] = paper.path('M'+srna_start+' '+y+'L'+srna_stop+' '+y).attr({stroke: 'red'});
    };
}

function drawstructs(div, pgenestruct, srnastruct, degrstruct, start, stop) {
    var box_width = document.getElementById(div).clientWidth - 20;
    var box_height = document.getElementById(div).clientHeight;
    if (paper==undefined) {
        paper = Raphael(div, box_width, box_height);//.initZoom();
    }
    paper.setSize(box_width, box_height);
    paper.clear();
    var genestruct = pgenestruct.split(';');

    var h_utr = 15;
    var h_cds = 20;
    var f = box_width / (stop - start);
    var line = paper.path('M0 '+(h_cds/2)+'L'+(box_width)+' '+(h_cds/2)).attr({stroke: 'grey'});
    var boxes = new Array();
    var startlines = new Array();
    var stoplines = new Array();
    for(i in genestruct) {
        var st = genestruct[i].split(/Y|N/);
        var color = '#f88';
        var h = h_cds;
        var y1 = 1;
        if (genestruct[i].match(/Y/)) {
            color = '#88f';
            h = h_utr;
            y1 = h/2 - (h_cds - h_utr) + 1;
        }

        var x1 = (st[0] - start) * f;
        var x2 = (st[1] - start) * f;

        boxes[i] = paper.rect(x1, y1, x2-x1 + 1, h);
        boxes[i].attr({ fill: color, stroke: color });
        //lines[i] = paper.path('M'+x2+' '+h_cds+'L'+x2+' '+$(div).height()).attr({stroke: '#555'});
        //startlines[i] = paper.path('M'+x1+' '+h_cds+'V'+box_height).setAttr({stroke: '#ddd'});
        //stoplines[i]  = paper.path('M'+x2+' '+h_cds+'V'+box_height).setAttr({stroke: '#ddd'});
        startlines[i] = paper.rect(x1,h_cds,1,box_height).attr({ fill: '#ddd', stroke: 0 });
        stoplines[i]  = paper.rect(x2,h_cds,1,box_height).attr({ fill: '#ddd', stroke: 0 });
    }

    var srnas = Array();
    for(i in srnastruct) {
        var y = i*1 + h_cds*2;
        var srna_start = (srnastruct[i][0] - start) * f;
        var srna_stop  = (srnastruct[i][1] - start) * f;
        //srnas[i] = paper.path('M'+srna_start+' '+y+'L'+srna_stop+' '+y).setAttr({stroke: 'blue'});
        srnas[i] = paper.rect(srna_start,y,srna_stop-srna_start+1,1).attr({fill: 'blue', stroke: 0 }); 
    };

    var degrs = Array();
    for(i in degrstruct) {
        var y = i*1 + h_cds*2;
        var srna_start = (degrstruct[i][0] - start) * f;
        var srna_stop  = (degrstruct[i][1] - start) * f;
        //degrs[i] = paper.path('M'+srna_start+' '+y+'L'+srna_stop+' '+y).setAttr({stroke: 'orange'});
        degrs[i] = paper.rect(srna_start,y,srna_stop-srna_start+1,1).attr({fill: 'orange', stroke: 0});
    };

    if (!zoomAttached) {
        initZoom(div, pgenestruct, srnastruct, degrstruct, start, stop);
    }
}

function clearpaper() {
    paper.clear();
}

var zoomAttached = false;

function initZoom(div, pgenestruct, srnastruct, degrstruct, start, stop) {
    // init the zooming
    if (document.getElementById(div).addEventListener) /** DOMMouseScroll is for mozilla. */
        document.getElementById(div).addEventListener('DOMMouseScroll', function (e) { zoompaper(e, div, pgenestruct, srnastruct, degrstruct, start, stop); }, false);
    document.getElementById(div).onmousewheel = function (e) { zoompaper(e, div, pgenestruct, srnastruct, degrstruct, start, stop); }; /** IE/Opera. */
    zoomAttached = true;
}

var currentzoom = 1;

function zoompaper(event, div, genestruct, srnastruct, degrstruct, start, stop) {
    // http://adomas.org/javascript-mouse-wheel/
    var delta = 0;
    if (!event) /* For IE. */
        event = window.event;
    if (event.wheelDelta) { /* IE/Opera. */
        delta = event.wheelDelta/120;
        if (window.opera)
            delta = -delta;
    } else if (event.detail) { /** Mozilla case. */
        delta = -event.detail/3;
    }
    if (delta) {
        zoom = delta > 0 ? 1.25 : 0.8;
        currentzoom = zoom * currentzoom;
        divel = document.getElementById(div);
        divel.style.width = divel.clientWidth * zoom + 'px';
        drawstructs(div, genestruct, srnastruct, degrstruct, start, stop);
        document.getElementById('zoomlevel').innerHTML = currentzoom.toFixed(2);
    }  
    // Prevent default actions caused by mouse wheel.
    if (event.preventDefault)
        event.preventDefault();
    event.returnValue = false;
}
