window.boards =
  init: ->
    @rearrangeBoards()

  rearrangeBoards: ->
    $('.nav.nav-pills.nav-left.m-tabs.nav-board').sortable
      start: (event, ui) ->
        ui.item.startPos = ui.item.index()
      stop: (e, ui) ->
        last_priority = $(this).find('li').length - 1
        arr = [ui.item.index(), last_priority]
        cond_start = arr.includes(ui.item.startPos)
        cond_stop = last_priority == ui.item.index()
        return false if cond_start || cond_stop
        boardOrder = $(this).sortable("toArray", {attribute: "data-board-id"})
        selector = $(this).parents().find('.trello-board:first')
        projectId = selector.data('project_id')
        $.ajax
          url: "/projects/#{projectId}/rearrange_order_boards",
          method: "POST"
          dataType: 'json'
          data: {boards_order: boardOrder}
