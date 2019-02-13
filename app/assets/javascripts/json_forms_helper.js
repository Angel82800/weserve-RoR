var JsonFormsHelper = {
    InitializeNotificationsControls: function() {
        initializeInvitationsControls();
        initializeRequestsControls();
        initializeDeleteNotificationsControls();
    },

    InitializeAdminRequestsControls: function() {
        initializeAdminRequestControls();
    },

    InitializeTeamMembersControls: function () {
        initializeTeamMembersControls();
    },

    InitializeTaskMembersControls: function () {
        initializeTaskMemberDeleteControls();
    }
}

function initializeTeamMembersControls() {
    $('.delete-member').click(function(e) {
        $.ajax({
            type: 'DELETE',
            url: "/team_memberships/" + $(this).attr('team-membership-id'),
            data: { delete_team_member: true },
        }).done(function(data) {
            $("#team-member-" + data.id).hide(500);
            $('[data-tab=team] .count').text(data.count_members);
        }).fail(function(data) {
            console.log(data);
        });
    });

    $('.delete-role').click(function(e) {
      var truthy = $(this).parents('.member-box').find('.member-role').length < 2;
      var data = truthy ? { delete_team_member: true } : {};
      var member_role = $(this).parents('.member-role');
      var role =member_role.find('.role span').text();
      if (confirm("Are you sure you want to revoke the " + role + " rights for this user?")) {
        $.ajax({
          type: 'DELETE',
          url: "/team_memberships/" + $(this).attr('team-membership-id'),
          data: data,
        }).done(function (data) {
          if (truthy) {
            $(member_role).parents('._team-member').hide(500)
          } else {
            member_role.remove()
          }
          $('[data-tab=team] .count').text(data.count_members);
        });
      }
      e.preventDefault();
    });
}

function initializeDeleteNotificationsControls() {
    $('.delete-notification').click(function(e) {
        $.ajax({
            type: 'DELETE',
            url: "/notifications/" + $(this).attr('notification-id'),
        }).done(function(data) {
            $("#notification-" + data).html("Removed");
        }).fail(function(data) {
            console.log(data);
        });
    });
}

function initializeAdminRequestControls() {
    $('form.new_admin_request').submit(function (e) {
        e.preventDefault();
        $.ajax({
            type: $(this).attr('method'),
            url: $(this).attr('action'),
            data: $(this).serialize()
        }).done(function (data) {
            $("#admin-request").hide();
        }).fail(function (data) {
            console.log(data);
        });
    });
}

function initializeInvitationsControls() {
    initializeNotificationFormControl("form.reject-invitation", "div#invitation-");
    initializeNotificationFormControl("form.accept-invitation", "div#invitation-");
}

function initializeRequestsControls() {
    initializeNotificationFormControl("form.reject-request", "div#request-");
    initializeNotificationFormControl("form.accept-request", "div#request-");
}

function initializeNotificationFormControl(formSelector, formParentSelector) {
    $(formSelector).submit(function(e) {
        e.preventDefault();
        $.ajax({
            type: "post",
            url: $(this).attr('action')
        }).done(function(data) {
            $(formParentSelector + data).hide();
        }).fail(function(data) {
            console.log(data);
        });
    });
}

function initializeTaskMemberDeleteControls() {
    $('.delete-task-member').click(function(e) {
        if (confirm("Are you sure?")) {
            $.ajax({
                type: 'DELETE',
                url: "/tasks/" + $('#task-members-container').attr('task-id') + "/members/" + $(this).attr('task-membership-id'),
            }).done(function(data) {
                $("#task-membership-" + data).hide(500);
            }).fail(function(data) {
                console.log(data);
            });
        }
    });
}
