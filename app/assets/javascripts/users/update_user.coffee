replace_upload = (picture) ->
  if picture
    empty_upload = '<input type="file" name="picture" id="tmp-user-picture"' +
      ' accept="image/png,image/gif,image/jpeg" class="btn-upload">'
    $(empty_upload).insertAfter($("#tmp-user-picture"))
    $("#tmp-user-picture").remove()
  else
    empty_upload = '<input type="file" name="background_picture"' +
        ' id="tmp-user-background-picture"' +
        ' accept="image/png,image/gif,image/jpeg" class="btn-upload">'
    $(empty_upload).insertAfter($("#tmp-user-background-picture"))
    $("#tmp-user-background-picture").remove()

save_img = (type, image, picture) ->
  userId = $('#profile').data('id')
  if image
    userNewData = new FormData()
    userNewData.append(type, image)
    $.ajax
      url: '/users/' + userId
      method: 'PUT'
      data: userNewData
      processData: false
      contentType: false
      success: (event, data, status, xhr) ->
        if picture
          img = $('.f-edit-img__image img').attr('src')
          $(".modal-edit-profile__avatar").css('background-image',
            'url(' + img + ')')
    replace_upload(picture)

$ ->
  array = ['image/png','image/gif','image/jpeg']
  error_message = 'Picture allowed only types: jpg, jpeg, gif, png.'
  html = '<div class="alert alert-danger" style="margin-top: 30px;">' +
    '<a href="#" class="close" data-dismiss="alert"' +
    ' aria-label="close">&times;</a><strong>Error!</strong>' +
    error_message + '</div>'

  $(document).on "change", "#tmp-user-picture", (e) ->
    input = $(this)[0]
    $('.modal-default__content .alert-danger').remove()
    if input.files && input.files[0]
      picture = input.files[0]
      reader = new FileReader()
      if picture && array.indexOf(picture.type) isnt -1
        reader.onload = (e) ->
          $('.f-edit-img__image img,' +
              ' .f-edit-img__placeholder img').attr('src', e.target.result)
          $('.jcrop-holder img').attr('src', e.target.result)
        reader.readAsDataURL(input.files[0])
      else
        replace_upload(true)
        $(html).insertAfter($('.f-edit-img__image'))
    e.preventDefault

  $(document).on "change", "#tmp-user-background-picture", (e) ->
    input = $(this)[0]
    $('.modal-default__content .alert-danger').remove()
    if input.files && input.files[0]
      picture = input.files[0]
      reader = new FileReader()
      if picture && array.indexOf(picture.type) isnt -1
        reader.onload = (e) ->
          $('.f-edit-bcg__image img').attr('src', e.target.result)
        reader.readAsDataURL(input.files[0])
      else
        replace_upload(false)
        $(html).insertAfter($('.f-edit-bcg__image'))
    e.preventDefault

  $(document).on "click", ".btn-save-user-picture", (e) ->
    picture = $("#tmp-user-picture")[0].files[0]
    save_img("user[picture]", picture, true)
    e.preventDefault

  $(document).on "click", ".btn-save-user-background-picture", (e) ->
    picture = $("#tmp-user-background-picture")[0].files[0]
    save_img("user[background_picture]", picture, false)
    e.preventDefault
