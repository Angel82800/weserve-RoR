function rejectDiscussion(id) {
    var response = confirm('Are you sure?');

    if (!response) { return; }
    $.ajax({
        url: '/discussions/'+id,
        type: 'DELETE',
        success: function(data) {
            //$('#discussion-'+id).remove();
        },
        contentType: false,
        dataType: 'json'
    });
}

function acceptDiscussion(id) {
    $.ajax({
        url: '/discussions/'+id+'/accept',
        type: 'PUT',
        success: function(data) {
            //$('.'+data['field_name']+'-content').html(data['content']);
            //$('#discussion-'+id).remove();
        },
        contentType: false,
        dataType: 'json'
    });
}
