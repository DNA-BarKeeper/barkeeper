jQuery(function() {
    $('#individuals').DataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#individuals').data('source'),
        "columnDefs": [
            { "orderable": false, "targets": 1 },
            { "orderable": false, "targets": 6 }
        ],
        "order": [5, 'desc']
    });
    return $('#individual_species_name').autocomplete({
        source: $('#individual_species_name').data('autocomplete-source')
    });
});

function init() {
    // stuff runs faster when objects are in vars
    d = document;

    // set up the form objects
    ddLat  = d.getElementById("dd_lat");
    ddLong = d.getElementById("dd_long");

    dmsLatDeg = d.getElementById("dms_lat_deg");
    dmsLatMin = d.getElementById("dms_lat_min");
    dmsLatSec = d.getElementById("dms_lat_sec");
    dmsLatHem = d.getElementById("dms_lat_hem");

    dmsLongDeg = d.getElementById("dms_long_deg");
    dmsLongMin = d.getElementById("dms_long_min");
    dmsLongSec = d.getElementById("dms_long_sec");
    dmsLongHem = d.getElementById("dms_long_hem");
}

function dd2dms() {

    // are there minus signs ?

    if (ddLat.value.substr(0,1) == "-") {
        dmsLatHem.options.selectedIndex = 1;
        ddLatVal = ddLat.value.substr(1,ddLat.value.length-1);
    } else {
        dmsLatHem.options.selectedIndex = 0;
        ddLatVal = ddLat.value;
    }

    if (ddLong.value.substr(0,1) == "-") {
        dmsLongHem.options.selectedIndex = 1;
        ddLongVal = ddLong.value.substr(1,ddLong.value.length-1);
    } else {
        dmsLongHem.options.selectedIndex = 0;
        ddLongVal = ddLong.value;
    }

    // degrees = degrees
    ddLatVals = ddLatVal.split(".");
    dmsLatDeg.value = ddLatVals[0];

    ddLongVals = ddLongVal.split(".");
    dmsLongDeg.value = ddLongVals[0];

    // * 60 = mins
    ddLatRemainder  = ("0." + ddLatVals[1]) * 60;
    dmsLatMinVals   = ddLatRemainder.toString().split(".");
    dmsLatMin.value = dmsLatMinVals[0];

    ddLongRemainder  = ("0." + ddLongVals[1]) * 60;
    dmsLongMinVals   = ddLongRemainder.toString().split(".");
    dmsLongMin.value = dmsLongMinVals[0];

    // * 60 again = secs
    ddLatMinRemainder = ("0." + dmsLatMinVals[1]) * 60;
    dmsLatSec.value   = Math.round(ddLatMinRemainder);

    ddLongMinRemainder = ("0." + dmsLongMinVals[1]) * 60;
    dmsLongSec.value   = Math.round(ddLongMinRemainder);
}

function dms2dd() {
    // get decimal latitude
    ddLatVal = dmsLatDeg.value*1 + dmsLatMin.value/60 + dmsLatSec.value/3600;
    ddLatVal = dmsLatHem.options[dmsLatHem.selectedIndex].value + ddLatVal;

    // get decimal longitude
    ddLongVal = dmsLongDeg.value*1 + dmsLongMin.value/60 + dmsLongSec.value/3600;
    ddLongVal = dmsLongHem.options[dmsLongHem.selectedIndex].value + ddLongVal;

    // display in form
    ddLat.value  = ddLatVal;
    ddLong.value = ddLongVal;
}