--
--  Test mpz datatype
--

--
-- first, define the datatype.  Turn off echoing so that expected file
-- does not depend on contents of pgmp.sql.
--
SET client_min_messages = warning;
\set ECHO none
\i pgmp.sql
\t
\a
\set ECHO all
RESET client_min_messages;


--
-- mpz input and output functions
--

SELECT '0'::mpz;
SELECT '1'::mpz;
SELECT '-1'::mpz;
SELECT '10'::mpz;
SELECT '-10'::mpz;

SELECT '000001'::mpz;       -- padding zeros
SELECT '-000001'::mpz;

SELECT '4294967295'::mpz;   -- limbs boundaries
SELECT '4294967296'::mpz;
SELECT '-4294967296'::mpz;
SELECT '-4294967297'::mpz;
SELECT '18446744073709551614'::mpz;
SELECT '18446744073709551615'::mpz;
SELECT '18446744073709551616'::mpz;
SELECT '18446744073709551617'::mpz;
SELECT '-18446744073709551615'::mpz;
SELECT '-18446744073709551616'::mpz;
SELECT '-18446744073709551617'::mpz;
SELECT '-18446744073709551618'::mpz;

SELECT '12345678901234567890123456789012345678901234567890123456789012345678901234567890'::mpz;

-- other bases
SELECT '0x10'::mpz, '010'::mpz, '0b10'::mpz;
SELECT mpz('10'), mpz('10', 16), mpz('10', 2), mpz('10', 62);
SELECT mpz('10', 1);
SELECT mpz('10', 63);
SELECT mpz('10', 0), mpz('0x10', 0), mpz('010', 0), mpz('0b10', 0);

SELECT text(10::mpz);
SELECT text(10::mpz, 2);
SELECT text(10::mpz, -2);
SELECT text(255::mpz, 16);
SELECT text((36 * 36 - 1)::mpz, 36);
SELECT text((62 * 62 - 1)::mpz, 62);
SELECT text((36 * 36 - 1)::mpz, -36);
SELECT text(10::mpz, -37);
SELECT text(10::mpz, -1);
SELECT text(10::mpz, 0);
SELECT text(10::mpz, 1);
SELECT text(10::mpz, 63);

-- limited error
SELECT ('xx' || repeat('1234567890', 10))::mpz;
SELECT mpz('xx' || repeat('1234567890', 10), 42);


--
-- mpz cast
--

SELECT 0::smallint::mpz, (-32768)::smallint::mpz, 32767::smallint::mpz;
SELECT 0::integer::mpz, (-2147483648)::integer::mpz, 2147483647::integer::mpz;
SELECT 0::bigint::mpz, (-9223372036854775808)::bigint::mpz, 9223372036854775807::bigint::mpz;
SELECT 0::numeric::mpz, (-12345678901234567890)::numeric::mpz, 12345678901234567890::numeric::mpz;
-- decimal are truncated
SELECT 123.10::numeric::mpz, 123.90::numeric::mpz;
SELECT (-123.10::numeric)::mpz, (-123.90::numeric)::mpz;
SELECT 'NaN'::numeric::mpz;

SELECT 0.0::float4::mpz, 123.15::float4::mpz, 123.95::float4::mpz;
SELECT (1e36::float4)::mpz BETWEEN pow(10::mpz,36) - pow(10::mpz,30) AND pow(10::mpz,36) + pow(10::mpz,30);
SELECT (-1e36::float4)::mpz BETWEEN -pow(10::mpz,36) - pow(10::mpz,30) AND -pow(10::mpz,36) + pow(10::mpz,30);
SELECT 'NaN'::float4::mpz;
SELECT 'Infinity'::float4::mpz;
SELECT '-Infinity'::float4::mpz;

SELECT 0.0::float8::mpz, 123.15::float8::mpz, 123.95::float8::mpz;
SELECT (1e307::float8)::mpz BETWEEN pow(10::mpz,307) - pow(10::mpz,307-15) AND pow(10::mpz,307) + pow(10::mpz,307-15);
SELECT (-1e307::float8)::mpz BETWEEN -pow(10::mpz,307) - pow(10::mpz,307-15) AND -pow(10::mpz,307) + pow(10::mpz,307-15);
SELECT 'NaN'::float8::mpz;
SELECT 'Infinity'::float8::mpz;
SELECT '-Infinity'::float8::mpz;

