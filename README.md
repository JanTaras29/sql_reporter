## What this is?

This is a gem that can be used for comparing sql_tracker reports for different branches.

## Setup

Simply run the following in terminal while in the repo directory (temporary solution while not in rubygems.org)
```
gem build sql_reporter.gemspec
gem install sql_reporter
```

or if you are using Bundler
```
bundle
```

## Usage

`sql_reporter original_branch.json improved_branch.json` 


The above will generate a comparison.log file with content akin to:
```
SQL Count Decreases between samples/master.json -> samples/637.json
##########################################################

Queries killed: 0

Duration decrease[ms]: 0.0

SQL Count Increases between samples/master.json -> samples/637.json
##########################################################

Queries killed: 0

Duration decrease[ms]: 0.0

SQL Spawned between samples/master.json -> samples/637.json
##########################################################
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------+-------------------------------------+
|Query                                                                                                                                                                                                                                 |Count difference             |Duration difference [ms]             |
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------+-------------------------------------+
|SELECT `email_default_messages`.* FROM `email_default_messages` WHERE `email_default_messages`.`email_defaults_id` = xxx AND `email_default_messages`.`locale` = xxx AND `email_default_messages`.`message_type` IN (xxx)             |0 -> 1                       |0.0 -> 1.76                          |
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------+-------------------------------------+
Queries spawned: 1

Duration gain[ms]: 1.76

SQL Gone between samples/master.json -> samples/637.json
##########################################################
+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+--------------------+
|Query                                                                                                                                                                                                                                                                   |Count diff… |Duration differenc… |
+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+--------------------+
|SELECT `email_default_messages`.* FROM `email_default_messages` WHERE `email_default_messages`.`email_defaults_id` = xxx AND `email_default_messages`.`locale` = xxx AND `email_default_messages`.`message_type` IN (xxx)                                               |0 -> 1      |0.0 -> 1.76         |
|SELECT `email_default_messages`.* FROM `email_default_messages` WHERE `email_default_messages`.`email_defaults_id` = xxx AND `email_default_messages`.`message_type` = xxx AND `email_default_messages`.`locale` = xxx ORDER BY `email_default_messages`.`id` ASC LIMI… |7 -> 0      |13.78 -> 0.0        |
+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+--------------------+
Queries killed: 7

Duration decrease[ms]: 13.78

################## SUMMARY #####################
+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+--------------------+
|Query                                                                                                                                                                                                                                                                   |Count diff… |Duration differenc… |
+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+--------------------+
|SELECT `email_default_messages`.* FROM `email_default_messages` WHERE `email_default_messages`.`email_defaults_id` = xxx AND `email_default_messages`.`locale` = xxx AND `email_default_messages`.`message_type` IN (xxx)                                               |0 -> 1      |0.0 -> 1.76         |
|SELECT `email_default_messages`.* FROM `email_default_messages` WHERE `email_default_messages`.`email_defaults_id` = xxx AND `email_default_messages`.`message_type` = xxx AND `email_default_messages`.`locale` = xxx ORDER BY `email_default_messages`.`id` ASC LIMI… |7 -> 0      |13.78 -> 0.0        |
+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+--------------------+
Queries killed: 6

Duration decrease[ms]: 12.02
```
