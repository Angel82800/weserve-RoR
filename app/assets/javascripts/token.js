function showError(error) {
  $('.alert-box').css({ display: 'block' });
  $('.alert-box').removeClass('_hidden');
  $('.alert-box span').text(error);
}

function generateToken (stripe, args) {
  stripe.createToken('account', args).then(function(data) {
    result = data;
    if (result.token) {
      document.querySelector('#token').value = result.token.id;
      document.querySelector('.payout-form').submit();
    }
    else {
      showError(result.error.message);
    }
  });
}

function createToken(pk_key_stripe) {
  var stripe = Stripe(pk_key_stripe);
  const payoutForm = document.querySelector('.payout-form');
  payoutForm.addEventListener('submit', getToken);

  function getToken(event) {
    event.preventDefault();
    var result;
    result = getAgrumentsToken(stripe, generateToken);
  }
}

function getAgrumentsToken(stripe, callback) {
  var legal_document = document.querySelector("#legal_document");
  var agrumentsToken;
  if (legal_document) {
    agrumentsToken = createAgrumentsForUpdate();
    var documentData = new FormData();
    documentData.append('file', legal_document.files[0]);
    documentData.append('purpose', 'identity_document');
    $.ajax({
      type: 'POST',
      url: 'https://uploads.stripe.com/v1/files',
      headers: {"Authorization": "Bearer " + stripe._apiKey},
      processData: false,
      contentType: false,
      data: documentData
    }).success(function(data) {
      agrumentsToken["legal_entity"]["verification"]["document"] = data.id;
      return callback(stripe, agrumentsToken);
    })
  }
  else {
    agrumentsToken = createAgrumentsForNew();
    return callback(stripe, agrumentsToken);
  }
}

function createAgrumentsForUpdate() {
  var personal_id = document.querySelector("#personal_id") ? document.querySelector("#personal_id").value : '';
  var agrumentsToken = {
    legal_entity: {
      personal_id_number: personal_id,
      verification: {
        document: ""
      }
    }
  };
  return agrumentsToken;
}

function createAgrumentsForNew() {
  var dob = document.querySelector('#dob').value.split("-"),
      last_4_ssn = document.querySelector('#last_4_ssn');
  var agrumentsToken = {
    legal_entity: {
      first_name: document.querySelector('#first_name').value,
      last_name: document.querySelector('#last_name').value,
      type: "individual"
    },
    tos_shown_and_accepted: true
  };
  if (last_4_ssn) {
    agrumentsToken["legal_entity"]["ssn_last_4"] = last_4_ssn.value;
  }
  agrumentsToken["legal_entity"]["address"] = getAddress();
  agrumentsToken["legal_entity"]["dob"] = getDOB(dob);
  return agrumentsToken;
}

function getDOB(dob) {
  var day_of_birth = {
    year: Number(dob[0]),
    month: Number(dob[1]),
    day: Number(dob[2])
  }
  return day_of_birth;
}

function getAddress() {
  var address = {
    line1: document.querySelector('#address').value,
    city: document.querySelector('#city').value,
    state: document.querySelector('#state').value,
    postal_code: document.querySelector('#postal_code').value
  };
  return address;
}
