:- module(http_date,
            [decode/2,
             encode/2,
             is_imf_fixdate/1,
             is_rfc850/1,
             is_asctime/1,
             valid_date/1,
             valid_time/1,
             valid_http_date/1,
             valid_calendar_date/1,
             http_date//2]).

day(mon, 1, `Mon`, `Monday`).
day(tue, 2, `Tue`, `Tuesday`).
day(wed, 3, `Wed`, `Wednesday`).
day(thu, 4, `Thu`, `Thursday`).
day(fri, 5, `Fri`, `Friday`).
day(sat, 6, `Sat`, `Saturday`).
day(sun, 7, `Sun`, `Sunday`).

month(1, `Jan`, 31).
month(2, `Feb`, 28).
month(3, `Mar`, 31).
month(4, `Apr`, 30).
month(5, `May`, 31).
month(6, `Jun`, 30).
month(7, `Jul`, 31).
month(8, `Aug`, 31).
month(9, `Sep`, 30).
month(10, `Oct`, 31).
month(11, `Nov`, 30).
month(12, `Dec`, 31).

leap_year(Y) :-
    0 is Y mod 4,
    ( 0 is Y mod 100 -> 0 is Y mod 400; true ).

days_in_month(Y, M, N) :-
    month(M, _, N0),
    ( M =:= 2, leap_year(Y) -> N is N0 + 1; N = N0 ).

datetime_year(datetime(_, date(Y, _, _), _), Y).

literal([]) --> [].
literal([C|Cs]) --> [C], literal(Cs).

day_name(D, short) --> { day(D, _, Cs, _) }, literal(Cs).
day_name(D, long)  --> { day(D, _, _, Cs) }, literal(Cs).

month_name(M) --> { month(M, Cs, _) }, literal(Cs).

gmt --> `GMT`.

ndigits(0, []) --> [].
ndigits(N, [C|Cs]) -->
    { N > 0, N0 is N - 1 },
    [C],
    { code_type(C, digit) },
    ndigits(N0, Cs).

digits(N, V) --> { var(V) }, !, ndigits(N, Cs), { number_codes(V, Cs) }.
digits(N, V) --> { format(codes(Cs), '~|~`0t~d~*|', [V, N]) }, ndigits(N, Cs).

time(time(H, Mi, S)) -->
    digits(2, H), `:`, digits(2, Mi), `:`, digits(2, S).

asctime_day(D) --> ` `, digits(1, D), { D < 10 }.
asctime_day(D) --> digits(2, D).

date1(date(Y, M, D)) -->
    digits(2, D), ` `, month_name(M), ` `, digits(4, Y).

date2(date(Y, M, D)) -->
    digits(2, D), `-`, month_name(M), `-`, digits(2, Y).

http_date(imf_fixdate, datetime(Day, Date, Time)) -->
    day_name(Day, short), `, `, date1(Date), ` `, time(Time), ` GMT`.

http_date(rfc850, datetime(Day, Date, Time)) -->
    day_name(Day, long), `, `, date2(Date), ` `, time(Time), ` GMT`.

http_date(asctime, datetime(Day, date(Y, M, D), Time)) -->
    day_name(Day, short), ` `, month_name(M), ` `, asctime_day(D), ` `,
    time(Time), ` `, digits(4, Y).

http_date_datetime(http_date(_, DateTime), DateTime).

decode(Text, http_date(Format, DateTime)) :-
    string_codes(Text, Codes),
    once(phrase(http_date(Format, DateTime), Codes)).

encode(http_date(Format, DateTime), Text) :-
    once(phrase(http_date(Format, DateTime), Codes)),
    string_codes(Text, Codes).

is_imf_fixdate(http_date(imf_fixdate, _)).
is_rfc850(http_date(rfc850,_)).
is_asctime(http_date(asctime, _)).

valid_date(date(Y, M, D)) :-
    between(0, 9999, Y),
    days_in_month(Y, M, Max),
    between(1, Max, D).

valid_time(time(H, Mi, S)) :-
    between(0, 23, H),
    between(0, 59, Mi),
    between(0, 59, S).

valid_http_date(http_date(_, datetime(_,Date, Time))) :-
    valid_date(Date),
    valid_time(Time).

valid_dayname(http_date(_, datetime(Day, date(Y, M, D), _))) :-
    day_of_the_week(date(Y, M, D), N),
    day(Day, N, _, _).

valid_calendar_date(http_date(Format, DateTime)) :-
    valid_http_date(http_date(Format, DateTime)),
    ( Format == rfc850 -> true
    ; valid_dayname(http_date(Format, DateTime))
    ).

:- begin_tests(http_date).

test(imf) :-
    decode("Sun, 06 Nov 1994 08:49:37 GMT", D),
    assertion(D == http_date(imf_fixdate, datetime(sun, date(1994,11,6), time(8,49,37)))).

test(rfc850) :-
    decode("Sunday, 06-Nov-94 08:49:37 GMT", D),
    assertion(D == http_date(rfc850, datetime(sun, date(94,11,6), time(8,49,37)))).

test(asctime_padded) :-
    decode("Sun Nov  6 08:49:37 1994", D),
    assertion(D == http_date(asctime, datetime(sun, date(1994,11,6), time(8,49,37)))).

test(asctime_two_digit) :-
    decode("Wed Nov 16 08:49:37 1994", D),
    assertion(D == http_date(asctime, datetime(wed, date(1994,11,16), time(8,49,37)))).

test(trailing_data, [fail]) :- decode("Sun, 06 Nov 1994 08:49:37 GMTx", _).
test(garbage, [fail]) :- decode("not a date", _).
test(feb_31_rejected, [fail]) :- decode("Sun, 31 Feb 1994 08:49:37 GMT", D), valid_http_date(D).
test(feb_29_leap) :- decode("Tue, 29 Feb 2000 08:49:37 GMT", D), valid_http_date(D).
test(feb_29_century_not_leap, [fail]) :- decode("Thu, 29 Feb 1900 08:49:37 GMT", D), valid_http_date(D).
test(dayname_matches) :- decode("Sun, 06 Nov 1994 08:49:37 GMT", D), valid_dayname(D).
test(dayname_mismatch, [fail]) :- decode("Mon, 06 Nov 1994 08:49:37 GMT", D), valid_dayname(D).
tset(leap_years, [forall(member(Y-Is, [1992-true, 1900-false, 2000-true, 1994-false]))]) :-
    (leap_year(Y) -> Got = true; Got = false),
    assertion(Got == Is).
test(hour_out_of_range, [fail]) :- decode("Sun, 06 Nov 1994 25:49:37 GMT", D), valid_http_date(D).

test(rfc850_rejects_four_digit_year, [fail]) :-
    encode(http_date(rfc850, datetime(sun, date(1994,11,6), time(8,49,37))), _).

test(roundtrip, [forall(member(S, ["Sun, 06 Nov 1994 08:49:37 GMT",
                                   "Sunday, 06-Nov-94 08:49:37 GMT",
                                   "Sun Nov  6 08:49:37 1994"]))]) :-
    decode(S, D), encode(D, S2), assertion(S2 == S).

test(every_day_and_month, [forall((day(Day,_,_,_), month(M,_,_)))]) :-
    Date = http_date(imf_fixdate, datetime(Day, date(1994, M, 6), time(8,49,37))),
    encode(Date, S), decode(S, Back), assertion(Back == Date).

:- end_tests(http_date).
