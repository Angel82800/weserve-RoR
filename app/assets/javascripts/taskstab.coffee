
$().ready ->
  $('#loading-mask1').hide()

  $('#send-project-email').submit ->
    $('#response').empty()
    $('#response').html 'loading...'
    return

  $('#send-project-email-button').click ->
    $('#response').empty()
    return

  $('.btn_movecard').click ->
    loading = document.getElementById('loading-mask1')
    loading.style.display = 'block'
    return

  $('#inviteclose').click ->
    $('#response').empty()
    $('#response-failure').empty()
    $ '#response-success'
    $('#guest-email').val ''
    return

  $('#guest-email').keyup ->
    $('#response').empty()
    $('#response-failure').empty()
    $ '#response-success'
    return

  return
