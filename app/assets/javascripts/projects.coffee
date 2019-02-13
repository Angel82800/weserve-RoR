# # Place all the behaviors and hooks related to the matching controller here.
# # All this logic will automatically be available in application.js.
# # You can use CoffeeScript in this file: http://coffeescript.org/

window.alertSuccess =->
  editSuccessHtml = '<div id="editAlert" data-alert class="alert-box info radius">
    You\'ve successfuly edited the project description.
    <a onClick="closeEditAlert();" class="close">&times;</a>
  </div>'
  $("div[data-edit-alert]").append(editSuccessHtml)

window.saveEdit = (projectId)->
  $("#proj-desc").attr("contenteditable", false)
  $("#editBtn").css("color", "").css("background", "").text("Edit")
  $("#editBtn").off().on "click", (e)->
    e.preventDefault()
    makeEditable()
  description = $("#proj-desc").text()
  $.ajax({
    url: '/projects/' + projectId + '/save_edits',
    dataType: "json",
    method: 'POST',
    data: { project: {id: projectId, project_edit: description } }
  }).then (data)->
    alertSuccess()

window.closeEditAlert=->
  $("#editAlert").remove()
  false

# makes the project description editable
window.makeEditable = (projectId)->
  $("#proj-desc").attr("contenteditable", true)
  $("#editBtn").css("color", "white").css("background", "orange").text("Save")
  $("#editBtn").off().on "click", (e)->
    e.preventDefault()
    saveEdit(projectId)

#update the status of an edit via ajax
window.updateEdit = (projectEditId, new_state)->
  projectId = $("button[data-makes-editable]").data("makes-editable")
  $.ajax({
    url: '/projects/' + projectId + '/update_edits',
    dataType: "json",
    method: 'POST',
    data: { project: {id: projectId, editItem: {id: projectEditId, new_state: new_state} } }
  }).then (dt, textStatus, xhr)->
    console.log(dt)
    console.log(xhr.status)
    if xhr.status == 200
      deleteDiv = "project-edit-" + projectEditId
      $("#" + deleteDiv).remove()
      if new_state == "accepted"
        $("#proj-desc").text(dt.description)
      alertSuccess()

