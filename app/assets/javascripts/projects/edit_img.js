'use strict';

$(document).ready(function($) {
  // preview edit project background picture

  $('#project_picture').on('change', function (input) {
    var files = input.target.files;

    if(files && files[0]) {
      var reader = new FileReader();
      reader.onload = function(e) {
        $('#project_picture_cropbox').attr('src', e.target.result);
        $('.jcrop-holder img').attr('src', e.target.result);
      };
      //add to preview
      reader.readAsDataURL(files[0]);
    }
  });
});
