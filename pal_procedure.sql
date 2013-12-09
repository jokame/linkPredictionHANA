--Those who wants to buy, actually buy.

set schema CARLOS;

drop type PAL_LP_DATA_T;
create type PAL_LP_DATA_T as table ("NODE1" INTEGER, "NODE2" INTEGER);

drop type PAL_LP_RESULT_T;
create type PAL_LP_RESULT_T as table ("NODE1" INTEGER, "NODE2" INTEGER, "SCORE" DOUBLE);

drop type PAL_CONTROL_T;
create type PAL_CONTROL_T as table (
	"NAME" VARCHAR(100),
	"INT_ARGS" INTEGER,
	"DOUBLE_ARGS" DOUBLE, 
	"STRING_ARGS" VARCHAR(100)
);

drop table PAL_LP_PDATA_TBL;
create column table PAL_LP_PDATA_TBL(
	"ID" INTEGER, 
	"TYPENAME" VARCHAR(100),
	"DIRECTION" VARCHAR(100)
);

insert into PAL_LP_PDATA_TBL values (1, 'CARLOS.PAL_LP_DATA_T', 'in');
insert into PAL_LP_PDATA_TBL values (2, 'CARLOS.PAL_CONTROL_T', 'in');
insert into PAL_LP_PDATA_TBL values (2, 'CARLOS.PAL_LP_RESULT_T', 'out');

-- some times is necesary to uncomment the next line
-- grant select on CARLOS.PAL_LP_PDATA_TBL to system; 

call "SYSTEM"."AFL_WRAPPER_ERASER"('PAL_LINK_PREDICTION_BUYERS');
call "SYSTEM"."AFL_WRAPPER_GENERATOR"('PAL_LINK_PREDICTION_BUYERS', 'AFLPAL', 'LINKPREDICTION', PAL_LP_PDATA_TBL);

drop table #PAL_CONTROL_TBL;

create local temporary column table #PAL_CONTROL_TBL like PAL_CONTROL_T;
insert into #PAL_CONTROL_TBL values ('THREAD_NUMBER', 1, null, null);
insert into #PAL_CONTROL_TBL values ('METHOD', 1, null, null);
insert into #PAL_CONTROL_TBL values ('BETA', null, 0.005, null);

drop table PAL_LP_DATA_TBL;
create column table PAL_LP_DATA_TBL AS (
	select ID_FROM "NODE1", ID_TO "NODE2"
	from "CARLOS"."LOG_TRANS"
	where
		MONTH_IN_YEAR = 6 -- Selection of the desired month
	group by ID_FROM, ID_TO
);

drop table PAL_LP_RESULT_TBL;
create column table PAL_LP_RESULT_TBL LIKE PAL_LP_RESULT_T;

call _SYS_AFL.PAL_LINK_PREDICTION_BUYERS(PAL_LP_DATA_TBL, #PAL_CONTROL_TBL, PAL_LP_RESULT_TBL) with overview;
select NODE1 "BUYER", NODE2 "SELLER", SCORE from PAL_LP_RESULT_TBL;
