  
$().ready ->
  toggleMobileMenu = (isShow) ->
    if isShow
      $('.mobile-menu').slideToggle 'slow', ->
        $('.cross').show()
        $('.hamburger').hide()
        return
    else
      $('.mobile-menu').slideToggle 'slow', ->
        $('.cross').hide()
        $('.hamburger').show()
        return
    return

  toggleMobileUserMenu = (isShow) ->
    if isShow
      $('.mobile-user-submenu').slideToggle 'slow', ->
        $('.mobile-user-menu .fa-chevron-right').show()
        $('.mobile-user-menu .fa-chevron-down').hide()
        return
    else
      $('.mobile-user-submenu').slideToggle 'slow', ->
        $('.mobile-user-menu .fa-chevron-right').hide()
        $('.mobile-user-menu .fa-chevron-down').show()
        return
    return

  $('.cross').hide()
  $('.mobile-menu').hide()

  $('.hamburger').click ->
    toggleMobileMenu true
    return

  $('.cross').click ->
    toggleMobileMenu false
    return

  # $('.mobile-menu ul a').click ->
  #   toggleMobileMenu false
  #   return

  $('.mobile-user-menu .fa-chevron-right').hide()
  $('.mobile-user-submenu').hide()

  $('.mobile-user-menu .fa-chevron-down').click ->
    toggleMobileUserMenu true
    return

  $('.mobile-user-menu .fa-chevron-right').click ->
    toggleMobileUserMenu false
    return

  $('.notification-item').click ->
    window.location = "/notifications"

  return
