# During restart, newly enabled or disabled plugins may modify topbar menu. For this reason,
# cache is invalidated for all users. This will work for the default cache provider (files)
# but might not work with other providers (memcached). On these installations, users need
# to logout and re-login in order to update the top menu.

TopbarSweeper.expire_cache_all_users
