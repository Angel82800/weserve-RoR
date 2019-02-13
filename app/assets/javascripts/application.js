// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.jcrop
//= require jquery_ujs
//= require autocomplete-rails
//= require jquery.remotipart
//= require best_in_place
//= require foundation
//= require chosen-jquery
//= require tinymce-jquery
//= require social-share-button
//= require react
//= require react_ujs
//= require components
//= require zeroclipboard
//= require jquery-ui
//= require jquery.validate.min
//= require jquery.slimscroll
//= require cocoon
//= require bootstrap-sprockets
//= require jquery.slick
//= require underscore-min
//= require moment
//= require bootstrap-datetimepicker
//= require toastr

//= require_tree .

function fetchUrlGetParam(k) {
   var p = {};
   location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi,function(s,k,v){p[k]=v});
   return k?p[k]:p;
}

var $document = $(document);
var $html = $('html');
$document.foundation();

$document.on('page:load', function () {
    $document.foundation();
});

$(function () {
    $('img').one('error', function () {
        this.src = '/assets/no_image.png';
    });
    $('.task-box').matchHeight();
    $document.foundation();
});

$(function () {
    $('.task-box').matchHeight();
});


function setLocation(url) {
    if (LanguageModule.isLanguageSet()) {
        window.history.pushState(null, null, window.location.pathname + url + '&locale=' + LanguageModule.getCurrentLanguage());
    } else {
        window.history.pushState(null, null, window.location.pathname + url);
    }
}
window.onpopstate = function(event) {
    if($("#myModal").css("display") === "block") {
      $("#task-popup-close").trigger("click");
    }
    if (fetchUrlGetParam('tab')) {
      $('[data-tab="' + tab + '"]').trigger('click');
    }
};

var DateTimePickerModule = (function () {
    function bindEvents() {
        var DAY_TO_DEADLINE = 89,
            currentDate = new Date(),
            deadlineDate = new Date().setDate(currentDate.getDate() + DAY_TO_DEADLINE);
        $('.deadline_picker').each(function(i, v) {
          try {
            var deadline_picker_value = $(v).find("#input-task-deadline").val();
            $(v).datetimepicker({
                viewMode: 'months',
                format: 'YYYY-MM-DD',
                minDate: currentDate,
                maxDate: deadlineDate
            });
            if(deadline_picker_value) {
              var deadline_picker_value_unix = parseInt((new Date(deadline_picker_value).getTime() / 1000).toFixed(0), 10); // seconds
              var current_date_unix = parseInt((new Date().getTime() / 1000).toFixed(0), 10);
              if(deadline_picker_value_unix < current_date_unix) {
                var days_diff = Math.floor((current_date_unix - deadline_picker_value_unix) / (3600*24));
                if(days_diff < 0) days_diff = 0;
                var new_day_till_deadline = DAY_TO_DEADLINE + days_diff;
                var new_min_date = new Date(deadline_picker_value_unix * 1000).toISOString();
                var new_max_data = new Date(deadline_picker_value_unix * 1000).setDate(new Date(deadline_picker_value_unix * 1000).getDate() + new_day_till_deadline);
                new_max_data = new Date(new_max_data).toISOString();
                $(v).data('DateTimePicker').minDate(new_min_date);
                $(v).data('DateTimePicker').maxDate(new_max_data);
              }
              $(v).data('DateTimePicker').defaultDate(new Date(deadline_picker_value_unix * 1000).toISOString());
            }
          } catch(e) { console.log(e); }
        })
    }
    return {
        init: function ($document) {
            bindEvents($document);
        }
    };
})();


var DateTimePickerModuleDOB = (function () {

    function bindEvents() {

        $('.dob_picker').datetimepicker({
            viewMode: 'months',
            format: 'YYYY-MM-DD'
        });
    }

    return {
        init: function ($document) {
            bindEvents($document);
        }
    };
})();


