var removeProject = function (projectID) {
  var $modalRemoveProject = $('#modalRemoveProject');
  $("#remove-project-path").attr("href", "/projects/"+ projectID);

}
$(function(){
  $(document)
    .on('click.agree', '#modalRemoveProject ._decline', function () {
      $('#modalRemoveProject').trigger('click');
    })
})