SELECT 0::mpz, 1::mpz, (-1)::mpz;       -- automatic casts
SELECT 1000000::mpz, (-1000000)::mpz;
SELECT 1000000000::mpz, (-1000000000)::mpz;
SELECT 1000000000000000::mpz, (-1000000000000000)::mpz;
SELECT 1000000000000000000000000000000::mpz, (-1000000000000000000000000000000)::mpz;

SELECT -1::mpz;       -- these take the unary minus to work
SELECT -1000000::mpz;
SELECT -1000000000::mpz;
SELECT -1000000000000000::mpz;
SELECT -1000000000000000000000000000000::mpz;

SELECT 2147483647::mpz::integer;
SELECT -2147483647::mpz::integer;
SELECT 2147483648::mpz::integer;
SELECT -2147483648::mpz::integer;
SELECT 32767::mpz::smallint;
SELECT -32767::mpz::smallint;
SELECT 32768::mpz::smallint;
SELECT -32768::mpz::smallint;
SELECT 9223372036854775807::mpz::bigint;
SELECT -9223372036854775807::mpz::bigint;
SELECT 9223372036854775808::mpz::bigint;
SELECT -9223372036854775808::mpz::bigint;
SELECT 2147483648::mpz::bigint;
SELECT -2147483648::mpz::bigint;
SELECT (65536::mpz)::bigint;
SELECT (65536::mpz*65536::mpz)::bigint;
SELECT (65536::mpz*65536::mpz*65536::mpz)::bigint;
SELECT (65536::mpz*65536::mpz*65536::mpz*65536::mpz/2::mpz-1::mpz)::bigint;
SELECT (65536::mpz*65536::mpz*65536::mpz*65536::mpz/2::mpz)::bigint;
SELECT (-65536::mpz)::bigint;
SELECT (-65536::mpz*65536::mpz)::bigint;
SELECT (-65536::mpz*65536::mpz*65536::mpz)::bigint;
SELECT (-65536::mpz*65536::mpz*65536::mpz*65536::mpz/2::mpz+1::mpz)::bigint;
-- TODO: error on 32 bit, works on 64 bit.
-- SELECT (-65536::mpz*65536::mpz*65536::mpz*65536::mpz/2::mpz)::bigint;
SELECT (65536::mpz)::numeric;
SELECT (65536::mpz*65536::mpz)::numeric;
SELECT (65536::mpz*65536::mpz*65536::mpz)::numeric;
SELECT (65536::mpz*65536::mpz*65536::mpz*65536::mpz)::numeric;
SELECT (65536::mpz*65536::mpz*65536::mpz*65536::mpz-1::mpz)::numeric;
SELECT (-65536::mpz)::numeric;
SELECT (-65536::mpz*65536::mpz)::numeric;
SELECT (-65536::mpz*65536::mpz*65536::mpz)::numeric;
SELECT (-65536::mpz*65536::mpz*65536::mpz*65536::mpz)::numeric;
SELECT (-65536::mpz*65536::mpz*65536::mpz*65536::mpz+1::mpz)::numeric;

SELECT 0::mpz::float4, 123::mpz::float4, (-123::mpz)::float4;
SELECT pow(10::mpz, 30)::float4, (-pow(10::mpz, 30))::float4;
SELECT 0::mpz::float8, 123::mpz::float8, (-123::mpz)::float8;
SELECT pow(10::mpz, 307)::float8, (-pow(10::mpz, 307))::float8;


--
-- mpz arithmetic
--

SELECT -('0'::mpz), +('0'::mpz), -('1'::mpz), +('1'::mpz);
SELECT -('12345678901234567890'::mpz), +('12345678901234567890'::mpz);
SELECT abs('-1234567890'::mpz), abs('1234567890'::mpz);

SELECT '1'::mpz + '2'::mpz;
SELECT '2'::mpz + '-4'::mpz;
SELECT regexp_matches((
        ('1' || repeat('0', 1000))::mpz +
        ('2' || repeat('0', 1000))::mpz)::text,
    '^3(0000000000){100}$') IS NOT NULL;

SELECT '3'::mpz - '2'::mpz;
SELECT '3'::mpz - '5'::mpz;
SELECT regexp_matches((
        ('5' || repeat('0', 1000))::mpz -
        ('2' || repeat('0', 1000))::mpz)::text,
    '^3(0000000000){100}$') IS NOT NULL;

SELECT '3'::mpz * '2'::mpz;
SELECT '3'::mpz * '-5'::mpz;
SELECT regexp_matches((
        ('2' || repeat('0', 1000))::mpz *
        ('3' || repeat('0', 1000))::mpz)::text,
    '^6(00000000000000000000){100}$') IS NOT NULL;

