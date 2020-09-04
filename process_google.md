Processing:

- clean columns:
    - drop unnecessary columns

- parse data:
    - parse dates, versions and integers

- output:
    - date -> year
    - country -> region
    - sum and pivot on units per version

----------------------------------------
Most stats/installs/installs_*.csv files have the following columns:

- Date: date, format YYYY-MM-DD
    - use to calculate total installs by version and year

- Package Name: de.kirchentag.glaesernes_restaurant
    - ignore

- Country: DE, AT etc.
    - only in stats/installs/installs_*_country.csv
    - ignore, include all countries, numbers for non-DACH are negligible

- App Version Code: 1, 2, 15, 1005002, 1006007 etc.
    - only in stats/installs/installs_*_app_version.csv
    - See google_versions.txt
    - use to calculate total installs by version and year

- Current Device Installs:
    - includes devices that were last active up until several months ago
    - dropped on 2016-12-01, see https://support.google.com/googleplay/android-developer/answer/7003402#active_devices
    - ignore, Apple doesn't provide similar information

- Daily Device Installs:
    - \>0 on ~80% of days
    - use to calculate total installs by version and year

- Daily Device Uninstalls:
    - \>0 on ~70% of days until 2019-07-28
    - 0 since 2019-07-29
    - Question about 0 values without answer: https://support.google.com/googleplay/thread/25947807
    - ignore, Apple doesn't provide similar information

- Daily Device Upgrades:
    - \>0 on ~10% of days until 2019-07-28
    - 0 since 2019-07-29
    - ignore, only calculate new installs

- Current User Installs:
    - includes devices that were last active up until several months ago
    - dropped on 2016-12-01, see https://support.google.com/googleplay/android-developer/answer/7003402#active_devices
    - ignore, Apple doesn't provide similar information

- Total User Installs:
    - sum of Daily User Installs (including current row)
    - 0 since 2018-07-17
    - see https://support.google.com/googleplay/android-developer/answer/7003402#cumulative_installs
    - and https://stackoverflow.com/questions/51379013/google-play-store-can-no-longer-see-total-installs
    - ignore / recalculate, Apple doesn't provide similar information

- Daily User Installs:
    - ignore, Apple doesn't provide similar information

- Daily User Uninstalls:
    - ignore, Apple doesn't provide similar information

- Active Device Installs:
    - added on 2016-09-01, see https://support.google.com/googleplay/android-developer/answer/7003402#active_devices
    - number of devices that have app installed and have been online at least once in the past 30 days
    - ignore, changes in unpredictable ways

- Install events:
    - added on 2017-11-01
    - similar (but often not equal) to Daily Device Installs
    - includes devices that had the app installed previously
    - ignore, only calculate new installs

- Update events:
    - added on 2017-11-01
    - similar (but often not equal) to Daily Device Upgrades
    - ignore, only calculate new installs

- Uninstall events
    - added on 2017-11-01
    - similar (but often not equal) to Daily Device Uninstalls
    - ignore, Apple doesn't provide similar information

----------------------------------------
- May also be interesting:
    - https://support.google.com/googleplay/android-developer/answer/139628
    - https://support.google.com/googleplay/android-developer/answer/6135870
    - https://support.google.com/googleplay/android-developer/answer/7383463
    - https://support.google.com/googleplay/android-developer/answer/9419939