var TabsModule = (function () {

    function setBoard(boardId) {
        var board = $('[data-board-id="' + boardId + '"]').click();
        if(board.length > 0) {
            board.click();
            return;
        }
        else {
            setTimeout(function() {
                setBoard(boardId);
            }, 100);
        }
    }

    function bindEvents($document) {
        $document
            .on('click.changeTab', '[data-tab].tablinks.m-tabs__link', function (e) {
                e.preventDefault();
                e.stopPropagation();
                var $that = $(this), taskId, boardId,
                $html = $('html'),
                    tab = $that.data('tab'),
                    paramsArr = window.location.search.slice(1).split('&');
                UrlModule.setTab(tab);
                $document.find('.tabcontent').hide();
                $document.find('[data-tab].tablinks.m-tabs__link').removeClass('active');
                $('.tabs-wrapper__' + tab).show();
                $that.addClass('active');
                $('#sourceEditor').hide();
                tab === "team" ? $('.get-invo-btn').show() : $('.get-invo-btn').hide();
                paramsArr.map(function (item) {
                    if (item.indexOf('taskId=') === 0) {
                        taskId = item.split('=')[1];
                    }
                    if (item.indexOf('board=') === 0) {
                        boardId = item.split('=')[1];
                    }
                });

                if ($html.hasClass('_open-modal')) {
                    $('#welcomeToTeamModal').fadeOut(300);
                    setTimeout(function () {
                        $html.removeClass('_open-modal');
                        if ($that.data('tab') === 'tasks') {
                            $('#tab-tasks').addClass('active');
                        } else {
                            $('#tab-plan').addClass('active');
                        }
                    }, 300)
                }

                if (tab === 'tasks' && boardId !== undefined) {
                    tab = 'tasks&board=' + boardId;
                    setBoard(boardId);
                }

                var tab_url = '?tab=' + (taskId ? 'Tasks&taskId=' + taskId : tab);
                if (e.type === 'click' && !e.isTrigger) {
                    setLocation(tab_url);
                }
            })

        .on('click.changeTab', '.board-tab', function (e) {
            var board_id = $(this).data('board-id');
            var board_url = '?tab=tasks&board=' + board_id;
            if (e.type === 'click' && !e.isTrigger) {
                setLocation(board_url);
            }
        });
    }

    return {
        init: function ($document) {
            bindEvents($document);
        }
    };
})();

var RevisionModule = (function () {
    function bindEvents($document) {
        $document
            .on('click.blockUser', '.revision-status-btn', function (e) {
                e.preventDefault();

                var $that = $(this),
                    projectId = $that.data('project-id'),
                    username = $that.data('username'),
                    url = LanguageModule.isLanguageSet() ? '/projects/' + projectId + ($that.hasClass('_block-user') ? '/block_user?username=' : '/unblock_user?username=') + username :
                        '/projects/' + projectId + ($that.hasClass('_block-user') ? '/block_user?username=' : '/unblock_user?username=') + username + '&locale=' + LanguageModule.getCurrentLanguage();

                sessionStorage.setItem('revisionBlockOpen', JSON.stringify(true));

                window.location.assign(window.location.origin + url);
            })
    }

    function checkVisibilityRevisionBlock() {
        if (JSON.parse(sessionStorage.getItem('revisionBlockOpen'))) {
            setTimeout(function () {
                $('#editSource').click();
            });
            sessionStorage.removeItem('revisionBlockOpen');
        }
    }

    return {
        init: function ($document) {
            bindEvents($document);
            checkVisibilityRevisionBlock();
        }
    };
})();