jQuery ->
  $(document).foundation()
  $(document).on "mouseenter", ".star-rating-sm > i", (e) ->
    e.preventDefault()
    $(@).parent().find('i').removeClass("seleted")
    $(@).prevAll('i').addClass('seleted')
    $(@).addClass('seleted')

  $(document).on "mouseleave", ".star-rating-sm", (e) ->
    e.preventDefault()
    $(@).find('i').removeClass("seleted")
    rate = $(@).data('rate')
    if rate > 0
      $(@).find('i').slice(0, rate).addClass('seleted')

  $(document).on "click", ".star-rating-sm > i", (e) ->
    $this = $(@)
    rate = $this.parent().find('i').index(@) + 1
    $.ajax(
      url: "/projects/#{projectId}/rate"
      dataType: "json"
      method: "POST"
      data:
        rate: rate
    ).done (data) ->
      $this.parent().data('rate', data.average)
      .error (e) ->
      window.location = '/users/sign_in' if e.status == 401

  $('#project_expires_at').datepicker()
  $(document).foundation()

  $(document).on "mouseleave", ".star-rating-sm", (e) ->
    e.preventDefault()
    $(@).find('i').removeClass("seleted")
    rate = $(@).data('rate')
    if rate > 0
      $(@).find('i').slice(0, rate).addClass('seleted')

  $(document).on "click", ".star-rating-sm > i", (e) ->
    $this = $(@)
    rate = $this.parent().find('i').index(@) + 1
    $.ajax(
      url: "/projects/#{projectId}/rate"
      dataType: "json"
      method: "POST"
      data:
        rate: rate
    ).done (rate) ->
      $this.parent().data('rate', rate.rate)
      .error (e) ->
      window.location = '/users/sign_in' if e.status == 401

  $('#project_expires_at').datepicker()

  #attach handlers to data attributes
  $("button[data-makes-editable]").off().on "click", (e)->
    e.preventDefault()
    projectId = $(this).data("makes-editable")
    makeEditable(projectId)

  $("button[data-accepts-edit]").off().on "click", (e)->
    e.preventDefault()
    projectEditId = $(this).data("accepts-edit")
    updateEdit(projectEditId, "accepted")

  $("button[data-rejects-edit]").off().on "click", (e)->
    e.preventDefault()
    projectEditId = $(this).data("rejects-edit")
    updateEdit(projectEditId, "rejected")

  $(document).on 'page:load', ->
    console.log( "readyp!" )
    #attach handlers to data attributes
    $("button[data-makes-editable]").off().on "click", (e)->
    e.preventDefault()
    projectId = $(this).data("makes-editable")
    makeEditable(projectId)

    $("button[data-accepts-edit]").off().on "click", (e)->
      e.preventDefault()
      projectEditId = $(this).data("accepts-edit")
      updateEdit(projectEditId, "accepted")

    $("button[data-rejects-edit]").off().on "click", (e)->
      e.preventDefault()
      projectEditId = $(this).data("rejects-edit")
      updateEdit(projectEditId, "rejected")

  $(document).on "click", "#sign_up_nav", (e) ->
    start_by_signup = false
    $.ajax(
      url: "/projects/start_project_by_signup"
      dataType: "json"
      method: "POST"
      data:
        start_by_signup: start_by_signup
    ).done (status) ->
      return true
      .error (e) ->
      return false

  $(document).on "click", "#start_project_link", (e) ->
    start_by_signup = true
    $.ajax(
      url: "/projects/start_project_by_signup"
      dataType: "json"
      method: "POST"
      data:
        start_by_signup: start_by_signup
    ).done (status) ->
      return true
      .error (e) ->
      return false

  $(document).on "click", "#create-sub-project", (e) ->
    e.preventDefault()
    e.stopPropagation()
    modal = $('#startProjectModal')
    modal.find('#project_parent_id').attr('value', $(@).data('project-id'))

    if modal.selector == '#registerModal'
      $('.alert-box.alert').hide()
    modal.fadeIn()
    $html.addClass '_open-modal'

  $(document).on "click", "#sd_pencil", ->
    text_length = $(".form_in_place textarea").val().length
    text_remaining = 250 - text_length
    $('<div id="textarea_feedback" style="padding-bottom: 10px; float: left"><label class="f-default__label"></label></div>').insertAfter( $('.form_in_place textarea') );
    $('.form_in_place #textarea_feedback > label').html text_remaining + ' characters remaining'

  elements = '.modal-task__title-wrap .btn-edit, .task-desc .btn-edit'
  $(document).on "click", elements, ->
    $(this).siblings('.js-toggleForm').click()

jQuery ->
  new CarrierWaveCropper()

class CarrierWaveCropper
  constructor: ->
    $('#project_picture_cropbox').Jcrop
      onSelect: @update
      onChange: @update
      boxHeight: 300
    $('#user_picture_cropbox').Jcrop
      onSelect: @update
      onChange: @update
      boxWidth: 300
      boxHeight: 300

  update: (coords) =>
    $('#project_picture_crop_x').val(coords.x)
    $('#project_picture_crop_y').val(coords.y)
    $('#project_picture_crop_w').val(coords.w)
    $('#project_picture_crop_h').val(coords.h)

    $('#user_picture_crop_x').val(coords.x)
    $('#user_picture_crop_y').val(coords.y)
    $('#user_picture_crop_w').val(coords.w)
    $('#user_picture_crop_h').val(coords.h)
    @updatePreview(coords)

  updatePreview: (coords) =>
    $('#project_picture_previewbox').css
      width: Math.round(100/coords.w * $('#project_picture_cropbox').width()) + 'px'
      height: Math.round(100/coords.h * $('#project_picture_cropbox').height()) + 'px'
      marginLeft: '-' + Math.round(100/coords.w * coords.x) + 'px'
      marginTop: '-' + Math.round(100/coords.h * coords.y) + 'px'
    $('#user_picture_previewbox').css
      width: Math.round(100/coords.w * $('#user_picture_cropbox').width()) + 'px'
      height: Math.round(100/coords.h * $('#user_picture_cropbox').height()) + 'px'
      marginLeft: '-' + Math.round(100/coords.w * coords.x) + 'px'
      marginTop: '-' + Math.round(100/coords.h * coords.y) + 'px'

