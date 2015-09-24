Delayed::Worker.max_attempts = 10 # High max attempts because we are not using workless
Delayed::Worker.max_run_time = 1.hour
