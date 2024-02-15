module gml.maths;

import std.datetime, std.format, std.math, std.random;
import ic.calc;

alias pi = ic.calc.pi;

//Date And Time

enum TimeZone{
	local,
	utc,
}
alias timezone = TimeZone;

TimeZone timeZone = TimeZone.local;

void dateSetTimeZone(TimeZone timeZone) nothrow @nogc @safe{
	.timeZone = timeZone;
}
alias date_set_timezone = dateSetTimeZone;

TimeZone dateGetTimeZone() nothrow @nogc @safe =>
	timeZone;
alias date_get_timezone = dateGetTimeZone;

///This function is unique to De-GML.
auto getTimeZone() nothrow @safe =>
	timeZone == TimeZone.utc ? UTC() : LocalTime();

///This function is unique to De-GML.
DateTime getDateTime() nothrow @safe =>
	cast(DateTime)Clock.currTime(getTimeZone());

@property ulong currentTime() nothrow @safe =>
	(MonoTime.currTime - MonoTime.zero).total!"msecs"();
alias current_time = currentTime;

@property ubyte currentSecond() nothrow @safe =>
	getDateTime().second;
alias current_second = currentSecond;

@property ubyte currentMinute() nothrow @safe =>
	getDateTime().minute;
alias current_minute = currentMinute;

@property ubyte currentHour() nothrow @safe =>
	getDateTime().hour;
alias current_hour = currentHour;

@property ubyte currentDay() nothrow @safe =>
	getDateTime().day;
alias current_day = currentDay;

@property ubyte currentWeekday() nothrow @safe =>
	cast(ubyte)getDateTime().dayOfWeek;
alias current_weekday = currentWeekday;

@property ubyte currentMonth() nothrow @safe =>
	cast(ubyte)getDateTime().month;
alias current_month = currentMonth;

@property short currentYear() nothrow @safe =>
	getDateTime().year;
alias current_year = currentYear;

DateTime dateCreateDateTime(int year, int month, int day, int hour, int minute, int second) pure @safe =>
	DateTime(year, month, day, hour, minute, second);
alias date_create_datetime = dateCreateDateTime;

DateTime dateCurrentDateTime() nothrow @safe =>
	cast(DateTime)Clock.currTime(UTC());
alias date_current_datetime = dateCurrentDateTime;

int dateCompareDate(DateTime date1, DateTime date2) nothrow @nogc pure @safe =>
	date1.date < date2.date ? -1 : date1.date == date2.date ? 0 : 1;
alias date_compare_date = dateCompareDate;

int dateCompareDateTime(DateTime date1, DateTime date2) nothrow @nogc pure @safe =>
	date1 < date2 ? -1 : date1 == date2 ? 0 : 1;
alias date_compare_datetime = dateCompareDateTime;

int dateCompareTime(DateTime date1, DateTime date2) nothrow @nogc pure @safe =>
	date1.timeOfDay < date2.timeOfDay ? -1 : date1.timeOfDay == date2.timeOfDay ? 0 : 1;
alias date_compare_time = dateCompareTime;

bool dateValidDateTime(int year, int month, int day, int hour, int minute, int second) nothrow pure @safe{
	if(year < 1970) return false;
	try{
		enforceValid!"months"(month);
		enforceValid!"hours"(hour);
		enforceValid!"minutes"(minute);
		enforceValid!"seconds"(second);
		return true;
	}catch(Exception ex){
		return false;
	}
}
alias date_valid_datetime = dateValidDateTime;

DateTime dateDateOf(DateTime date) @nogc pure @safe =>
	DateTime(date.date);
alias date_date_of = dateDateOf;

DateTime dateTimeOf(DateTime date) pure @safe =>
	DateTime(Date(1970, 1, 1), date.timeOfDay);
alias date_time_of = dateTimeOf;

bool dateIsToday(DateTime date) nothrow @safe =>
	date.date == dateCurrentDateTime().date;
alias date_is_today = dateIsToday;

bool dateLeapYear(DateTime date) nothrow @safe =>
	SysTime(date, getTimeZone()).isLeapYear;
