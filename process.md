----------------------------------------
Main idea:

Calculate number of new installs by version, year and total.

----------------------------------------
Previous approaches:

I initially thought it would be interesting to calculate how often an app
version was installed, so I added up install and update counts. But that
makes it impossible to calculate meaningful totals for all versions and
years, so I later dropped the update counts. This means that we only see
the new installs for each version, but we can easily calculate sums for
multiple version or years.

For Google, I initially used the larger number of 'Daily Device Installs'
and 'Install events', but I later learned that 'Install events' includes
devices that had the app installed earlier, so I dropped 'Install events'.
