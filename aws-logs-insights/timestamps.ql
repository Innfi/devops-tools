fields @timestamp, @message
| fields tomillis(@timestamp) as millis
| filter millis >= 1739196000000 and millis < 1739282400000
| sort @timestamp desc
| limit 200

// is it valid to add timestamp filter in ql????
// filter millis >= 1739196000000: working
// filter millis >= 1739196000000 and millis < 1739282400000: not working
// filter millies >= tomillis('2026-02-11T00:00:00Z'): not working
