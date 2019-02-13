window.tasks =
  init: ->
    @rearrangeTasks()

  rearrangeTasks: ->
    $('.tasks-in-column').sortable
      start: (event, ui) ->
        ui.item.startPos = ui.item.index()
      stop: (e, ui) ->
        return false if ui.item.startPos == ui.item.index()
        taskOrder = $(this).sortable("toArray", {attribute: "data-task-id"})
        projectId = $(this).parents().find('.trello-board:first').data('project_id')
        $.ajax
          url: "/projects/#{projectId}/rearrange_order_tasks",
          method: "POST"
          dataType: 'json'
          data: {tasks_order: taskOrder}

  initShowRejectPopover: (actionType)->
    $("#" + actionType + "TaskPopover").popover
      html: true
      content: () ->
        $("#" + actionType + "TaskPopoverContent").html()
      title:  () ->
        $("#" + actionType + "TaskPopoverTitle").html()

  handleStateDropdown: ->
    tasks.initShowRejectPopover("reject")
    tasks.initShowRejectPopover("cancel")
    $('#approveTaskPopover, #rejectTaskPopover, #cancelTaskPopover')
    .on 'click', (event) ->
      event.stopPropagation()

    # should not be displayed
    # for current user have not transitions not available
    unless $('.state-transition-list li').length
      $('.task-state-transition-dropdown').hide()

$(document).on "change", ".modal-new-task__checkbox", (e) ->
  budgetField = $('.modal-new-task__usd-amount')
  memberField = $('.modal-new-task__member_amount')
  if budgetField.attr('disabled')
    budgetField.removeAttr('disabled')
    memberField.val('1')
    memberField.attr('disabled', '')
  else
    budgetField.val('')
    budgetField.attr('disabled', '')
    memberField.removeAttr('disabled')
  e.preventDefault()

$(document).on "click", ".transition-state, .approve-btn", ->
  $('.task-state-transition-dropdown').removeClass('open')
  $("#state-transition-menu").attr('disabled', true)

$(document).on "click", ".task-state-transition-dropdown ._close-modal", ->
  $("#state-transition-menu").attr('disabled', false)
