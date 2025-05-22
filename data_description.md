There is no data for the year 2020. The race was cancelled in 2020 because of the Covid pandemic.
If a time column is in the format 9:56:16 then treat that as HH:MM:SS format.  In this case, the value would be 09:56:16 which is 9 hours, 56 minutes, 16 seconds.
Pad a leading 0 if the time column starts with a single digit. All time columns are in HH:MM:SS format.
Columns with the word "time" are in a format of hours:minutes:seconds. Those values do not represent a 24 hour clock schedule or format. They represent cumulative hours, minutes and seconds.  For example, the value "26:45:18" represents a total of 26 hours, 45 minutes and 18 seconds.
To convert column values when doing computations on "time" columns, you can use a SQL command such as this example:
SELECT AVG(CAST(SUBSTR(finish_time, 1, 2) AS INTEGER) * 3600 + CAST(SUBSTR(finish_time, 4, 2) AS INTEGER) * 60 + CAST(SUBSTR(finish_time, 7, 2) AS INTEGER)) AS avg_finish_time_seconds FROM wser_results WHERE year = 2019 AND finish_time NOT LIKE 'DNF'.
Temperature data is in the data description, not the data table.
Convert columns names with "time" into a string format representing hours:minutes:seconds. Those values do not represent a 24 hour clock format. They represent cumulative hours, minutes and seconds.  For example, the value "26:45:18" represents a total of 26 hours, 45 minutes and 18 seconds.
To convert column values when doing computations on those columns, you can use a SQL command such as this example:
Convert all your final answers from total seconds to hours, minutes and seconds. For example, if your answer to a question is "10616 seconds" you need to convert that to "2:56:56" or "2 hours, 56 minutes and 56 seconds"
Columns with the words "position" and "overall_place" represent each runner's position or rank at each of the location columns.  For example, if the runner has a value of "16" at the "robinson_flat_position" then they are in 16th place overall in the race at that position.  If a runner has a value of "2" in the "overall_place" column then they finished the race in second place.
The value "DNF" or "dnf" in the "time" column means that the runner did not successfully complete the race.  To successfully complete the race, the runner must have a time value of less than 30 hours which is less than 30:00:00 and they must not have "DNF" or "dnf" in the "time" column.
The race starts at "olympic_valley".  All "olympic_valley_time" values represent the start so they are in the format of "0:00:00" and all runners have the same position value of "1" at the start "olympic_valley_position".
Consider all text values to be case insensitive.  Force lower case on any text columns if necessary to compare values in those columns.
If the "finish_time" column is 30:00:00 or greater then the runner did not officially finish the race. This is the same as a DNF in the "time" column and "no buckle" in the "buckle type" column
If the "finish_time" column is null then the runner did not finish the race. This is the same as a DNF in the "time" column and "no buckle" in the "buckle type" column
There are two aid stations (also called checkpoints) that are not in this data set. These two are called "Dardanelles" (which is also known as "Cal-1") and "Ford's Bar" (which is also known as "Cal-3") 
The following list identifies the distance to and between aid stations, which are also called checkpoints, and these aid statoins are categorized as follows:
"Checkpoint name",	"Miles from start",	"Kilometers from start",	"Miles to next checkpoint", "Kilometers to next checkpoint":
"Olympic Valley",	0,	0,	10.3,	16.6
"Lyon Ridge",	10.3,	16.6,	5.5,	8.8
"Red Star Ridge",	15.8, 25.4, 8.6, 13.9
"Duncan Canyon", 24.4, 39.3, 5.9,	9.5
"Robinson Flat",	30.3,	48.8,	4.1,	6.6
"Miller's Defeat",	34.4,	55.4,	3.6,	5.8
"Dusty Corners",	38,	61.2,	5.3,	8.5
"Last Chance",	43.3,	69.7,	4.5,	7.2
"Devil's Thumb",	47.8,	76.9,	5.1,	8.2
"El Dorado Creek",	52.9,	85.1,	2.8,	4.5
"Michigan Bluff",	55.7,	89.6,	6.3,	10.2
"Foresthill", 62, 99.8,	8.7, 14
"Peachstone (Cal-2)",	70.7,	113.8,	7.3,	11.7
"Rucky Chucky",	78,	125.5,	1.8,	2.9
"Green Gate",	79.8,	128.4,	5.4,	8.7
"Auburn Lake Trails",	85.2,	137.1,	5.5,	8.9
"Quarry Road",	90.7,	146,	3.6,	5.8
"Pointed Rocks",	94.3,	151.8,	4.6,	7.4
"Robie Point",	98.9,	159.2,	1.3,	2.1
"Placer High School",	100.2,	161.3,	0,	0

The following list identifies the conditions for each race year.
"date","high_temp_fahrenheit","low_temp_fahrenheit","finish_percentage","snow_level","river_crossing_method"
2024-06-29,94,63,76.3,light,foot
2023-06-24,80,51,86.5,moderate,boat
2022-06-25,97,70,79.6,light,foot
2021-06-26,101,73,66,light,foot
2019-06-29,83,57,86.4,moderate,boat
2018-06-23,98,61,81,light,foot
2017-06-24,95,75,67.2,moderate,boat
