var paper;

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