var ModalsModule = (function () {

    var modalsArr = ["#team", "#suggested_task_popup", "#myModal2", ".modal-default", "#popup-for-free-paid", "#modalVerification", "#registerModal"]; // todo try to remove this
    var _scope = null;

    function openModal(modalSelector) {
        $(modalSelector).fadeIn();
        $html.addClass('_open-modal');
    }

    function _clearScope() {
        _scope = null;
    }

    function togglePreloader(isShow) {
        if (typeof(isShow) === "boolean") {
            return isShow ? $('#loading-mask1').show() : $('#loading-mask1').hide();
        }
        $('#loading-mask1').fadeToggle();
    }

    function bindEvents($document) {
        $document
            .on('click.openModal', '[data-modal]', function (e) {
                e.preventDefault();
                e.stopPropagation();

                var modal = $($(this).data('modal')),
                    modalScope = $(this).data('modalScope');

                if (modal.selector === '#registerModal') {
                    $('.alert-box.alert').hide();
                }

                modal.fadeIn();
                _scope = modalScope;
                $html.addClass('_open-modal');
            })
            .on('click.closeModalByOverlay', '.modal-default', function (e) {
                if (e.target !== this) return;
                $(this).fadeOut();
                $html.removeClass('_open-modal');
            })
            .on('click.closeModalByCloseBtn', '.modal-default__close, [data-modal-close]', function (e) {
                var hideModal = true;
                $(this).closest('.modal-default').fadeOut(400, function () {
                    $('.modal-default').each(function (index, element) {
                        if ($(element).is(':visible')) {
                            hideModal = false;
                        }
                    });

                    if (hideModal) {
                        $html.removeClass('_open-modal');
                    }
                });

            })
            .on('click.closeTaskModalByBtn', '#task-popup-close', function (e) {
                UrlModule.closeTaskModal();
            })
            .on('click.closeTaskModalByOverlay', '#myModal', function (e) {
                if (e.target === this) UrlModule.closeTaskModal();
            })
            .on('keydown.closeModals', function (e) {
                if (e.keyCode === 27) {  // todo rewrite when be removed modalsArr
                    for (var i = 0, max = modalsArr.length; i < max; i++) {
                        $(modalsArr[i]).fadeOut();
                    }
                    $('.modal-backdrop').remove();
                    $html.removeClass('_open-modal');
                }
            });
    }

    return {
        init: function ($document) {
            bindEvents($document);
        },
        openModal: function (modalSelector) {
            openModal(modalSelector);
        },
        clearScope: _clearScope,
        togglePreloader: function (isShow) {
            togglePreloader(isShow);
        },
        getScope: function () {
            return _scope
        }
    };
})();

var LanguageModule = (function () {

    function _insertCurrentFlag(svg) {
        $('.s-header__lang-select').html(svg);
    }

    function _getCurrentSvgFlag(flagName) {
        return '' +
            '<svg focusable="false" version="1.1" class="svg-' + flagName + '-flag" aria-hidden="true" style="position: relative;z-index:-1;">' +
            '<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#svg-' + flagName + '-flag"></use>' +
            '</svg>'
    }

    function _getCurrentLanguage() {
      var arr_locale = location.href.split('locale=');
      return (arr_locale.length > 1) ? arr_locale[1] : 'en';
    }

    function _isLanguageSet() {
        return location.href.indexOf('locale=') >= 0;
    }

    function _setUserSelectedLanguage(lang) {
        switch (lang.split('&')[0]) {
            case 'en':
                _insertCurrentFlag(_getCurrentSvgFlag('usa'));
                break;
            case 'es':
                _insertCurrentFlag(_getCurrentSvgFlag('spain'));
                break;
            case 'pt':
                _insertCurrentFlag(_getCurrentSvgFlag('portugal'));
                break;
            case 'fr':
                _insertCurrentFlag(_getCurrentSvgFlag('france'));
                break;
            default:
                _insertCurrentFlag(_getCurrentSvgFlag('usa'));
                break;
        }
    }

    function bindEvents() {
    }

    return {
        init: function () {
            bindEvents();
        },
        setUserSelectedLanguage: _setUserSelectedLanguage,
        isLanguageSet: _isLanguageSet,
        getCurrentLanguage: _getCurrentLanguage
    }
})();