alias date_leap_year = dateLeapYear;

string dateDateString(DateTime date) nothrow @safe{
	const time = SysTime(date, getTimeZone());
	try{
		return format("%02u/%02u/%u", time.day, cast(ubyte)time.month, time.year);
	}catch(Exception ex){
		assert(0);
	}
}
alias date_date_string = dateDateString;
unittest{
	dateSetTimeZone(TimeZone.utc);
	assert(dateCreateDateTime(2019,9,27, 0,0,0).dateDateString() == "27/09/2019");
}

///Does not consider system locale settings, as the GameMaker equivalent does.
string dateDateTimeString(DateTime date) nothrow{
	const time = SysTime(date, getTimeZone());
	string monthName = {
		switch(date.month){
			case  1: return "January";
			case  2: return "February";
			case  3: return "March";
			case  4: return "April";
			case  5: return "May";
			case  6: return "June";
			case  7: return "July";
			case  8: return "August";
			case  9: return "September";
			case 10: return "October";
			case 11: return "November";
			case 12: return "December";
			default: assert(0);
		}
	}();
	string dayExt = {
		switch(date.day){
			case 1, 21, 31: return "st";
			case 2, 22:     return "nd";
			case 3, 23:     return "rd";
			default:        return "th";
		}
	}();
	try{
		return format(
			"%u%s %s %u, %02u:%02u:%02u",
			date.day, dayExt,
			monthName,
			date.year,
			date.hour, date.minute, date.second,
		);
	}catch(Exception ex){
		assert(0, format("%s", ex));
	}
}
alias date_datetime_string = dateDateTimeString;
unittest{
	dateSetTimeZone(TimeZone.utc);
	assert(dateCreateDateTime(1979,10,23, 21,42,5).dateDateTimeString() == "23rd October 1979, 21:42:05");
}

///Does not consider system locale settings, as the GameMaker equivalent does.
string dateTimeString(DateTime date) nothrow{
	const time = SysTime(date, getTimeZone());
	try{
		return format(
			"%02u:%02u:%02u",
			date.hour, date.minute, date.second,
		);
	}catch(Exception ex){
		assert(0, format("%s", ex));
	}
	
}
alias date_time_string = dateTimeString;
unittest{
	dateSetTimeZone(TimeZone.utc);
	assert(dateCreateDateTime(1,1,1, 21,42,5).dateTimeString() == "21:42:05");
}

ulong dateSecondSpan(DateTime date1, DateTime date2) nothrow @nogc pure @safe =>
	(date1 - date2).total!"seconds"();
alias date_second_span = dateSecondSpan;

double dateMinuteSpan(DateTime date1, DateTime date2) nothrow @nogc pure @safe =>
	dateSecondSpan(date1, date2) / cast(double)(1.minutes.total!"seconds"());
alias date_minute_span = dateMinuteSpan;

double dateHourSpan(DateTime date1, DateTime date2) nothrow @nogc pure @safe =>
	dateSecondSpan(date1, date2) / cast(double)(1.hours.total!"seconds"());
alias date_hour_span = dateHourSpan;

double dateDaySpan(DateTime date1, DateTime date2) nothrow @nogc pure @safe =>
	dateSecondSpan(date1, date2) / cast(double)(1.days.total!"seconds"());
alias date_day_span = dateDaySpan;

double dateWeekSpan(DateTime date1, DateTime date2) nothrow @nogc pure @safe =>
	dateSecondSpan(date1, date2) / cast(double)(1.weeks.total!"seconds"());
alias date_week_span = dateWeekSpan;

//TODO: figure out the implementation of `date_month_span`. What how long is "a month"?

//TODO: figure out the implementation of `date_year_span`. What is a "a year"?

ubyte dateDaysInMonth(DateTime date) nothrow @safe =>
	SysTime(date, getTimeZone()).daysInMonth;
alias date_days_in_month = dateDaysInMonth;

ushort dateDaysInYear(DateTime date) nothrow @safe =>
	SysTime(date, getTimeZone()).isLeapYear ? 366 : 365;
alias date_days_in_year = dateDaysInYear;

