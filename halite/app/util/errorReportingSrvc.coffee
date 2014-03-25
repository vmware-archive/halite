###
Service to handle operations related to displayig errors on the UI.

Maintains a list of all alerts. Exposes methods that add to and remove
items from that list.

Call ErrorReporter.getAlerts() to get the whole list of alerts.
ErrorReporter.removeAlert(0) removes the 0th alert from alerts.
Use ErrorReporter.addAlert() to add an alert.

The console page makes use of this service.
###
angular.module("errorReportingSrvc", ['appUtilSrvc']).factory "ErrorReporter", () ->

    alerts = []
    servicer =
      addAlert: (type = 'info', msg = 'Error message!') ->
        alerts.push({'type': type, 'msg': msg})
        return
      removeAlert: (index) ->
        alerts.splice(index, 1)
        return
      getAlerts: () ->
        return alerts
    return servicer
