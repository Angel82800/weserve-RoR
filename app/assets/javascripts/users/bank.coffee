$(document).ready ($) ->

  selectPayoutMethod = (country) ->
    $('#bank-account, #bank-routing').val('')

    if country.val() == 'US'
      $('#bank-form .payout label').text('Checking Bank Account Number')
      $('#bank-routing').attr('required', 'required')
      $('#bank-form .payout-for-us').show()
    else
      $('#bank-form .payout label').text('IBAN')
      $('#bank-routing').removeAttr('required')
      $('#bank-form .payout-for-us').hide()

  $('#country, #state').on 'change', ->
    selectPayoutMethod $(this)
