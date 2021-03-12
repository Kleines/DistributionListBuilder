# DistributionListBuilder

This has been created to speed the creation of M365 distribution lists while performing some error checking along the way. It creates the email addresss and defaults the DL manager to the person running the script.

The common errors it checks for:

* Distribution list name exists
* Distribution list email is in use
* Manager email address is valid
* Manager email address is in the domain

It then creates the DL.
