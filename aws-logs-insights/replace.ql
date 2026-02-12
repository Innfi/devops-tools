fields @timestamp, replace(replace(log, "stdout F", ""), "stderr F ", "") as cleanLog
| limit 20