ubyte dateGetSecond(DateTime date) nothrow @safe =>
	(cast(DateTime)SysTime(date, getTimeZone())).second;
alias date_get_second = dateGetSecond;

ubyte dateGetMinute(DateTime date) nothrow @safe =>
	(cast(DateTime)SysTime(date, getTimeZone())).minute;
alias date_get_minute = dateGetMinute;

ubyte dateGetHour(DateTime date) nothrow @safe =>
	(cast(DateTime)SysTime(date, getTimeZone())).hour;
alias date_get_hour = dateGetHour;

ubyte dateGetDay(DateTime date) nothrow @safe =>
	(cast(DateTime)SysTime(date, getTimeZone())).day;
alias date_get_day = dateGetDay;

ubyte dateGetWeekday(DateTime date) nothrow @safe =>
	cast(ubyte)(cast(DateTime)SysTime(date, getTimeZone())).dayOfWeek;
alias date_get_weekday = dateGetWeekday;

ubyte dateGetWeek(DateTime date) nothrow @safe =>
	(cast(DateTime)SysTime(date, getTimeZone())).isoWeek;
alias date_get_week = dateGetWeek;

ubyte dateGetMonth(DateTime date) nothrow @safe =>
	cast(ubyte)(cast(DateTime)SysTime(date, getTimeZone())).month;
alias date_get_month = dateGetMonth;

short dateGetYear(DateTime date) nothrow @safe =>
	(cast(DateTime)SysTime(date, getTimeZone())).year;
alias date_get_year = dateGetYear;

uint dateGetSecondOfYear(DateTime date) @safe{
	const adjDate = cast(DateTime)SysTime(date, getTimeZone());
	try{
		const startOfYear = Date(adjDate.year, 1, 1);
		return cast(uint)(1 + (DateTime() - adjDate).total!"seconds"());
	}catch(Exception ex){
		assert(0);
	}
}
alias date_get_second_of_year = dateGetSecondOfYear;

uint dateGetMinuteOfYear(DateTime date) nothrow @safe{
	const adjDate = cast(DateTime)SysTime(date, getTimeZone());
	try{
		const startOfYear = Date(adjDate.year, 1, 1);
		return cast(uint)(1 + (DateTime() - adjDate).total!"minutes"());
	}catch(Exception ex){
		assert(0);
	}
}
alias date_get_minute_of_year = dateGetMinuteOfYear;

ushort dateGetHourOfYear(DateTime date) nothrow @safe{
	const adjDate = cast(DateTime)SysTime(date, getTimeZone());
	try{
		const startOfYear = Date(adjDate.year, 1, 1);
		return cast(ushort)(1 + (DateTime() - adjDate).total!"hours"());
	}catch(Exception ex){
		assert(0);
	}
}
alias date_get_hour_of_year = dateGetHourOfYear;

ushort dateGetDayOfYear(DateTime date) nothrow @safe{
	const adjDate = cast(DateTime)SysTime(date, getTimeZone());
	try{
		const startOfYear = Date(adjDate.year, 1, 1);
		return cast(ushort)(1 + (DateTime() - adjDate).total!"minutes"());
	}catch(Exception ex){
		assert(0);
	}
}
alias date_get_day_of_year = dateGetDayOfYear;

DateTime dateIncSecond(DateTime date, long amount) nothrow @nogc pure @safe =>
	date += amount.seconds;
alias date_inc_second = dateIncSecond;

DateTime dateIncMinute(DateTime date, long amount) nothrow @nogc pure @safe =>
	date += amount.minutes;
alias date_inc_minute = dateIncMinute;

DateTime dateIncHour(DateTime date, long amount) nothrow @nogc pure @safe =>
	date += amount.hours;
alias date_inc_hour = dateIncHour;

DateTime dateIncDay(DateTime date, long amount) nothrow @nogc pure @safe =>
	date += amount.days;
alias date_inc_day = dateIncDay;

DateTime dateIncWeek(DateTime date, long amount) nothrow @nogc pure @safe =>
	date += amount.weeks;
alias date_inc_week = dateIncWeek;

