#include "ruby.h"
#include <time.h>

static VALUE t_init(VALUE self, VALUE fixtime)
{
	long pause;
	int inttime;
    clock_t now,then;

	if (FIXNUM_P(fixtime) == 0) {
		return -1;
	}	

    inttime = FIX2INT(fixtime);
    pause = inttime * (CLOCKS_PER_SEC / 1000);
    now = then = clock();
    while((now - then) < pause)
        now = clock();

	return self;
}

VALUE cTimer;
void Init_timer() {
	cTimer = rb_define_class("Timer", rb_cObject);
	rb_define_method(cTimer, "initialize", t_init, 1);
}