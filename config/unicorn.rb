worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)

timeout 120
preload_app true
