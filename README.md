## What this is?

This is a gem that can be used for comparing sql_tracker reports for different branches.

## Setup

Simply run the following in terminal while in the repo directory (temporary solution while not in rubygems.org)
```
gem build sql_reporter.gemspec
gem install sql_reporter
```

## Usage

`sql_reporter original_branch.json improved_branch.json` 


The above will generate a comparison.log file with content akin to:
```
SQL Query Count Decreases between master.json -> ponyland.json
##########################################################
Difference for SELECT COUNT(*) FROM `ponies` WHERE `ponies`.`business_id` = xxx AND `ponies`.`user_id` = xxx:
Count drop: 24 -> 18
SQL Query Count Increases between master.json -> ponyland.json
##########################################################
Difference for SELECT `tails`.* FROM `tails` WHERE `tails`.`id` = xxx LIMIT xxx:
Count drop: 220 -> 230
Difference for SELECT `hooves`.* FROM `hooves` WHERE `hooves`.`id` = xxx ORDER BY name ASC LIMIT xxx:
Count drop: 228 -> 238
Difference for SELECT `apples`.* FROM `apples` WHERE `apples`.`business_id` = xxx LIMIT xxx:
Count drop: 9 -> 10
SQL New Queries between master.json -> ponyland.json
##########################################################
Difference for SELECT COUNT(*) FROM `ponies` WHERE `ponies`.`business_id` = xxx AND `remote_reports`.`user_id` = xxx AND (magic is not null):
Count difference: 0 -> 9
SQL Gone Queries between master.yml -> ponyland.json
##########################################################
Difference for EXPLAIN PARTITIONS UPDATE `saddles` SET `total_amount` = xxx, `updated_at` = xxx WHERE `saddles`.`id` = xxx:
Count difference: 1 -> 0
Difference for UPDATE `saddles` SET `total_amount` = xxx, `updated_at` = xxx WHERE `saddles`.`id` = xxx:
Count difference: 1 -> 0
```
