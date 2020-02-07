# Configure "min" to be the minimum number of threads to use to answer
# requests and "max" the maximum.
#
# The default is "0, 16".
#
threads ENV.fetch('FOREMAN_PUMA_THREADS_MIN', 0).to_i, ENV.fetch('FOREMAN_PUMA_THREADS_MAX', 16).to_i

# === Cluster mode ===

# How many worker processes to run.
#
# The default is "0" for puma. Recommending "2" for foreman
#
workers ENV.fetch('FOREMAN_PUMA_WORKERS', 2).to_i
