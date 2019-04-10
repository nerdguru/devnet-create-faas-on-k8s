createPath = 'https://10.10.20.208:31001/api/v1/web/guest/default/guestbook-dev-create.json'; // Path to create API endpoint
listPath = 'https://10.10.20.208:31001/api/v1/web/guest/default/guestbook-dev-list.json'; // Path to list API endpoint

// Make List call and render current lst
function getAndRenderMsg() {
  console.log('Trying: ' + listPath);
  $.ajax({
    type: 'GET',
    url: listPath,
    crossDomain: true,
    success: function (resp) {
      var response = resp;
      if (typeof resp == 'string') // String or obj return?
        response = JSON.parse(resp);
      console.log('Response: ' + JSON.stringify(response, null, 2));
      var messageString = '';
      for (var i = 0; i < response.entries.length; i++) {
        messageString += '<div>' + response.entries[i].text + '</div>\n';
      }

      document.getElementById('messages').innerHTML = messageString;
    },
  });
}

function createMsg() {
  var inputMessage = document.getElementById('inputMessage').value;
  console.log('inputMessage: ' + inputMessage);
  $.ajax({
      type: 'POST',
      url: createPath,
      contentType: 'application/json',
      dataType: 'json',
      data: '{"text":"' + inputMessage + '"}',
      crossDomain: true,
      success: function (response) {
        console.log('Response: ' + JSON.stringify(response, null, 2));
        document.getElementById('inputMessage').innerHTML = '';
        getAndRenderMsg();
      },
    });
}

// Upon the submit buttong being created, make Create call, then List
$('#submitEntry').on('click', function () {
  createMsg();
});

$('#guestForm').submit(function(event){
  event.preventDefault();
  createMsg();
});

// Start the page load with the List call
getAndRenderMsg();
