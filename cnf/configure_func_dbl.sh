# Same tests as with non-FP routines, but these all require math.h.

includes='math.h'
checkfunc d_acosh 'acosh' '0.0'
checkfunc d_asinh 'asinh' '0.0'
checkfunc d_atanh 'atanh' '0.0'
checkfunc d_cbrt 'cbrt' '0.0'
checkfunc d_copysign 'copysign' '0.0, 0.0'
checkfunc d_copysignl 'copysignl' "0.0,0.0"
checkfunc d_erf 'erf' '0.0'
checkfunc d_erfc 'erfc' '0.0'
checkfunc d_exp2 'exp2' '0.0'
checkfunc d_expm1 'expm1' '0.0'
checkfunc d_fdim 'fdim' '0.0, 0.0'
checkfunc d_fegetround 'fegetround' '' 'fenv.h'
checkfunc d_finite 'finite' "0.0"
checkfunc d_finitel 'finitel' "0.0"
checkfunc d_fma 'fma' '0.0, 0.0, 0.0'
checkfunc d_fmax 'fmax' '0.0, 0.0'
checkfunc d_fmin 'fmin' '0.0, 0.0'
checkfunc d_fp_classify 'fp_classify' '0.0'
checkfunc d_fp_classl 'fp_classl' '0.0'
# d_fpclass see below
# d_fpclassify see below
checkfunc d_fpclassl 'fpclassl' "1.0" 'ieeefp.h'
checkfunc d_fpgetround 'fpgetround' '' 'fenv.h'
checkfunc d_frexpl 'frexpl' '0,NULL'
checkfunc d_hypot 'hypot' '0.0, 0.0'
checkfunc d_ilogb 'ilogb' '0.0'
checkfunc d_isfinite 'isfinite' "0.0"
checkfunc d_isfinitel 'isfinitel' '0.0'
checkfunc d_isinf 'isinf' "0.0"
checkfunc d_isinfl 'isinfl' '0.0'
checkfunc d_isless 'isless' '0.0, 0.0'
checkfunc d_isnan 'isnan' "0.0"
checkfunc d_isnanl 'isnanl' "0.0"
checkfunc d_isnormal 'isnormal' '0.0'
checkfunc d_j0 'j0' '0.0'
checkfunc d_j0l 'j0l' '0.0'
checkfunc d_ldexpl 'ldexpl' '0.0, 0'
checkfunc d_lgamma 'lgamma' '0.0'
checkfunc d_lgamma_r 'lgamma_r' '0.0, NULL'
checkfunc d_llrint 'llrint' '0.0'
checkfunc d_llrintl 'llrintl' '0.0'
checkfunc d_llround 'llround' '0.0'
checkfunc d_llroundl 'llroundl' '0.0'
checkfunc d_log1p 'log1p' '0.0'
checkfunc d_log2 'log2' '0.0'
checkfunc d_logb 'logb' '0.0'
checkfunc d_lrint 'lrint' '0.0'
checkfunc d_lrintl 'lrintl' '0.0'
checkfunc d_lround 'lround' '0.0'
checkfunc d_lroundl 'lroundl' '0.0'
checkfunc d_modfl 'modfl' "0.0,NULL"
checkfunc d_nan 'nan' 'NULL' 'stdlib.h math.h'
checkfunc d_nearbyint 'nearbyint' '0.0'
checkfunc d_nextafter 'nextafter' '0.0, 0.0'
checkfunc d_nexttoward 'nexttoward' '0.0, 0.0'
checkfunc d_remainder 'remainder' '0.0, 0.0'
checkfunc d_remquo 'remquo' '0.0, 0.0, NULL'
checkfunc d_rint 'rint' '0.0'
checkfunc d_round 'round' '0.0'
checkfunc d_scalbn 'scalbn' '0.0, 0'
checkfunc d_scalbnl 'scalbnl' "0.0,0"
checkfunc d_signbit 'signbit' '.0'
checkfunc d_sqrtl 'sqrtl' "0.0"
checkfunc d_tgamma 'tgamma' '0.0'
checkfunc d_trunc 'trunc' '0.0'
checkfunc d_truncl 'truncl' '0.0'
unset includes

# Extended test for fpclassify. Linking alone is not enough apparently,
# the constants must be defined as well.

# checkfpclass d_func func 'includes' D1 D2 D3 ....
checkfpclass() {
	_sym=$1
	_fun=$2
	_inc=$3

	mstart "Checking whether $_fun() is usable"
	if not hinted $_sym 'yes' 'no'; then
		try_start
		try_includes $_inc
		try_add "int main(void) { return $_fun(0.0); }"
		shift; shift; shift;

		for c in $*; do
			try_add "int v_$c = $c;"
		done

		try_link
		resdef $_sym 'yes' "no, disabling $_fun()"
	fi
}

checkfpclass d_fpclassify fpclassify 'math.h' \
	FP_NAN FP_INFINITE FP_NORMAL FP_SUBNORMAL FP_ZERO

checkfpclass d_fpclass fpclass 'math.h ieeefp.h' \
	FP_SNAN FP_QNAN FP_NEG_INF FP_POS_INF FP_NEG_INF \
	FP_NEG_NORM FP_POS_NORM FP_NEG_NORM FP_NEG_DENORM FP_POS_DENORM \
	FP_NEG_DENORM FP_NEG_ZERO FP_POS_ZERO FP_NEG_ZERO
