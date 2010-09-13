function drawstructs(div, pgenestruct, srnastruct, degrstruct, start, stop) {
    var box_width = document.getElementById(div).clientWidth - 20;
    var box_height = document.getElementById(div).clientHeight;
    var genestruct = pgenestruct.split(';');

    var h_utr = 15;
    var h_cds = 20;
    var f = box_width / (stop - start);
    horline(div, 0, h_cds/2, box_width, 'grey');
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

        rect(div, x1, h_utr,x2,box_height,'#eee', 0, 1); // the box underneath the exon
        rect(div, x1, y1, x2, h, color, 0, 1); // the exon
    }

    structs = {srna:{struct:srnastruct,color:'blue'},degr:{struct:degrstruct,color:'orange'}};
    for(s in structs) {
        var prev_x = 0;
        var cur_y  = 0;
        var cur_s = structs[s]['struct'];
        for(i in cur_s) {
            cur_y++;
            //if ((prev_x*1 + 45) < cur_s[i][0]) {
            //    cur_y = 0;
            //}
            var y = cur_y*1 + h_cds*2;
            var srna_start = (cur_s[i][0] - start) * f;
            var srna_stop  = (cur_s[i][1] - start) * f;
            horline(div,srna_start,y,srna_stop-srna_start+1,structs[s]['color'],cur_s[i][2]); 
            //if (i-20 > 1) {
            //    prev_x = cur_s[i-20][0];
            //}

        }
    }

    if (!zoomAttached) {
        initZoom(div, pgenestruct, srnastruct, degrstruct, start, stop);
    }
}

function horline(div, x1, y1, len, color, id) {
    rect(div, x1, y1, len + x1 - 1, y1, color, id,1);
}

function verline(div, x1, y1, h, color, id) {
    rect(div, x1, y1, x1, h + y1, color, id,1);
}

function rect(div, x1, y1, x2, y2, color, id,rel) {
    d = document.getElementById(div);
    w = d.clientWidth;
    c = document.createElement('span');
    //l = document.createElement('a');
    //l.setAttribute('href','/smallrna/srnas/view/'.id);

    if (rel != undefined) {
        left = x1/w*100+'%';
        width = (x2-x1+1)/w*100+'%';
    }
    else {
        left = x1+'px';
        width = (x2-x1+1)+'px';
    }

    c.style.cssText = 'height:'+(y2-y1+1)+'px;border:none;color:'+color+';background-color:'+color+';position:absolute;left:'+left+';top:'+y1+'px;width:'+width;
    c.innerHTML = '&nbsp;';
    //l.appendChild(c);
    d.appendChild(c);
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
        //drawstructs(div, genestruct, srnastruct, degrstruct, start, stop);
        document.getElementById('zoomlevel').innerHTML = currentzoom.toFixed(2);
    }  
    // Prevent default actions caused by mouse wheel.
    if (event.preventDefault)
        event.preventDefault();
    event.returnValue = false;
}
