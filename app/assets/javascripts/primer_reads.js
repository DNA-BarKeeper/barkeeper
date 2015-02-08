jQuery(function() {
    $('#new_primer_read').fileupload({
        dataType: "script",
        add: function(e, data) {
            data.context = $(tmpl("template-upload", data.files[0]));
            $('#new_primer_read').append(data.context);
            return data.submit();
        },
        progress: function(e, data) {
            var progress;
            if (data.context) {
                progress = parseInt(data.loaded / data.total * 100, 10);
                return data.context.find('.progress-bar.progress-bar-striped.active').css('width', progress + '%');
            }
        }
    });
    $('#primer_reads').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#primer_reads').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 4 }
        ]
    });
    $('#primer_read_contig_name').autocomplete({
        source: $('#primer_read_contig_name').data('autocomplete-source')
    });


//    draw chromatogram
    var chromatogram1 = $('#chromatogram').data('url');

    if (chromatogram1){
        draw_chromatogram(chromatogram1);

        //clean up
        $('#loading').remove()
    }

});

function draw_chromatogram(chromatogram1){
    var canvas = document.getElementById('ChromatogramCanvas');
    canvas.width= chromatogram1.atrace.length*2;
    canvas.height = 500;
    canvas.style.width = chromatogram1.atrace.length +"px";
    canvas.style.height = "250px";
    ymax=250;

    var ctx = canvas.getContext('2d');

    var r=window.devicePixelRatio;

    if (r > 1 ) {
        ctx.scale(r,r);
    }

    //mk dynamic via slider (deactivated) or createJS -mouse-drag later:
    var scale=4;

    ctx.textAlign='center';

    ctx.fillStyle = '#d3d3d3';


    if (chromatogram1.trimmedReadStart){
        ctx.rect(0, 0, chromatogram1.peak_indices[chromatogram1.trimmedReadStart-1]-5, ymax);
        ctx.fill();

        ctx.rect(chromatogram1.peak_indices[chromatogram1.trimmedReadEnd-1]+5, 0, chromatogram1.atrace.length, ymax);
        ctx.fill();

    }

    <!--A trace-->
    ctx.strokeStyle = 'green';
    ctx.beginPath();
    ctx.moveTo(0, ymax);
    var y=0;
    for(var i = 0; i < chromatogram1.atrace.length; i++){
        y=ymax-chromatogram1.atrace[i]/scale;
        ctx.lineTo(i,y);
        ctx.moveTo(i,y);
    }
    ctx.stroke();
    ctx.closePath();

    <!--C trace-->
    ctx.strokeStyle = 'blue';
    ctx.beginPath();
    ctx.moveTo(0, ymax);
    var y=0;
    for(var i = 0; i < chromatogram1.ctrace.length; i++){
        y=ymax-chromatogram1.ctrace[i]/scale;
        ctx.lineTo(i,y);
        ctx.moveTo(i,y);
    }
    ctx.stroke();
    ctx.closePath();

    <!--G trace-->
    ctx.strokeStyle = 'black';
    ctx.beginPath();
    ctx.moveTo(0, ymax);
    var y=0;
    for(var i = 0; i < chromatogram1.gtrace.length; i++){
        y=ymax-chromatogram1.gtrace[i]/scale;
        ctx.lineTo(i,y);
        ctx.moveTo(i,y);
    }
    ctx.stroke();
    ctx.closePath();

    <!--T trace-->
    ctx.strokeStyle = 'red';
    ctx.beginPath();
    ctx.moveTo(0, ymax);
    var y=0;
    for(var i = 0; i < chromatogram1.ttrace.length; i++){
        y=ymax-chromatogram1.ttrace[i]/scale;
        ctx.lineTo(i,y);
        ctx.moveTo(i,y);
    }
    ctx.stroke();
    ctx.closePath();

//  base calls
    var pos=0;

    for(var i = 0; i < chromatogram1.peak_indices.length; i++){
        pos = chromatogram1.peak_indices[i];
        var ch = chromatogram1.sequence[i];

        ctx.strokeStyle = 'gray';
        ctx.font = '7pt Courier New';

        var disp = i+1;
        if(disp % 10 == 0){
            ctx.strokeText(disp, pos, 20);
            ctx.strokeText('.', pos, 27);
        }

        if (ch == 'A') {
            ctx.strokeStyle = 'green';
        } else if (ch == 'C') {
            ctx.strokeStyle = 'blue';
        } else if (ch == 'G') {
            ctx.strokeStyle = 'black';
        } else if (ch == 'T') {
            ctx.strokeStyle = 'red';
        } else {
            ctx.strokeStyle = 'gray';
        }

        ctx.font = '10pt Courier New';
        ctx.strokeText(ch, pos, 40);
        ctx.font = '5pt Courier New';
        ctx.strokeStyle = 'gray';
        ctx.strokeText(chromatogram1.qualities[i], pos, 60);
    }
}