-- PostgreSQL should apply the conventional precedence to operators
-- with the same name of the builtin operators.
SELECT '2'::mpz + '6'::mpz * '7'::mpz;  -- cit.


SELECT  '7'::mpz /  '3'::mpz;
SELECT '-7'::mpz /  '3'::mpz;
SELECT  '7'::mpz / '-3'::mpz;
SELECT '-7'::mpz / '-3'::mpz;
SELECT  '7'::mpz %  '3'::mpz;
SELECT '-7'::mpz %  '3'::mpz;
SELECT  '7'::mpz % '-3'::mpz;
SELECT '-7'::mpz % '-3'::mpz;

SELECT  '7'::mpz +/  '3'::mpz;
SELECT '-7'::mpz +/  '3'::mpz;
SELECT  '7'::mpz +/ '-3'::mpz;
SELECT '-7'::mpz +/ '-3'::mpz;
SELECT  '7'::mpz +%  '3'::mpz;
SELECT '-7'::mpz +%  '3'::mpz;
SELECT  '7'::mpz +% '-3'::mpz;
SELECT '-7'::mpz +% '-3'::mpz;

SELECT  '7'::mpz -/  '3'::mpz;
SELECT '-7'::mpz -/  '3'::mpz;
SELECT  '7'::mpz -/ '-3'::mpz;
SELECT '-7'::mpz -/ '-3'::mpz;
SELECT  '7'::mpz -%  '3'::mpz;
SELECT '-7'::mpz -%  '3'::mpz;
SELECT  '7'::mpz -% '-3'::mpz;
SELECT '-7'::mpz -% '-3'::mpz;

SELECT  '7'::mpz /  '0'::mpz;
SELECT  '7'::mpz %  '0'::mpz;
SELECT  '7'::mpz +/  '0'::mpz;
SELECT  '7'::mpz +%  '0'::mpz;
SELECT  '7'::mpz -/  '0'::mpz;
SELECT  '7'::mpz -%  '0'::mpz;

SELECT  '21'::mpz /! '7'::mpz;

SELECT  '10000000000'::mpz << 10;
SELECT  '10000000000'::mpz << 0;
SELECT  '10000000000'::mpz << -1;

SELECT  '1027'::mpz >>   3;
SELECT '-1027'::mpz >>   3;
SELECT  '1027'::mpz >>  -3;
SELECT  '1027'::mpz %>   3;
SELECT '-1027'::mpz %>   3;
SELECT  '1027'::mpz %>  -3;

SELECT  '1027'::mpz +>>   3;
SELECT '-1027'::mpz +>>   3;
SELECT  '1027'::mpz +>>  -3;
SELECT  '1027'::mpz +%>   3;
SELECT '-1027'::mpz +%>   3;
SELECT  '1027'::mpz +%>  -3;

SELECT  '1027'::mpz ->>   3;
SELECT '-1027'::mpz ->>   3;
SELECT  '1027'::mpz ->>  -3;
SELECT  '1027'::mpz -%>   3;
SELECT '-1027'::mpz -%>   3;
SELECT  '1027'::mpz -%>  -3;

SELECT q, r from tdiv_qr( 7::mpz,  3::mpz);
SELECT q, r from tdiv_qr(-7::mpz,  3::mpz);
SELECT q, r from tdiv_qr( 7::mpz, -3::mpz);
SELECT q, r from tdiv_qr(-7::mpz, -3::mpz);
SELECT q, r from tdiv_qr( 7::mpz,  0::mpz);

SELECT q, r from cdiv_qr( 7::mpz,  3::mpz);
SELECT q, r from cdiv_qr(-7::mpz,  3::mpz);
SELECT q, r from cdiv_qr( 7::mpz, -3::mpz);
SELECT q, r from cdiv_qr(-7::mpz, -3::mpz);
SELECT q, r from cdiv_qr( 7::mpz,  0::mpz);

SELECT q, r from fdiv_qr( 7::mpz,  3::mpz);
SELECT q, r from fdiv_qr(-7::mpz,  3::mpz);
SELECT q, r from fdiv_qr( 7::mpz, -3::mpz);
SELECT q, r from fdiv_qr(-7::mpz, -3::mpz);
SELECT q, r from fdiv_qr( 7::mpz,  0::mpz);

SELECT divisible(10::mpz, 3::mpz);
SELECT divisible(12::mpz, 3::mpz);
SELECT divisible(10::mpz, 0::mpz);
SELECT divisible(0::mpz, 0::mpz);
SELECT divisible_2exp(63::mpz, 3);
SELECT divisible_2exp(64::mpz, 3);

