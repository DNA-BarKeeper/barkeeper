jQuery(function() {
    $('#ngs_runs').dataTable({
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#ngs_runs').data('source'),
        "columnDefs": [{
            "targets": 2,
            "orderable": false
        }],
        "order": [1, 'desc']
    });
});

$(document).ready(function(){
    if($('#multiple_sets').val() != "In Progress"){
        $("#multiple_sets").attr('disabled','disabled');
    }
    else{
        $("#multiple_sets").removeAttr('disabled');
    }

    $('#multiple_sets').change(function(){
        if($(this).val() != "In Progress"){
            $("#project_capital_cost").attr('disabled','disabled');
        }
        else{
            $("#project_capital_cost").removeAttr('disabled');
        }
    })
});