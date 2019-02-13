'use strict';

$(document).ready(function($) {
      var currentBoardUrl = null;

  $(document)
    .off('click.setCurrentBoardUrl', '[data-modal="#removeBoard"]')
    .off('click.agreeRemoveBoard', '#removeBoard ._agree')
    .off('click.declineRemoveBoard', '#removeBoard ._decline');

  $(document)
    .on('click.setCurrentBoardUrl', '[data-modal="#removeBoard"]', function () {
      currentBoardUrl = $(this).data('deleteUrl');
    })
    .on('click.agreeRemoveBoard', '#removeBoard ._agree', function () {
      $.ajax({
        type: 'DELETE',
        url: currentBoardUrl,
        success: function(data) {
          location.reload();
        }
      });
    })
    .on('click.declineRemoveBoard', '#removeBoard ._decline', function () {
      $('#removeBoard').trigger('click');
    })
});
