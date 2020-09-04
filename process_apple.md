----------------------------------------
Processing:

- clean columns:
    - drop unnecessary columns

- parse data:
    - parse dates and integers (versions not yet - there's some garbage)
    - map actions (1, 1F, ...) to human-readable strings

- remove garbage data:
    - drop rows with garbage (or irrelevant) data
    - drop columns that were only necessary to find garbage

- output:
    - parse version (garbage is gone)
    - date -> year
    - country -> region
    - sum and pivot on units per version

----------------------------------------
Most S_*.txt files have 28 columns:

Provider: APPLE
    ignore

Provider Country: US
    ignore

SKU: de.kirchentag.GlaesernesRestaurant (sometimes with space at end)
    ignore

Developer: Christopher Sahnwaldt (six lines with Christopher Sahnwald in S_Y_2016)
    ignore

Title: Gläsernes Restaurant (sometimes with space at end)
    ignore

Version: 1.1, 1.2, 1.2.1, 1.4, 1.5, 1.6, 1.6.6, 1.6.7
    garbage: 'N/A', ' ', '5.0', '6.2'; each occurs only once
    5.0: 1F, 2016, IE, Desktop, 1 unit
    6.2: 1F, 2016, ES, Desktop, 1 unit
    N/A: 3F, 2019-11-22, DE, iPhone, 1 unit
    ' ': 3F, 2017, CH, iPad, 1 unit
    use to calculate total installs by version and year

Product Type Identifier: 1, 1F, 3, 3F, 7, 7F
    see https://help.apple.com/app-store-connect/#/dev63c6f4502
    or https://help.apple.com/app-store-connect/en.lproj/static.html#dev63c6f4502
    ignore updates and re-installs, only calculate new installs

Units: never empty, always valid integer > 0 and < 1000
    garbage: 2488 (China, 2017), 1201 (Desktop, CH, 2016)
    use to calculate total installs by version and year

Developer Proceeds: 0, 0.00
    ignore

Begin Date, End Date: all rows in a file have same value, format MM/DD/YYYY
    use to calculate total installs by version and year

Customer Currency: EUR, CHF, many others
    irrelevant, almost all countries have only one currency (only BR has BRL and USD)

Country Code: DE, CH, AT, LU, many others
    delete CN - contains lots of garbage, especially for 2017
    otherwise ignore, include all countries, numbers for non-DACH are negligible

Currency of Proceeds: EUR, CHF, many others
    sometimes empty, otherwise same as Customer Currency
    ignore

Apple Identifier: 731041234
    ignore

Customer Price: 0, 0.00
    ignore

Promo Code:
    EDU in two lines, but device is Desktop - delete
    otherwise empty, ignore

Parent Identifier: empty
    ignore

Subscription: empty
    ignore

Period: empty
    ignore

Category: Food & Drink
    ignore

CMB: nil
    ignore

Device: iPhone, iPad, iPod touch
    garbage, delete: Desktop
    otherwise ignore

Supported Platforms: iOS, sometimes empty
    ignore

Proceeds Reason: empty
    ignore

Preserved Pricing: empty
    ignore

Client: empty
    ignore

Order Type: empty
    ignore

----------------------------------------
Some S_*.txt files have fewer columns:

S_Y_2013 has 21 columns
CMB+ are missing

S_Y_2014 has 22 columns
Device+ are missing

S_Y_2015 has 24 columns
Proceeds Reason+ are missing
Device is often empty