var ProjectAndTaskSearchModule = (function () {
    function bindEvents($document) {
        $document
            .on('input.userSearch', '#userSearchTasksAndProject', $.debounce(250, function () {
                var $this = $('#userSearchTasksAndProject'),
                    searchValue = $this.val(),
                    $searchResultsList = $('.search-result__list');

                $.ajax({
                    url: '/projects/autocomplete_user_search?term=' + searchValue,
                    type: 'GET',
                    dataType: 'html',
                    success: function (response) {
                        $searchResultsList.html(response);
                    }
                })
            }))
    }

    return {
        init: function ($document) {
            bindEvents($document);
        }
    }
})();

var UrlModule = (function () {

    var paramsArr, taskId, boardId, isAlreadyCheckedTaskModal, isAlreadyCheckedTab, isAlreadyCheckedBoard, tab,
        isCardClicked, isBoardClicked;

    function bindEvents($document) {
        $document
            .on('click.changeUrlTaskModal', '.pr-card', function () {
                if (isCardClicked) return;
                var taskId = $(this).data('taskId');
                var boardId = $(this).data('task-board-id');

                ModalsModule.togglePreloader(true);
                $('[data-board-id="' + boardId + '"]').click();
                var modal_url = '?tab=' + tab + '&board=' + boardId + '&taskId=' + taskId;
                setLocation(modal_url);
                isCardClicked = true;
            });
    }

    function checkIsCardClicked() {
        return isCardClicked;
    }

    function checkIsBoardClicked() {
        return isBoardClicked;
    }

    function enableCardClick() {
        isCardClicked = false;
    }

    function getTaskParam() {
        return taskId;
    }

    function getBoardParam() {
        return boardId;
    }

    function setTab(newTab) {
        tab = newTab;
    }

    function closeTaskModal() {
        var close_modal_url = '?tab=' + tab;
        setLocation(close_modal_url);
        boardId = null;
        taskId = null;
    }

    function checkBoard() {
        for (var i = 0; i < paramsArr.length; i++) {
            if (paramsArr[i].indexOf('boardId=') === 0) {
                boardId = paramsArr[i].split('=')[1];

                $('a[data-boardid="' + boardId + '"]').click();
                break;
            }
        }
        isAlreadyCheckedBoard = true;
    }

    function checkTaskModal() {
        if (isAlreadyCheckedTaskModal) return;
        for (var i = 0; i < paramsArr.length; i++) {
            if (paramsArr[i].indexOf('taskId=') === 0) {
                if (isCardClicked) return;
                taskId = paramsArr[i].split('=')[1];
                ModalsModule.togglePreloader(true);
                $('[data-task-id="' + taskId + '"]').trigger('click');
                break;
            }
        }
        isAlreadyCheckedTaskModal = true;
    }

    function checkTabModal() {
        if (isAlreadyCheckedTab) return;
        for (var i = 0; i < paramsArr.length; i++) {
            if (paramsArr[i].indexOf('tab=') === 0) {
                tab = paramsArr[i].split('=')[1];
                $('[data-tab="' + tab + '"]').trigger('click');
                break;
            }
        }
        if (!tab) $('[data-tab="tasks"]').trigger('click');
        isAlreadyCheckedTab = true;
    }

    function checkUrl() {
        paramsArr = window.location.search.slice(1).split('&');
        checkTabModal();
        checkBoard();
        checkTaskModal();
    }

    return {
        init: function ($document) {
            bindEvents($document);
            setTimeout(function () {
                checkUrl();
            }, 0);
        },
        checkUrl: function () {
            checkUrl();
        },
        getTaskParam: function () {
            return getTaskParam();
        },
        getBoardParam: function () {
            return getBoardParam();
        },
        closeTaskModal: function () {
            closeTaskModal();
        },
        setTab: function (tab) {
            setTab(tab);
        },
        enableCardClick: function () {
            enableCardClick();
        },
        checkIsCardClicked: function () {
            return checkIsCardClicked();
        },
        checkIsBoardClicked: function () {
            return checkIsBoardClicked();
        }
    };
})();