$ ->
  loading = false
  ajaxIsLoadingIndicator = $('#ajaxLoading')
  scrollToLoadMore = $('#scroll-to-load-more')    # todo FD: look like dead code
  $(document).bindWithDelay "scroll", ->
    windowBottom = $(window).scrollTop() + $(window).height() + 500

    # SCROLLED TO THE END OF SCREEN: LOADING NEXT PAGE
    if !loading && (windowBottom) >= $(document).height()
      loadItemsFromServer()
  , 10

  loadItemsFromServer = ->
    loading = true
#    check if the request is not yet complete
#    the data attribute will be set when the items are loaded into dom
    if ($('#paginator').data('remoteFetch') != 'pending' )
      $('#paginator').data('remoteFetch', 'pending')
      $(".load-more").removeClass('hide')
      ajaxIsLoadingIndicator.addClass('show-div')
      nextLink = $('.next a')
      nextLink.click()
      ajaxIsLoadingIndicator.removeClass('show-div')

    loading = false

  $(document).on "click", "#be_lead_editor", (e) ->
    alert "Hello";

  if typeof gon != 'undefined' and gon.short_descr_limit != 'undefined'
    # Create new project - short_description limitation
    text_max = 250
    tr_chars_remaining = $("#textarea_feedback").data "chars-remaining"
    $('#textarea_feedback > label').html text_max + ' ' + tr_chars_remaining
    $('#description-field, .b-project-info__user-name span').keyup ->
      if this.id == 'description-field'
        text_length = $('#description-field').val().length
        text_remaining = text_max - text_length
        text_remaining_str = text_remaining + ' ' + tr_chars_remaining
        $('#project-form #textarea_feedback > label').html text_remaining_str
      else if $(this).attr('class') == 'best_in_place'
        text_length = $(".form_in_place textarea").val().length
        text_remaining = text_max - text_length
        text_remaining_str = text_remaining + ' ' + tr_chars_remaining
        $('.form_in_place #textarea_feedback > label').html text_remaining_str
      return

$(document)
  .on 'click', '#editSource', ->
    project_id = $(".project_headline_wrapper").data('id')
    $.ajax({
      url: "/projects/#{project_id}/revisions",
      dataType: "script"
    }).success ->
      if (!$('.approval-switch input').is(':checked'))
        $('.revision-history__mark').addClass('_hide')

  .on 'click', '#modalVerification ._agree', ->
    project_id = $(".project_headline_wrapper").data('id')
    $(".revision-histories-body").
      html("<div class='center'><h4>Please wait....</h4></div>")
    updateInputState()
    $.ajax({
      url: "/projects/#{project_id}/switch_approval_status",
      type: "POST",
      data: {is_approval_enabled: $('.approval-switch input').is(':checked')},
      dataType: "script"
    }).success ->
      if (!$('.approval-switch input').is(':checked'))
        $('.revision-history__mark').addClass('_hide')
    $('#modalVerification').fadeOut()
    $('html').removeClass('_open-modal')

  .on 'click', '#modalVerification ._decline', ->
    $('#modalVerification').fadeOut()
    $('html').removeClass('_open-modal')

  .on 'click', '.modal-default__close', (e) ->
    $('#modalVerification').fadeOut()

  # todo organize all modals in separate module
  .on 'click', '#modalVerification', (e) ->
    if (e.target == this)
      $('#modalVerification').fadeOut()
