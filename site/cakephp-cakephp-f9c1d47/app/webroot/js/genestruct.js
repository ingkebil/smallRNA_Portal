function genestruct(div, coords) {
    var paper = Raphael(div, 500, 250);

    var coords = coords.split(';');
    var boxes = new Array();

    for(i in coords) {
        var st = coords[i].split(/Y|N/);
        var color = coords[i].match(/Y/) ? 'red' : 'blue';

        var f = 500 / (19800136 - 19798107);

        var x1 = (st[0] - 19798107) * f;
        var x2 = (st[1] - 19798107) * f;

        boxes[i] = paper.rect(x1, 10, x2-x1, 20);
        boxes[i].attr({ fill: color });
    }
}