SELECT congruent(12::mpz, 16::mpz, 5::mpz);
SELECT congruent(12::mpz, 17::mpz, 5::mpz);
SELECT congruent(12::mpz, 11::mpz, 0::mpz);
SELECT congruent(12::mpz, 12::mpz, 0::mpz);
SELECT congruent_2exp(18::mpz, 41::mpz, 3);
SELECT congruent_2exp(18::mpz, 42::mpz, 3);

-- power operator/functions

SELECT 2::mpz ^ 10;
SELECT 2::mpz ^ 0;
SELECT 2::mpz ^ -1;
SELECT pow(2::mpz, 10);
SELECT pow(2::mpz, 0);
SELECT pow(2::mpz, -1);

--
-- mpz ordering operators
--

select 1000::mpz =   999::mpz;
select 1000::mpz =  1000::mpz;
select 1000::mpz =  1001::mpz;
select 1000::mpz <>  999::mpz;
select 1000::mpz <> 1000::mpz;
select 1000::mpz <> 1001::mpz;
select 1000::mpz !=  999::mpz;
select 1000::mpz != 1000::mpz;
select 1000::mpz != 1001::mpz;
select 1000::mpz <   999::mpz;
select 1000::mpz <  1000::mpz;
select 1000::mpz <  1001::mpz;
select 1000::mpz <=  999::mpz;
select 1000::mpz <= 1000::mpz;
select 1000::mpz <= 1001::mpz;
select 1000::mpz >   999::mpz;
select 1000::mpz >  1000::mpz;
select 1000::mpz >  1001::mpz;
select 1000::mpz >=  999::mpz;
select 1000::mpz >= 1000::mpz;
select 1000::mpz >= 1001::mpz;

select mpz_cmp(1000::mpz,  999::mpz);
select mpz_cmp(1000::mpz, 1000::mpz);
select mpz_cmp(1000::mpz, 1001::mpz);

-- Can create a btree index
create table test_mpz_idx (z mpz);
create index test_mpz_idx_idx on test_mpz_idx (z);


--
-- mpz aggregation
--

CREATE TABLE mpzagg(z mpz);

SELECT sum(z) FROM mpzagg;      -- NULL sum

INSERT INTO mpzagg SELECT generate_series(1, 100);
INSERT INTO mpzagg VALUES (NULL);

SELECT sum(z) FROM mpzagg;
SELECT prod(z) FROM mpzagg;


--
-- test functions
--

SELECT mpz_test_dataset(5, 20);
SELECT numeric_test_dataset(5, '123456'::numeric);

--
-- mpz functions tests
--

SELECT sqrt(25::mpz);
SELECT sqrt(('1' || repeat('0',100))::mpz);
SELECT sqrt(0::mpz);
SELECT sqrt(-1::mpz);

SELECT root(27::mpz, 3);
SELECT root(('1' || repeat('0',100))::mpz, 3);
SELECT root(0::mpz, 3);
SELECT root(27::mpz, 1);
SELECT root(27::mpz, 0);
SELECT root(-27::mpz, 3);
SELECT root(27::mpz, -1);

select * from rootrem(1000::mpz,2) as rootrem;
select * from rootrem(1000::mpz,9) as rootrem;
select * from rootrem(('1' || repeat('0',100))::mpz,2);
select * from rootrem(('1' || repeat('0',100))::mpz,5);
select root from rootrem(1000::mpz, 2);
select rem from rootrem(1000::mpz, 2);

select * from sqrtrem(1000::mpz) as rootrem;
select * from sqrtrem(('1' || repeat('0',100))::mpz);
select root from sqrtrem(1000::mpz);
select rem from sqrtrem(1000::mpz);

select perfect_power(26::mpz);
select perfect_power(27::mpz);
select perfect_power(65535::mpz);
select perfect_power(65536::mpz);
select perfect_power(-65536::mpz);
select perfect_power(-65535::mpz);
select perfect_power(('1' || repeat('0',100))::mpz);
select perfect_power(('1' || repeat('0',10000))::mpz);
select perfect_power(('1' || repeat('0',10001))::mpz);
select perfect_power(('1' || repeat('0',10000))::mpz+1::mpz);

select perfect_square(0::mpz);
select perfect_square(1::mpz);
select perfect_square(-1::mpz);
select perfect_square(26::mpz);
select perfect_square(27::mpz);
select perfect_square(16777215::mpz);
select perfect_square(16777216::mpz);
select perfect_square(('1' || repeat('0',10000))::mpz);
select perfect_square(('1' || repeat('0',10000))::mpz+1::mpz);

