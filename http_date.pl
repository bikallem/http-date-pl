:- module(http_date, [decode/2, encode/2, is_imf_fixdate/1, is_rfc850/1, is_asctime/1, http_date//2]).

day(mon, `Mon`, `Monday`).
day(tue, `Tue`, `Tuesday`).
day(wed, `Wed`, `Wednesday`).
day(thu, `Thu`, `Thursday`).
day(fri, `Fri`, `Friday`).
day(sat, `Sat`, `Saturday`).
day(sun, `Sun`, `Sunday`).

month(1, `Jan`).
month(2, `Feb`).
month(3, `Mar`).
month(4, `Apr`).
month(5, `May`).
month(6, `Jun`).
month(7, `Jul`).
month(8, `Aug`).
month(9, `Sep`).
month(10, `Oct`).
month(11, `Nov`).
month(12, `Dec`).

valid_date(date(Y, M, D)) :-
    between(0, 9999, Y),
    month(M, _),
    between(1, 31, D).

valid_time(time(H, Mi, S)) :-
    between(0, 23, H),
    between(0, 59, Mi),
    between(0, 59, S).


datetime_year(datetime(_, date(Y, _, _), _), Y).


literal([]) --> [].
literal([C|Cs]) --> [C], literal(Cs).

day_name(D, short) --> { day(D, Cs, _) }, literal(Cs).
day_name(D, long)  --> { day(D, _, Cs) }, literal(Cs).

month_name(M) --> { month(M, Cs) }, literal(Cs).

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
    digits(2, H), `:`, digits(2, Mi), `:`, digits(2, S),
    { valid_time(time(H, Mi, S)) }.

asctime_day(D) --> ` `, digits(1, D), { D < 10 }.
asctime_day(D) --> digits(2, D).

date1(date(Y, M, D)) -->
    digits(2, D), ` `, month_name(M), ` `, digits(4, Y),
    { valid_date(date(Y, M, D)) }.

date2(date(Y, M, D)) -->
    digits(2, D), `-`, month_name(M), `-`, digits(2, Y),
    { valid_date(date(Y, M, D)) }.

http_date(imf_fixdate, datetime(Day, Date, Time)) -->
    day_name(Day, short), `, `, date1(Date), ` `, time(Time), ` GMT`.    

http_date(rfc850, datetime(Day, Date, Time)) -->
    day_name(Day, long), `, `, date2(Date), ` `, time(Time), ` GMT`.

http_date(asctime, datetime(Day, date(Y, M, D), Time)) -->
    day_name(Day, short), ` `, month_name(M), ` `, asctime_day(D), ` `,
    time(Time), ` `, digits(4, Y),
    { valid_date(date(Y, M, D)) }.

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

:- begin_tests(http_date).

test(imf) :-
    decode("Sun, 06 Nov 1994 08:49:37 GMT", D),
    assertion(D == http_date(imf_fixdate, datetime(sun, date(1994,11,6), time(8,49,37)))).

:- end_tests(http_date).