var ModalAgreement = (function () {
    var $modalAgreement = null,
        $modalAgreementTitle = null,
        $modalAgreementSubtitle = null,
        $modalAgreementAgreeBtn = null,
        $modalAgreementRefuseBtn = null;

    function bindEvents() {
        $modalAgreement = $('.modal-agreement');
        $modalAgreementTitle = $modalAgreement.find('.modal-agreement__title');
        $modalAgreementSubtitle = $modalAgreement.find('.modal-agreement__subtitle');
        $modalAgreementAgreeBtn = $modalAgreement.find('.btn-root._agree');
        $modalAgreementRefuseBtn = $modalAgreement.find('.btn-root._refuse');

        $modalAgreement
            .on('click.clearAgreementModal', '.modal-default__close', function () {
                setTimeout(function () {
                    removeTitles();
                    unbindEventsOnClose();
                }, 300);
            })
    }

    function unbindEventsOnClose() {
        $modalAgreementAgreeBtn.off('click.submit');
        $modalAgreementRefuseBtn.off('click.close');
    }

    function removeTitles() {
        $modalAgreement.find('.modal-agreement__title').text('');
        $modalAgreement.find('.modal-agreement__subtitle').text('');
    }

    function bindEventsOnOpenModal(agreeCallback, refuseCallback, extraArgs) {
        $modalAgreementAgreeBtn.on('click.submit', function () {
            agreeCallback(extraArgs);
        });
        if (refuseCallback) {
            $modalAgreementRefuseBtn.on('click.close', function () {
                refuseCallback(extraArgs);
            });
        }
    }

    function setTitles(title, subtitle) {
        $modalAgreement.find('.modal-agreement__title').text(title);
        $modalAgreement.find('.modal-agreement__subtitle').text(subtitle);
    }

    function openModal(options) { // options { title, subtitle, agreeCallback, refuseCallback, extraArgs }
        setTitles(options.title, options.subtitle);
        bindEventsOnOpenModal(options.agreeCallback, options.refuseCallback, options.extraArgs);
        $modalAgreement.fadeIn();
    }

    function closeModal() {
        $modalAgreement.fadeOut(function () {
            removeTitles();
            unbindEventsOnClose();
        });
    }

    return {
        init: function () {
            bindEvents();
        },
        openModal: openModal,
        closeModal: closeModal
    }
})();

var ModalResponse = (function () {
    var $modalResponse = null;

    function bindEvents() {
        $modalResponse = $('.modal-response');

        $modalResponse
            .on('click.clearResponseModal', '.modal-default__close', function () {
                setTimeout(function () {
                    $modalResponse.find('.modal-response__title').text('');
                    $modalResponse.removeClass('_error');
                }, 300);
            })

    }

    return {
        init: function () {
            bindEvents();
        },
        showMessage: function (message, isError) {
            $modalResponse.fadeIn();
            $modalResponse.find('.modal-response__title').text(message);
            if (isError) {
                $modalResponse.addClass('_error');
            }
        }
    }
})();

var parseBrToLine = function (text) {
    var regex = /<br\s*[\/]?>/gi;
    return text.replace(regex, "\n");
}

var convertLineToBr = function (text) {
  var regex = /\n\r?/g;
  return text.replace(regex, '<br />');
}


$document.ready(function () {
    $(".best_in_place").best_in_place();

    ModalAgreement.init();
    ModalResponse.init($document);
    ProjectAndTaskSearchModule.init($document);
    DateTimePickerModule.init($document);
    DateTimePickerModuleDOB.init($document);
    UrlModule.init($document);
    LanguageModule.init($document);
    ModalsModule.init($document);
    TabsModule.init($document);
    RevisionModule.init($document);
});