//TODO: figure out the implementation of `date_inc_month`. What how long is "a month"?

//TODO: figure out the implementation of `date_inc_year`. What is a "a year"?

ulong getTimer() nothrow @safe =>
	(MonoTime.currTime - MonoTime.zero).total!"usecs"();
alias get_timer = getTimer;

ulong deltaTime;
alias delta_time = deltaTime;

//Number Functions

Mt19937 rng;

T choose(T)(T[] vals...) nothrow @nogc @safe =>
	choice(vals, rng);

double random(double n) @safe =>
	uniform!"[]"(0.0, n, rng);

double randomRange(double n1, double n2) @safe =>
	uniform!"[]"(n1, n2, rng);
alias random_range = randomRange;

long iRandom(long n) @safe =>
	uniform!"[]"(0L, n, rng);
alias irandom = iRandom;

long iRandomRange(long n1, long n2) @safe =>
	uniform!"[]"(n1, n2, rng);
alias irandom_range = iRandomRange;

void randomSetSeed(uint val) nothrow @nogc @safe{
	rng.seed(val);
}
alias random_set_seed = randomSetSeed;

//uint randomGetSeed() nothrow @nogc @safe =>
//	rng.???
//alias random_get_seed = randomGetSeed;

void randomise() nothrow @nogc @safe{
	rng.seed(unpredictableSeed);
}

alias lerp = ic.calc.lerp;

//Angles And Distance 

F dcos(F)(F val) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	cos(val.degToRad());

F dsin(F)(F val) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	sin(val.degToRad());

F dtan(F)(F val) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	tan(val.degToRad());

F dacos(F)(F val) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	acos(val.degToRad());

F dasin(F)(F val) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	asin(val.degToRad());

F datan(F)(F val) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	atan(val).degToRad();
alias darctan = datan;

F datan2(F)(F y, F x) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	atan2(y, x).degToRad();
alias darctan2 = datan2;

F degToRad(F)(F val) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	val * cast(F)PI / cast(F)180;
alias degtorad = degToRad;

F radToDeg(F)(F val) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	val * cast(F)180 / cast(F)PI;
alias radtodeg = radToDeg;

F pointDirection(F)(F x1, F y1, F x2, F y2) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	datan2(y1 - y2, x1 - x2);
alias point_direction = pointDirection;

F pointDistance(F)(F x1, F y1, F x2, F y2) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	(Vec2!F(x1, y1) - Vec2!F(x2, y2)).length;
alias point_distance = pointDistance;

F pointDistance3D(F)(F x1, F y1, F z1, F x2, F y2, F z2) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	(Vec3!F(x1, y1, z1) - Vec3!F(x2, y2, z2)).length;
alias point_distance_3d = pointDistance3D;

//TODO: distance_to_object

//TODO: distance_to_point

F dotProduct(F)(F x1, F y1, F x2, F y2) nothrow @nogc pure @safe 
if(__traits(isFloating, F)) =>
	Vec2!F(x1, y1).dot(Vec2!F(x1, y1));
alias dot_product = dotProduct;

F dotProduct3D(F)(F x1, F y1, F z1, F x2, F y2, F z2) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	Vec3!F(x1, y1, z1).dot(Vec3!F(x2, y2, z2));
alias dot_product_3d = dotProduct3D;

F dotProductNormalised(F)(F x1, F y1, F x2, F y2) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	Vec3!F(x1, y1).normal().dot(Vec3!F(x2, y2).normal());
alias dot_product_normalised = dotProductNormalised;

F angleDifference(F)(F x, F y) nothrow @nogc pure @safe
if(__traits(isFloating, F)){
	F mod(F a, F n) => a - floor(a / n) * n;
	return mod((y - x) + 180.0, 360.0) - 180.0;
}
alias angle_difference = angleDifference;

F lengthDirX(F)(F len, F dir) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	dcos(dir) * len;
alias lengthdir_x = lengthDirX;

F lengthDirY(F)(F len, F dir) nothrow @nogc pure @safe
if(__traits(isFloating, F)) =>
	dsin(dir) * len;
alias lengthdir_y = lengthDirY;
