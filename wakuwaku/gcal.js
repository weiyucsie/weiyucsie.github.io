function initGoogleCalendarClient(CLIENT_ID, updateSigninStatus) {
  var DISCOVERY_DOCS = ["https://www.googleapis.com/discovery/v1/apis/calendar/v3/rest"];
  var SCOPES = "https://www.googleapis.com/auth/calendar";

  gapi.client.init({
    discoveryDocs: DISCOVERY_DOCS,
    clientId: CLIENT_ID,
    scope: SCOPES
  }).then(function() {
    if (updateSigninStatus) {
      gapi.auth2.getAuthInstance().isSignedIn.listen(updateSigninStatus);

      updateSigninStatus(gapi.auth2.getAuthInstance().isSignedIn.get());
    }
  });
}

function createMyGoogleCalendarListElement() {
  var MyCalendarElement = document.createElement('select');

  gapi.client.calendar.calendarList.list().then(function(response) {
    response.result.items.forEach(function(item) {
      var option = document.createElement('option');
      option.text = item.summary;
      option.value = item.id;
      option.selected = ('primary' in item) && item.primary;

      MyCalendarElement.add(option);
    });
  });

  return MyCalendarElement;
}
