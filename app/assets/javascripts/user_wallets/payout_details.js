'use strict';

$(document).ready(function($) {
  var transaction_id = $('.s-wallet #wallet-transaction_id').val();
  if (transaction_id)
    window.location = "/download_tax_receipt/" + transaction_id + ".pdf";

  $('#country, #state').on('change', function () {
    updateSelectedData($(this));
  });

  //  to set selects values if we have the data
  if($('#country').val() !== '') {
    updateSelectedData($('#country'));
  }

  function updateSelectedData(input) {
    var data;
    var field;

    // remove/add ability to change follow select
    disableEnableSelects(input.attr('id'));

    if(input.attr('id') === 'country'){
      data = input.serialize();
      field = 'state';
    }
    else{
      data = input.serialize() + '&country=' + $('#country').val();
      field = 'city';
    }
    $.ajax({
      url: '/users/state',
      type: 'get',
      data: data
    }).done(function (data) {
      changeSelect(data, field);
    });
  }

  function changeSelect(data, field) {
    // clean old values
    emptySelects(field);

    $.each( data, function( i, val ) {
      if (field === 'city'){
        i = val
      }
      $("#" + field).append($("<option></option>").attr("value", i).text(val));
    });
    if($('#' + field + '_value').val() !== '') {
      selectOption(field);
    }
  }

  function selectOption(field) {
    var existing_field = $('#' + field + '_value');
    $('#'+ field +' option[value="' + existing_field.val() + '"]').prop('selected', true);

    if(field === 'state') {
      updateSelectedData($('#state'));
    }

    // clean field value
    existing_field.attr('value', '');
  }

  function emptySelects(field) {
    $('#' + field).empty();
    if (field === 'state') {
      $('#city').empty();
      setZeroOption('city')
    }
    setZeroOption(field);
  }

  function setZeroOption(field) {
    $("#" + field).append($("<option></option>").attr('value', '').text('--Select ' + field + '--'));
  }

  function disableEnableSelects (field) {
    if (field === 'country') {
      var isCountryEmpty = Boolean($('#country').val());

      $('#state').prop('disabled', !isCountryEmpty);
      $('#city').prop('disabled', true);
    } else if (field === 'state') {
      $('#city').prop('disabled', false);
    }
  }

  // related with country
  $('#country').on('change', function(){
    if($('#country').val() === 'US') {
      $('#us-snn').append("<label>Last 4 digits of your SSN</label> <input type='text' class='form-control' id='last_4_ssn' name='last_4_ssn' placeholder='1234' maxlength='4' required='required'/>");
    } else {
      $('#us-snn').empty();
    }
  })

});