--
-- Number Theoretic Functions
--

SELECT probab_prime(5::mpz, 2);
SELECT probab_prime(10::mpz, 2);
SELECT probab_prime(17::mpz, 2);

SELECT nextprime(5::mpz);
SELECT nextprime(10::mpz);
SELECT nextprime(100::mpz);
SELECT nextprime(1000::mpz);
SELECT nextprime(0::mpz);
SELECT nextprime(-8::mpz);

SELECT gcd(3::mpz, 15::mpz);
SELECT gcd(17::mpz, 15::mpz);
SELECT gcd(12345::mpz, 54321::mpz);
SELECT gcd(10000000::mpz, 10000::mpz);

SELECT g, s, t FROM gcdext(6::mpz, 15::mpz);

SELECT lcm(3::mpz, 15::mpz);
SELECT lcm(17::mpz, 15::mpz);
SELECT lcm(12345::mpz, 54321::mpz);

SELECT invert(1::mpz,2::mpz);
SELECT invert(1::mpz,3::mpz);
SELECT invert(2::mpz,3::mpz);
SELECT invert(20::mpz,3::mpz);
SELECT invert(30::mpz,3::mpz);

select jacobi(2::mpz, 3::mpz);
select jacobi(5::mpz, 3::mpz);
select jacobi(5::mpz, 10::mpz);
select jacobi(5::mpz, 20::mpz);
select jacobi(5::mpz, 200::mpz);

select legendre(2::mpz, 3::mpz);
select legendre(5::mpz, 3::mpz);
select legendre(5::mpz, 10::mpz);
select legendre(5::mpz, 20::mpz);
select legendre(5::mpz, 200::mpz);

select kronecker(2::mpz, 3::mpz);
select kronecker(5::mpz, 3::mpz);
select kronecker(5::mpz, 10::mpz);
select kronecker(5::mpz, 20::mpz);
select kronecker(5::mpz, 200::mpz);

select remove(40::mpz, 5::mpz); 
select remove(43::mpz, 5::mpz); 
select remove(48::mpz, 6::mpz); 
select remove(48::mpz, 3::mpz); 


--
-- Logic and bit fiddling functions and operators
--

SELECT text('0b10001'::mpz & '0b01001'::mpz, 2);
SELECT text('0b10001'::mpz | '0b01001'::mpz, 2);
SELECT text('0b10001'::mpz # '0b01001'::mpz, 2);
SELECT com(10::mpz);
SELECT popcount('0b101010'::mpz);
SELECT popcount(0::mpz);
SELECT popcount(-1::mpz) = gmp_max_bitcnt();
SELECT hamdist('0b101010'::mpz, '0b101100'::mpz);
SELECT hamdist(0::mpz, -1::mpz) = gmp_max_bitcnt();
SELECT scan0('0b110110'::mpz, 1);
SELECT scan0('0b110110'::mpz, 3);
SELECT scan0(-1::mpz, 2) = gmp_max_bitcnt();
SELECT scan0(0::mpz, -1);
SELECT scan0(0::mpz, (2^64)::numeric::mpz);
SELECT scan1('0b110110'::mpz, 1);
SELECT scan1('0b110110'::mpz, 3);
SELECT scan1(1::mpz, 2) = gmp_max_bitcnt();
SELECT scan1(0::mpz, -1);
SELECT scan1(0::mpz, (2^64)::numeric::mpz);
SELECT text(setbit('0b1010'::mpz, 0), 2);
SELECT text(setbit('0b1010'::mpz, 1), 2);
SELECT setbit(0::mpz, -1);
SELECT setbit(0::mpz, (2^64)::numeric::mpz);
SELECT text(clrbit('0b1010'::mpz, 0), 2);
SELECT text(clrbit('0b1010'::mpz, 1), 2);
SELECT clrbit(0::mpz, -1);
SELECT clrbit(0::mpz, (2^64)::numeric::mpz);
SELECT text(combit('0b1010'::mpz, 0), 2);
SELECT text(combit('0b1010'::mpz, 1), 2);
SELECT combit(0::mpz, -1);
SELECT combit(0::mpz, (2^64)::numeric::mpz);
SELECT tstbit('0b1010'::mpz, 0);
SELECT tstbit('0b1010'::mpz, 1);
SELECT tstbit(0::mpz, -1);
SELECT tstbit(0::mpz, (2^64)::numeric::mpz);
