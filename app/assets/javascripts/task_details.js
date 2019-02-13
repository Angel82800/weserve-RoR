window.TaskDetails = {
  updateTaskBudget: function (taskID, confirmMessage, taskFree) {
    var budgetConfirm = confirm(confirmMessage);
    if (!budgetConfirm) return;

    $.ajax({
      url: "/tasks/" + taskID,
      type: "PUT",
      data:
      {
        task: {
          free: taskFree
        }
      },
      success: function() {
        location.reload();
      }
    });
  },

  handleBudget: function (taskID, confirmMessage, mark_task_as_free) {
    var selector = mark_task_as_free ? '.modal-task_rm-budget-btn' : '.modal-task__free-btn';
    $(selector).on('click', function() {
      TaskDetails.updateTaskBudget(taskID, confirmMessage, mark_task_as_free);
    })
  }
};

$(document).on('click', '#update-task_in_progress', function(e) {
  var id = $(".task-details").data('id'),
      name = $(this).data('value'),
      value = $("#input-task-" + name).val(),
      param = $(this).data('param'),
      data = {};
  data[param] = value;
  $.ajax({
    url: "/tasks/" + id + "/update_task_in_progress",
    type: "PUT",
    data: { task: data },
    success: function(data) {
      $('.modal-badge-informing').html(data["badge"]);
      $('.modal-badge-informing').css('display', 'block');
    }
  });
  e.preventDefault();
});

function update_after_response(id, data) {
  $('a[data-task-id="' + id + '"] .card-title h5').text(data.title);
  $('#task-title').text(data.title);
  $('#task-condition').text(data.condition_of_execution);
  $('#task-proof').text(data.proof_of_execution);
  $('.task-condition').text(data.condition_of_execution);
  $('.task-proof').text(data.proof_of_execution);
}

$(document).on('click', '.preview, .exit_preview', function(e) {
  var id = $(".task-details").data('id'),
      leader = $(".task-details").data('leader'),
      data = { leader: leader };
  if (!$(this).hasClass('exit_preview'))
    data = { preview: true, leader: leader };
  $.ajax({
    url: "/tasks/" + id + "/preview",
    type: "GET",
    data: data,
    success: function(data) {
      update_after_response(id, data["task"]);
      $('.modal-badge-informing').html(data["badge"]);
    }
  });
  e.preventDefault();
});

$(document).on('click', '.approve_change, .reject_change, .dismiss', function(e) {
  var id = $(".task-details").data('id'),
      data = {};

  if ($(this).hasClass('approve_change'))
    data = { approve: true };
  if ($(this).hasClass('reject_change'))
    data = { reject: true };

  $.ajax({
    url: "/tasks/" + id + "/set_approve_change_task",
    type: "PUT",
    data: data,
    success: function(data) {
      update_after_response(id, data);
      $('.modal-badge-informing').css('display', 'none');
      $('.modal-badge-informing').html('');
    }
  });
  e.preventDefault();
});

$(document).on('click', '.modal-content .glyphicon-pencil', function(e) {
  var id = 'changed-task-' + $(".task-details").data('id');
  if ($(".task-details").data('leader') && $(".task-details").data('progress') && !localStorage[id]) {
    localStorage[id] = true;
    $('#myModalWarning').modal('show');
  }
  e.preventDefault();
});

$(document).on('click', '.modal-task_submit-review-btn', function(e) {
  $('#taskSubmitReview').show();
});

$(document).on('click', '.later', function(e) {
  $('#taskSubmitReview').hide();
});

$(document).on('click', '.full', function(e) {
  $('.modal-review-task_stars p').hide();
  $('#star5').removeAttr('required');
  var value =  $(this).prev().val();
  $('.stars').text(' ' + value + '/5');
});

$(document).on('click', '.modal-review-task_submit', function() {
  $('.modal-review-task_stars p').hide();
  if ($('.modal-review-task_stars input:checked').length < 1)
    $('.modal-review-task_stars p').show()
});